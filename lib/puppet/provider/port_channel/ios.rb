require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Port Channel Puppet Provider for Cisco IOS devices
class Puppet::Provider::PortChannel::PortChannel
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.portchannel_interface_names_from_cli(output)
    port_channels_per_interface = {}
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_interfaces_get_instances')}}).each do |raw_instance_fields|
      port_channel_num = PuppetX::CiscoIOS::Utility.parse_attribute(raw_instance_fields, commands_hash, 'interfaces')
      mode = PuppetX::CiscoIOS::Utility.parse_attribute(raw_instance_fields, commands_hash, 'mode')
      next unless port_channel_num
      interface_name = raw_instance_fields.scan(%r{#{PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_interfaces_name')}})
      if port_channels_per_interface[port_channel_num].nil?
        port_channels_per_interface[port_channel_num] = []
      end
      port_channel_hash = { interface_name.first.first => mode }
      port_channels_per_interface[port_channel_num] << port_channel_hash
    end
    port_channels_per_interface
  end

  def self.instances_from_cli(output)
    interface_hash = portchannel_interface_names_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      # Convert 10/100/1000 speed values to modelled 10m/100m/1g
      unless new_instance[:speed].nil?
        new_instance[:speed] = PuppetX::CiscoIOS::Utility.convert_speed_int_to_modelled_value(new_instance[:speed])
      end

      channel_number = new_instance[:name].gsub(%r{Port-channel}, '')
      if interface_hash[channel_number]
        new_instance[:interfaces] = []
        interface_hash[channel_number].each do |interface_mode|
          interface_mode.each do |interface_name, mode|
            new_instance[:interfaces] << interface_name
            if new_instance[:mode].nil?
              new_instance[:mode] = mode
            elsif new_instance[:mode] != mode
              raise "Multiple modes per PortChannel #{channel_number} found - original value #{new_instance[:mode]}, new value #{mode}"
            end
          end
        end
      end
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance[:ensure] = 'present'
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.interface_commands_from_instance(property_hash, delete = false)
    raise 'interface requires mode to be set if setting port channel' if !property_hash[:interfaces].nil? && property_hash[:mode].nil?
    command_line = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'set_interfaces')
    command_line = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command_line, 'name', property_hash[:name].gsub(%r{Port-channel}, ''), false)
    command_line = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command_line, 'mode', property_hash[:mode], false)
    command_line = if delete
                     PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command_line, 'state', 'no ', false)
                   else
                     PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command_line, 'state', '', false)
                   end
    command_line
  end

  def self.commands_from_instance(property_hash)
    if property_hash[:ensure].to_s == 'absent'
      return_commands = []
      default_command = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'delete_command_default')
      default_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(default_command, 'name', property_hash[:name], false)
      return_commands << default_command
      no_command = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'delete_command_no')
      no_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(no_command, 'name', property_hash[:name], false)
      return_commands << no_command
      return return_commands
    end

    # Convert 10m/100m/1g speed values to modelled 10/100/1000 on Cisco 6500
    unless property_hash[:speed].nil?
      property_hash[:speed] = PuppetX::CiscoIOS::Utility.convert_modelled_speed_value_to_int(property_hash[:speed])
    end
    PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
  end

  def commands_hash
    Puppet::Provider::PortChannel::PortChannel.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::PortChannel::PortChannel.instances_from_cli(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      is = change[:is]
      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?
      if is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name, is)
        end
      else
        context.updating(name) do
          update(context, name, is, should)
        end
      end
    end
  end

  def update(context, name, is, should)
    unless should[:ensure].to_s == 'absent'
      if is.nil?
        new_interfaces = should[:interfaces]
        remove_interfaces = []
      else
        is[:interfaces] = [] if is[:interfaces].nil?
        should[:interfaces] = [] if should[:interfaces].nil?
        new_interfaces = should[:interfaces] - is[:interfaces]
        remove_interfaces = is[:interfaces] - should[:interfaces]
      end

      new_interfaces.each do |interface|
        interface_commands_to_run = Puppet::Provider::PortChannel::PortChannel.interface_commands_from_instance(should)
        context.device.run_command_interface_mode(interface, interface_commands_to_run)
      end
      remove_interfaces.each do |interface|
        interface_commands_to_run = Puppet::Provider::PortChannel::PortChannel.interface_commands_from_instance(should, true)
        context.device.run_command_interface_mode(interface, interface_commands_to_run)
      end
    end
    array_of_commands_to_run = Puppet::Provider::PortChannel::PortChannel.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_interface_mode(name, command)
    end
  end

  def delete(context, name, is)
    should = { name: name, ensure: 'absent' }
    update(context, name, is, should)
  end
end

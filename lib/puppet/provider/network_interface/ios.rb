require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Network Interface Puppet Provider for Cisco IOS devices
class Puppet::Provider::NetworkInterface::NetworkInterface
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      # Convert 10/100/1000 speed values to modelled 10m/100m/1g
      if new_instance[:speed] && !new_instance[:speed].nil?
        new_instance[:speed] = PuppetX::CiscoIOS::Utility.convert_speed_int_to_modelled_value(new_instance[:speed])
      end
      mtu_value = new_instance[:mtu]
      mtu = if mtu_value.nil?
              mtu_value
            else
              mtu_value.to_i
            end
      new_instance[:mtu] = mtu
      new_instance[:enable] = if new_instance[:enable].nil?
                                true
                              else
                                false
                              end
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_instance(property_hash)
    # Convert 10m/100m/1g speed values to modelled 10/100/1000 on Cisco 6500
    unless property_hash[:speed].nil?
      property_hash[:speed] = PuppetX::CiscoIOS::Utility.convert_modelled_speed_value_to_int(property_hash[:speed])
    end
    # Enable attribute is strange: enable == 'no shutdown' and disable == 'shutdown'
    property_hash[:enable] = if property_hash[:enable]
                               'no'
                             else
                               ''
                             end
    PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
  end

  def commands_hash
    Puppet::Provider::NetworkInterface::NetworkInterface.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NetworkInterface::NetworkInterface.instances_from_cli(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      context.updating(name) do
        update(context, name, should)
      end
    end
  end

  def update(_context, name, should)
    array_of_commands_to_run = Puppet::Provider::NetworkInterface::NetworkInterface.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_interface_mode(name, command)
    end
  end
end

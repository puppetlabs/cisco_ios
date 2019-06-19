require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:network_interface).provide(:ios) do
  end

  # Network Interface Puppet Provider for Cisco IOS devices
  class Puppet::Provider::NetworkInterface::CiscoIos
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def canonicalize(_context, resources)
      new_resources = []
      resources.each do |r|
        new_resources << PuppetX::CiscoIOS::Utility.device_safe_instance(r, commands_hash)
      end
      new_resources
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
        new_instance[:enable] = new_instance[:enable].nil? ? true : false
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
      property_hash[:enable] = (property_hash[:enable]) ? 'no' : ''
      PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
    end

    def commands_hash
      Puppet::Provider::NetworkInterface::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::NetworkInterface::CiscoIos.instances_from_cli(output)
      instances = PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
      # Retrieve status for all the interfaces
      status_output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_speed_status'))

      if status_output =~ %r{% Unrecognized command}
        instances
      else
        data = PuppetX::CiscoIOS::Utility.read_table(status_output)

        instance_data = []
        data.each do |interface|
          instance_data << {
            name: shorthand_to_full(interface['Port']),
            # Convert 10/100/1000 speed values to modelled 10m/100m/1g
            speed: (interface['Speed'][0] == 'a') ? 'auto' : PuppetX::CiscoIOS::Utility.convert_speed_int_to_modelled_value(interface['Speed']),
            duplex: (interface['Duplex'][0] == 'a') ? 'auto' : interface['Duplex'],
          }
        end

        # combine the two arrays
        (instances + instance_data).group_by { |interface| interface[:name] }.map { |_, values| values.inject({}, :merge) }
      end
    end

    def shorthand_to_full(name)
      shorthand = name[%r{(^[a-zA-Z]{2})}, 1]
      port = name[%r{^[a-zA-Z]{2}(.*$)}, 1]
      full = case shorthand
             when 'Gi'
               'GigabitEthernet'
             when 'Te'
               'TenGigabitEthernet'
             when 'Fa'
               'FastEthernet'
             when 'Po'
               'Port-channel'
             end
      full + port
    end

    def set(context, changes)
      changes.each do |name, change|
        should = change[:should]
        context.updating(name) do
          update(context, name, should)
        end
      end
    end

    def update(context, name, should)
      array_of_commands_to_run = Puppet::Provider::NetworkInterface::CiscoIos.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_interface_mode(name, command)
      end
    end
  end
end

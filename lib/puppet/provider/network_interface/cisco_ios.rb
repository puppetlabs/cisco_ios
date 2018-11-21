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
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
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
      Puppet::Provider::NetworkInterface::CiscoIos.commands_hash
    end

    def test_for_interface_status_cli(context, instance)
      return false if instance.nil?
      command_to_use = PuppetX::CiscoIOS::Utility.get_interface_status_command(commands_hash, instance[:name])
      command_array = command_to_use.split

      built_command = ''
      command_array.each do |command_token|
        # Try each token of the command to ensure we can send
        # eg. 'show ? , show interfaces ? show interfaces x ? show interfaces x status ?'
        built_command = "#{built_command} #{command_token}"
        # Follow each command with a CTRL+C to clear the command line to ensure we don't send a newline where it is treated as a command
        test_command = "#{built_command} ?"
        test_command += ("\b" * test_command.length)
        test_for_new_cli_output = context.device.run_command_enable_mode(test_command)
        if test_for_new_cli_output =~ %r{% Unrecognized command}
          return false
        end
      end
      true
    end

    def get(context, _names = nil)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      instances = Puppet::Provider::NetworkInterface::CiscoIos.instances_from_cli(output)
      new_instances = []
      if test_for_interface_status_cli(context, instances.first)
        instances.each do |instance|
          status_output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_interface_status_command(commands_hash, instance[:name]))
          data = PuppetX::CiscoIOS::Utility.read_table(status_output)

          if instance[:speed].nil?
            instance[:speed] = PuppetX::CiscoIOS::Utility.get_speed_value_from_table_data(data, 'Speed')
            # Convert 10/100/1000 speed values to modelled 10m/100m/1g
            if instance[:speed] && !instance[:speed].nil?
              instance[:speed] = PuppetX::CiscoIOS::Utility.convert_speed_int_to_modelled_value(instance[:speed])
            end
          end
          if instance[:duplex].nil?
            instance[:duplex] = PuppetX::CiscoIOS::Utility.get_speed_value_from_table_data(data, 'Duplex')
          end
          instance.delete_if { |_k, v| v.nil? }
          new_instances << instance
        end
        new_instances
      else
        instances
      end
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
        context.device.run_command_interface_mode(name, command)
      end
    end
  end
end

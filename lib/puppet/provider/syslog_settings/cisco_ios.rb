require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:syslog_settings).provide(:ios) do
  end

  # Utility functions to parse out the Interface
  class Puppet::Provider::SyslogSettings::CiscoIos
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
      new_instance[:name] = 'default'
      # convert cli values to puppet values
      new_instance[:console] = PuppetX::CiscoIOS::Utility.convert_level_name_to_int(new_instance[:console])
      new_instance[:monitor] = PuppetX::CiscoIOS::Utility.convert_level_name_to_int(new_instance[:monitor])
      new_instance[:enable] = PuppetX::CiscoIOS::Utility.convert_no_to_boolean(new_instance[:enable])
      new_instance[:source_interface] = [].push(new_instance[:source_interface]) if new_instance[:source_interface].is_a?(String)
      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
      new_instance_fields
    end

    def self.commands_from_is_should(is, should)
      attributes_that_differ = (should.to_a - is.to_a).to_h
      # Change enable to a no / nostring
      attributes_that_differ[:enable] = PuppetX::CiscoIOS::Utility.convert_enable_to_string(attributes_that_differ[:enable]) unless attributes_that_differ[:enable].nil?
      # cisco_ios only supports a single source interface
      attributes_that_differ[:source_interface] = attributes_that_differ[:source_interface].first unless attributes_that_differ[:source_interface].nil?
      array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(attributes_that_differ, commands_hash)
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::SyslogSettings::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::SyslogSettings::CiscoIos.instances_from_cli(output)
    end

    def set(context, changes)
      changes.each do |name, change|
        is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
        should = change[:should]

        context.updating(name) do
          update(context, name, is, should)
        end
      end
    end

    def update(context, _name, is, should)
      array_of_commands_to_run = Puppet::Provider::SyslogSettings::CiscoIos.commands_from_is_should(is, should)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end

    def create(context, _name, _should); end

    def delete(context, _name); end

    def canonicalize(_context, resources)
      resources
    end
  end
end

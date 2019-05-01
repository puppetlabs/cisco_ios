require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:snmp_notification).provide(:ios) do
  end

  # SNMP Notification Puppet Provider for Cisco IOS devices
  class Puppet::Provider::SnmpNotification::CiscoIos
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      commands = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands)
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

    def commands_hash
      Puppet::Provider::SnmpNotification::CiscoIos.commands_hash
    end

    def self.commands_from_instance(property_hash)
      commands_array = []
      command = PuppetX::CiscoIOS::Utility.set_values(property_hash, commands_hash)
      command = command.to_s.gsub(%r{^snmp-server}, 'no snmp-server')
      command = command.to_s.gsub(%r{true }, '')
      commands_array.push(command)
      commands_array
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::SnmpNotification::CiscoIos.instances_from_cli(output)
      PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
    end

    def set(context, changes)
      changes.each do |name, change|
        should = change[:should]
        context.updating(name) do
          update(context, name, should)
        end
      end
    end

    def update(context, _name, should)
      array_of_commands_to_run = Puppet::Provider::SnmpNotification::CiscoIos.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    alias create update

    def delete(context, _name, should); end

    def canonicalize(_context, resources)
      resources
    end
  end
end

require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:network_snmp).provide(:ios) do
  end

  # Network SNMP Puppet Provider for Cisco IOS devices
  class Puppet::Provider::NetworkSnmp::CiscoIos
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
      new_instance[:name] = 'default'
      new_instance.delete_if { |_k, v| v.nil? }
      # if only name is populated, snmp is disabled
      new_instance[:enable] = new_instance.size != 1
      new_instance_fields << new_instance
      new_instance_fields
    end

    def self.commands_from_instance(property_hash)
      commands_array = []
      if property_hash[:enable] == false
        # when disabling, dont change the other attributes
        property_hash = { enable: false }
      else
        # we dont enable we only disable
        property_hash.delete(:enable)
      end
      commands_array += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
      commands_array
    end

    def commands_hash
      Puppet::Provider::NetworkSnmp::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::NetworkSnmp::CiscoIos.instances_from_cli(output)
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
      array_of_commands_to_run = Puppet::Provider::NetworkSnmp::CiscoIos.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    def canonicalize(_context, resources)
      resources
    end
  end
end

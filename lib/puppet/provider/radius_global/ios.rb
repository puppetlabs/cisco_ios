require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:radius_global).provide(:ios) do
  end

  # Configure the domain name of the device
  class Puppet::Provider::RadiusGlobal::RadiusGlobal
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
      new_instance[:name] = 'default'
      new_instance[:source_interface] = [].push(new_instance[:source_interface]) if new_instance[:source_interface].is_a?(String)
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
      new_instance_fields
    end

    def self.commands_from_instance(instance)
      commands = []
      # if key exists but not key_format, we need to fail
      raise 'radius_global requires key_format to be set if setting key' if !instance[:key].nil? && instance[:key_format].nil?
      unless instance[:key].nil?
        # build a single command for key_format + key
        if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'key') && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'key_format')
          command = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, 'key', 'set_value')
          command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command, 'key_format', instance[:key_format], false)
          command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command, 'key', instance[:key], false)
          commands.push(command)
        end
        # remove key and key_format, so we dont add twice
        instance.delete(:key_format)
        instance.delete(:key)
      end
      raise 'radius_global only accepts a single source_interface' if !instance[:source_interface].nil? && instance[:source_interface].size != 1
      instance[:source_interface] = instance[:source_interface].first unless instance[:source_interface].nil?
      commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      commands
    end

    def commands_hash
      Puppet::Provider::RadiusGlobal::RadiusGlobal.commands_hash
    end

    def get(context)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::RadiusGlobal::RadiusGlobal.instances_from_cli(output)
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
      array_of_commands_to_run = Puppet::Provider::RadiusGlobal::RadiusGlobal.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end
  end
end

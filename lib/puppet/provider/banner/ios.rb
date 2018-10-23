require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:banner).provide(:ios) do
  end

  # Configure the device banners
  class Puppet::Provider::Banner::Banner
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
      new_instance[:name] = 'default'
      if new_instance[:motd].nil?
        new_instance[:motd] = 'unset'
      end
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
      new_instance_fields
    end

    def self.commands_from_instance(instance)
      commands = []
      prefix = ''
      if instance[:motd] == 'unset'
        prefix = 'no '
        instance[:motd] = ''
      end
      command_array = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      command_array.each do |command|
        command = "#{prefix}#{command}"
        commands << command
      end
      commands
    end

    def commands_hash
      Puppet::Provider::Banner::Banner.commands_hash
    end

    def get(context, _names = nil)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::Banner::Banner.instances_from_cli(output)
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
      array_of_commands_to_run = Puppet::Provider::Banner::Banner.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end

    def canonicalize(_context, resources)
      resources
    end
  end
end

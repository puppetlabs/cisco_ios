require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Utility functions to parse out the Interface
  class Puppet::Provider::IosCef::CiscoIos
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
      new_instance[:name] = 'default'
      new_instance[:distributed] = (new_instance[:distributed]) ? false : true
      new_instance[:optimize_resolution] = (new_instance[:optimize_resolution]) ? false : true
      if new_instance[:load_sharing] && new_instance[:load_sharing] =~ %r{ }
        new_instance[:load_sharing] = new_instance[:load_sharing].split(' ')
      elsif !new_instance[:load_sharing]
        new_instance[:load_sharing] = 'universal'
      end
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
      new_instance_fields
    end

    def self.commands_from_instance(instance)
      instance[:distributed] = 'unset' if instance[:distributed] == false
      instance[:optimize_resolution] = 'unset' if instance[:optimize_resolution] == false
      instance[:load_sharing] = instance[:load_sharing].join(' ') if instance[:load_sharing].class == Array
      array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::IosCef::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::IosCef::CiscoIos.instances_from_cli(output)
      PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
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

    def update(context, _name, _is, should)
      array_of_commands_to_run = Puppet::Provider::IosCef::CiscoIos.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    def create(context, _name, _should); end

    def delete(context, _name); end

    def canonicalize(_context, resources)
      resources
    end
  end
end

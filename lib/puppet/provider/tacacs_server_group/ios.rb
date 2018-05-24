require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:tacacs_server_group).provide(:ios) do
  end

  # Tacacs Server Group Puppet Provider for Cisco IOS devices
  class Puppet::Provider::TacacsServerGroup::TacacsServerGroup
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
        new_instance[:servers] = [].push(new_instance[:servers]) if new_instance[:servers].is_a?(String)
        new_instance[:ensure] = 'present'
        new_instance.delete_if { |_k, v| v.nil? }
        new_instance_fields << new_instance
      end
      new_instance_fields
    end

    def self.commands_from_instance(instance)
      commands_array = []
      # servers are special
      instance[:servers] = nil unless instance[:servers].nil?
      command = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
      commands_array.push(command)
      commands_array
    end

    def self.commands_from_is_should(is, should)
      array_of_commands = []
      array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:servers], should[:servers], 'servers')
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::TacacsServerGroup::TacacsServerGroup.commands_hash
    end

    def get(context)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::TacacsServerGroup::TacacsServerGroup.instances_from_cli(output)
    end

    def set(context, changes)
      changes.each do |name, change|
        is = if context.feature_support?('simple_get_filter')
               change.key?(:is) ? change[:is] : (get(context, [name]) || []).find { |r| r[:name] == name }
             else
               change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }
             end
        should = change[:should]
        is = { name: name, ensure: 'absent' } if is.nil?
        should = { name: name, ensure: 'absent' } if should.nil?
        if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
          context.creating(name) do
            create(context, name, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          context.updating(name) do
            update(context, name, is, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
          context.deleting(name) do
            delete(context, name)
          end
        end
      end
    end

    def update(context, _name, is, should)
      array_of_commands_to_run = Puppet::Provider::TacacsServerGroup::TacacsServerGroup.commands_from_is_should(is, should)
      array_of_commands_to_run.each do |command|
        context.device.run_command_tacacs_server_group_mode(should[:name], command)
      end
    end

    def delete(context, name)
      delete_hash = { name: name, ensure: 'absent' }
      array_of_commands_to_run = Puppet::Provider::TacacsServerGroup::TacacsServerGroup.commands_from_instance(delete_hash)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end

    def create(context, name, should)
      # make a clone of should, because commands_from_instance modifys the hash
      instance = should.clone
      array_of_commands_to_run = Puppet::Provider::TacacsServerGroup::TacacsServerGroup.commands_from_instance(instance)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
      is = { name: name, ensure: 'present' }
      update(context, name, is, should)
    end
  end
end

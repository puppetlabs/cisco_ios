require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Tacacs Server Group Puppet Provider for Cisco IOS devices
  class Puppet::Provider::TacacsServerGroup::CiscoIos
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
        new_instance[:servers] = [].push(new_instance[:servers]) if new_instance[:servers].is_a?(String)
        new_instance[:ensure] = 'present'
        new_instance[:source_interface] = 'unset' unless new_instance[:source_interface]
        new_instance[:vrf] = 'unset' unless new_instance[:vrf]
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

      if should[:source_interface] == 'unset' && is[:source_interface] && is[:source_interface] != 'unset'
        array_of_commands << "no #{PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ source_interface: is[:source_interface] }, commands_hash)[0]}"
      elsif should[:source_interface] && should[:source_interface] != 'unset' && should[:source_interface] != is[:source_interface]
        array_of_commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ source_interface: should[:source_interface] }, commands_hash)
      end

      if should[:vrf] == 'unset' && is[:vrf] && is[:vrf] != 'unset'
        array_of_commands << "no #{PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ vrf: is[:vrf] }, commands_hash)[0]}"
      elsif should[:vrf] && should[:vrf] != 'unset' && should[:vrf] != is[:vrf]
        array_of_commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ vrf: should[:vrf] }, commands_hash)
      end

      array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:servers], should[:servers], 'servers')
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::TacacsServerGroup::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::TacacsServerGroup::CiscoIos.instances_from_cli(output)
      PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
    end

    def set(context, changes)
      changes.each do |name, change|
        is = if context.type.feature?('simple_get_filter')
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
      array_of_commands_to_run = Puppet::Provider::TacacsServerGroup::CiscoIos.commands_from_is_should(is, should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_tacacs_server_group_mode(should[:name], command)
      end
    end

    def delete(context, name)
      delete_hash = { name: name, ensure: 'absent' }
      array_of_commands_to_run = Puppet::Provider::TacacsServerGroup::CiscoIos.commands_from_instance(delete_hash)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    def create(context, name, should)
      # make a clone of should, because commands_from_instance modifys the hash
      instance = should.clone
      array_of_commands_to_run = Puppet::Provider::TacacsServerGroup::CiscoIos.commands_from_instance(instance)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
      is = { name: name, ensure: 'present', vrf: 'unset', source_interface: 'unset' }
      update(context, name, is, should)
    end

    def canonicalize(_context, resources)
      resources.each do |resource|
        resource[:servers] = resource[:servers].sort if resource[:servers]
      end
      resources
    end
  end
end

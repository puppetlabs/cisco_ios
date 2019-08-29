require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require 'puppet/resource_api/simple_provider'
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # NTP Server Puppet Provider for Cisco IOS devices
  class Puppet::Provider::NtpServer::CiscoIos
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
        new_instance[:ensure] = 'present'
        new_instance[:prefer] = !new_instance[:prefer].nil? # true if the keyword exists
        new_instance.delete_if { |_k, v| v.nil? }

        new_instance_fields << new_instance
      end
      new_instance_fields
    end

    def self.commands_from_instance(property_hash)
      commands_array = []
      command = PuppetX::CiscoIOS::Utility.set_values(property_hash, commands_hash)
      # special adjustments
      command = command.to_s.gsub(%r{name }, '')
      command = command.to_s.gsub(%r{source_interface}, 'source')
      command = command.to_s.gsub(%r{prefer true}, 'prefer')
      commands_array.push(command)
      commands_array
    end

    def commands_hash
      Puppet::Provider::NtpServer::CiscoIos.commands_hash
    end

    def set(context, changes)
      changes.each do |name, change|
        is = if context.type.feature?('simple_get_filter')
               change.key?(:is) ? change[:is] : (get(context, [name]) || []).find { |r| r[:name] == name }
             else
               change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }
             end
        context.type.check_schema(is) unless change.key?(:is)

        should = change[:should]

        raise 'SimpleProvider cannot be used with a Type that is not ensurable' unless context.type.ensurable?

        is = SimpleProvider.create_absent(:name, name) if is.nil?
        should = { name: name, ensure: 'absent', vrf: should[:vrf] } if should.nil?

        if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
          context.creating(name) do
            create(context, name, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          context.updating(name) do
            update(context, name, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
          context.deleting(name) do
            delete(context, name, should)
          end
        end
      end
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::NtpServer::CiscoIos.instances_from_cli(output)
      PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
    end

    def delete(context, name, should)
      clear_hash = { name: name, ensure: 'absent', vrf: should[:vrf] }
      array_of_commands_to_run = Puppet::Provider::NtpServer::CiscoIos.commands_from_instance(clear_hash)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    def update(context, _name, should)
      array_of_commands_to_run = Puppet::Provider::NtpServer::CiscoIos.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end
    alias create update

    def canonicalize(_context, resources)
      resources
    end
  end
end

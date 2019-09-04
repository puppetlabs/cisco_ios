require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # NTP Config Puppet Provider for Cisco IOS devices
  class Puppet::Provider::NtpConfig::CiscoIos
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
      new_instance[:name] = 'default'
      new_instance[:authenticate] = !new_instance[:authenticate].nil?
      unless new_instance[:trusted_key].nil?
        new_instance[:trusted_key] = [].push(new_instance[:trusted_key]) if new_instance[:trusted_key].is_a?(String)
        new_instance[:trusted_key] = new_instance[:trusted_key].map(&:to_i)
        new_instance[:trusted_key] = new_instance[:trusted_key].sort
      end
      new_instance[:trusted_key] = [] if new_instance[:trusted_key].nil?
      new_instance[:source_interface] = (new_instance[:source_interface]) ? new_instance[:source_interface] : 'unset'
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
      new_instance_fields
    end

    def self.commands_from_is_should(is, should)
      array_of_commands = []
      # build up the trusted keys commands
      array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:trusted_key], should[:trusted_key], 'trusted_key')
      should.delete(:trusted_key)
      # build up the rest of the commands
      should.delete(:name)
      should[:authenticate] = 'unset' unless should[:authenticate]
      array_of_commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(should, commands_hash)
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::NtpConfig::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::NtpConfig::CiscoIos.instances_from_cli(output)
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

    def update(context, _name, is, should)
      array_of_commands_to_run = Puppet::Provider::NtpConfig::CiscoIos.commands_from_is_should(is, should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    def canonicalize(_context, resources)
      resources.each do |resource|
        resource[:trusted_keys] = resource[:trusted_keys].sort if resource[:trusted_keys]
      end
    end
  end
end

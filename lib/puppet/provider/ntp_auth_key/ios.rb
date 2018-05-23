require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require 'puppet/resource_api/simple_provider'
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:ntp_auth_key).provide(:ios) do
  end

  # NTP Authentication Key Puppet Provider for Cisco IOS devices
  class Puppet::Provider::NtpAuthKey::NtpAuthKey < Puppet::ResourceApi::SimpleProvider
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, @commands_hash)
        new_instance[:ensure] = 'present'
        new_instance.delete_if { |_k, v| v.nil? }

        new_instance_fields << new_instance
      end
      new_instance_fields
    end

    def self.commands_from_instance(property_hash)
      commands_array = []
      commands_array.push(PuppetX::CiscoIOS::Utility.set_values(property_hash, commands_hash))
      commands_array
    end

    def commands_hash
      Puppet::Provider::NtpAuthKey::NtpAuthKey.commands_hash
    end

    def get(context)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::NtpAuthKey::NtpAuthKey.instances_from_cli(output)
    end

    def create(context, _name, should)
      array_of_commands_to_run = Puppet::Provider::NtpAuthKey::NtpAuthKey.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end

    alias update create

    def delete(context, name)
      clear_hash = { name: name, ensure: 'absent' }
      array_of_commands_to_run = Puppet::Provider::NtpAuthKey::NtpAuthKey.commands_from_instance(clear_hash)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end
  end
end

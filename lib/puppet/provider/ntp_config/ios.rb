require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# NTP Config Puppet Provider for Cisco IOS devices
class Puppet::Provider::NtpConfig::NtpConfig
  def self.commands_hash
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = Puppet::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance[:authenticate] = !new_instance[:authenticate].nil?
    new_instance[:trusted_key] = Puppet::Utility.convert_ntp_config_trusted_key_to_cli(new_instance[:trusted_key])
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    parent_device = Puppet::Utility.parent_device(commands_hash)
    array_of_commands = []
    array_of_commands.push(Puppet::Utility.convert_ntp_config_authenticate(commands_hash, should, parent_device))
    array_of_commands.push(Puppet::Utility.convert_ntp_config_source_interface(commands_hash, should, parent_device))
    array_of_commands.push(*Puppet::Utility.convert_ntp_config_keys(commands_hash, is, should, parent_device))
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::NtpConfig::NtpConfig.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(Puppet::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NtpConfig::NtpConfig.instances_from_cli(output)
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

  def update(_context, _name, is, should)
    array_of_commands_to_run = Puppet::Provider::NtpConfig::NtpConfig.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(command)
    end
  end

  def create(_context, _name, _should); end

  def delete(_context, _name); end
end

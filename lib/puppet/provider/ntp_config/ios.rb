require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# NTP Config Puppet Provider for Cisco IOS devices
class Puppet::Provider::NtpConfig::NtpConfig
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance[:authenticate] = !new_instance[:authenticate].nil?
    new_instance[:trusted_key] = PuppetX::CiscoIOS::Utility.convert_ntp_config_trusted_key_to_cli(new_instance[:trusted_key])
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    parent_device = PuppetX::CiscoIOS::Utility.parent_device(commands_hash)
    array_of_commands = []
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'authenticate')
      array_of_commands.push(PuppetX::CiscoIOS::Utility.convert_ntp_config_authenticate(commands_hash, should, parent_device))
    end
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'source_interface')
      array_of_commands.push(PuppetX::CiscoIOS::Utility.convert_source_interface(commands_hash, should, parent_device))
    end
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'trusted_key')
      array_of_commands.push(*PuppetX::CiscoIOS::Utility.convert_ntp_config_keys(commands_hash, is, should, parent_device))
    end
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::NtpConfig::NtpConfig.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
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

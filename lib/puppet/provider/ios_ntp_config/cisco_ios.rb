require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# pre-declare the module to load the provider without error
module Puppet::Provider::NtpConfig; end
require_relative '../ntp_config/cisco_ios'

# NTP Config Puppet Provider for Cisco IOS devices
class Puppet::Provider::IosNtpConfig::CiscoIos
  def self.commands_hash
    local_commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    ntp_config_commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/../ntp_config/command.yaml')
    @commands_hash = local_commands_hash.merge(ntp_config_commands_hash) { |_key, oldval, newval| (oldval.to_a + newval.to_a).to_h }
    @commands_hash
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance[:update_calendar] = (new_instance[:update_calendar]) ? true : false
    new_instance = new_instance.merge(Puppet::Provider::NtpConfig::CiscoIos.instances_from_cli(output).first)
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    array_of_commands = []
    should.delete(:name)
    should[:update_calendar] = 'unset' unless should[:update_calendar]
    array_of_commands += Puppet::Provider::NtpConfig::CiscoIos.commands_from_is_should(is, should)
    # build up the rest of the commands
    should.delete(:authenticate)
    should.delete(:source_interface)
    array_of_commands.concat(PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(should, commands_hash))
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::IosNtpConfig::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosNtpConfig::CiscoIos.instances_from_cli(output)
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
    array_of_commands_to_run = Puppet::Provider::IosNtpConfig::CiscoIos.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def canonicalize(_context, resources)
    resources
  end
end

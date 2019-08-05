require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# NTP Access Group Puppet Provider for Cisco IOS devices
class Puppet::Provider::IosNtpAccessGroup::CiscoIos < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ipv6_access_group] = (new_instance[:ipv6_access_group]) ? true : false
      new_instance[:ensure] = 'present'
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    commands = []
    if instance[:name].casecmp('none').zero?
      instance[:name] = nil
    end
    instance[:access_group_type] = 'ipv6 ' + instance[:access_group_type] if instance[:ipv6_access_group]
    command = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
    if instance[:ensure].to_s == 'absent'
      command = 'no ' + command
    end
    commands << command
    puts commands
    commands
  end

  def commands_hash
    Puppet::Provider::IosNtpAccessGroup::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosNtpAccessGroup::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def create(context, name, should)
    create_hash = { name: name, ensure: 'present', access_group_type: should[:access_group_type], ipv6_access_group: should[:ipv6_access_group] }
    array_of_commands_to_run = Puppet::Provider::IosNtpAccessGroup::CiscoIos.commands_from_instance(create_hash)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
    context.updating(name) do
      update(context, name, should)
    end
  end

  def update(context, _name, should)
    array_of_commands_to_run = Puppet::Provider::IosNtpAccessGroup::CiscoIos.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def delete(context, name)
    is = (get(context) || []).find { |key| key[:name] == name }
    clear_hash = { name: name, ensure: 'absent', access_group_type: is[:access_group_type], ipv6_access_group: is[:ipv6_access_group] }
    array_of_commands_to_run = Puppet::Provider::IosNtpAccessGroup::CiscoIos.commands_from_instance(clear_hash)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def canonicalize(_context, resources)
    resources
  end
end

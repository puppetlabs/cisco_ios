require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure a radius_server on the device
class Puppet::Provider::RadiusServer::RadiusServer < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = 'present'
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    commands = []
    # if key exists but not key_format, we need to fail
    raise 'radius_global requires key_format to be set if setting key' if !instance[:key].nil? && instance[:key_format].nil?
    command = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
    # rename attribute names to cisco keywords
    command  = command.to_s.gsub(%r{auth_port}, 'auth-port')
    command  = command.to_s.gsub(%r{acct_port}, 'acct-port')
    command  = command.to_s.gsub(%r{retransmit_count}, 'retransmit')
    command  = command.to_s.gsub(%r{key_format}, 'key')
    commands.push(command)
    commands
  end

  def commands_hash
    Puppet::Provider::RadiusServer::RadiusServer.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::RadiusServer::RadiusServer.instances_from_cli(output)
  end

  def update(_context, _name, should)
    array_of_commands_to_run = Puppet::Provider::RadiusServer::RadiusServer.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(command)
    end
  end

  def delete(_context, name)
    clear_hash = { name: name, ensure: 'absent' }
    array_of_commands_to_run = Puppet::Provider::RadiusServer::RadiusServer.commands_from_instance(clear_hash)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(command)
    end
  end
  alias create update
end

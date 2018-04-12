require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# NTP Server Puppet Provider for Cisco IOS devices
class Puppet::Provider::NtpServer::NtpServer < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
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
    Puppet::Provider::NtpServer::NtpServer.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NtpServer::NtpServer.instances_from_cli(output)
  end

  def delete(_context, name)
    clear_hash = { name: name, ensure: 'absent' }
    array_of_commands_to_run = Puppet::Provider::NtpServer::NtpServer.commands_from_instance(clear_hash)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(command)
    end
  end

  def update(_context, _name, should)
    array_of_commands_to_run = Puppet::Provider::NtpServer::NtpServer.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(command)
    end
  end
  alias create update
end

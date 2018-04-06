require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Name server Puppet Provider for Cisco IOS devices
class Puppet::Provider::NameServer::NameServer < Puppet::ResourceApi::SimpleProvider
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

  def self.command_from_instance(instance)
    PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
  end

  def commands_hash
    Puppet::Provider::NameServer::NameServer.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NameServer::NameServer.instances_from_cli(output)
  end

  def update(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::NameServer::NameServer.command_from_instance(should))
  end

  def delete(_context, name)
    clear_hash = { name: name, ensure: 'absent' }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::NameServer::NameServer.command_from_instance(clear_hash))
  end
  alias create update
end

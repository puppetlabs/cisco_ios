require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'

# SNMP Community Puppet Provider for Cisco IOS devices
class Puppet::Provider::SnmpCommunity::SnmpCommunity < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{Puppet::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = Puppet::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = :present
      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.command_from_instance(property_hash)
    command = Puppet::Utility.set_values(property_hash, commands_hash)
    command
  end

  def commands_hash
    Puppet::Provider::SnmpCommunity::SnmpCommunity.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(Puppet::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::SnmpCommunity::SnmpCommunity.instances_from_cli(output)
  end

  def update(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpCommunity::SnmpCommunity.command_from_instance(should))
  end

  alias create update
  alias delete update
end

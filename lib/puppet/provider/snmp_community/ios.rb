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
    output.scan(%r{#{commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      new_instance = Puppet::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = :present
      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.command_from_instance(property_hash)
    set_command = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')['default']['set_values']
    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<name>}, property_hash[:name])
    # rubocop:disable Style/TernaryParentheses
    set_command = set_command.to_s.gsub(%r{<group>}, property_hash[:group] ? " #{property_hash[:group]}" : '')
    set_command = set_command.to_s.gsub(%r{<acl>}, property_hash[:acl] ? " #{property_hash[:acl]}" : '')
    # rubocop:enable Style/TernaryParentheses
    set_command.strip!
    set_command.squeeze(' ') unless set_command.nil?
  end

  def commands_hash
    Puppet::Provider::SnmpCommunity::SnmpCommunity.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(commands_hash['default']['get_values'])
    return [] if output.nil?
    Puppet::Provider::SnmpCommunity::SnmpCommunity.instances_from_cli(output)
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpCommunity::SnmpCommunity.commands_from_instance(should))
  end

  alias update create
  alias delete create
end

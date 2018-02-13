require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'

# SNMP Community Puppet Provider for Cisco IOS devices
class Puppet::Provider::SnmpCommunity::SnmpCommunity < Puppet::ResourceApi::SimpleProvider
  def initialize
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def parse(output)
    new_instance_fields = []
    output.scan(%r{#{@commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      name_field = raw_instance_fields.match(%r{#{@commands_hash['default']['name']['get_value']}})
      group_field = raw_instance_fields.match(%r{#{@commands_hash['default']['group']['get_value']}})
      acl_field = raw_instance_fields.match(%r{#{@commands_hash['default']['acl']['get_value']}})

      new_instance = { name:  name_field ? name_field[:name] : nil,
                       ensure: :present,
                       group: group_field ? group_field[:group] : nil,
                       acl: acl_field ? acl_field[:acl] : nil }

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def config_command(property_hash)
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

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(@commands_hash['default']['get_values'])
    return [] if output.nil?
    parse(output)
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end

  def update(_context, _name, _is, should)
    # perform a delete on current, then add
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end

  def delete(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end
end

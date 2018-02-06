require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# SNMP Notification Receiver Puppet Provider for Cisco IOS devices
class Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver < Puppet::ResourceApi::SimpleProvider
  def initialize; end

  def parse(output)
    commands = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    new_instance_fields = []
    output.scan(%r{#{commands['default']['get_instances']}}).each do |raw_instance_fields|
      host_field = raw_instance_fields.match(%r{#{commands['default']['host']['get_value']}})
      port_field = raw_instance_fields.match(%r{#{commands['default']['port']['get_value']}})
      username_field = raw_instance_fields.match(%r{#{commands['default']['username']['get_value']}})
      version_field = raw_instance_fields.match(%r{#{commands['default']['version']['get_value']}})
      type_field = raw_instance_fields.match(%r{#{commands['default']['type']['get_value']}})
      security_field = raw_instance_fields.match(%r{#{commands['default']['security']['get_value']}})
      vrf_field = raw_instance_fields.match(%r{#{commands['default']['vrf']['get_value']}})

      name_field = ''
      name_field += host_field[:host] + ' ' if host_field
      name_field += username_field[:username] + ' ' if username_field
      name_field += vrf_field[:vrf] + ' ' if vrf_field
      name_field += port_field[:port] + ' ' if port_field
      name_field.strip!

      new_instance = { name:  name_field ? name_field : nil,
                       host: host_field ? host_field[:host] : nil,
                       ensure: :present,
                       port: port_field ? port_field[:port] : nil,
                       username: username_field ? username_field[:username] : nil,
                       version: version_field ? version_field[:version] : nil,
                       type: type_field ? type_field[:type] : nil,
                       security: security_field ? security_field[:security] : nil,
                       vrf: vrf_field ? vrf_field[:vrf] : nil }

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def config_command(property_hash)
    set_command = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')['default']['set_values']

    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<ip>}, property_hash[:host])
    # rubocop:disable Style/TernaryParentheses
    set_command = set_command.to_s.gsub(%r{<port>}, property_hash[:port] ? " udp-port #{property_hash[:port]}" : '')
    set_command = set_command.to_s.gsub(%r{<username>}, property_hash[:username] ? " #{property_hash[:username]}" : '')
    set_command = set_command.to_s.gsub(%r{<version>}, property_hash[:version] ? " version #{property_hash[:version]}" : '')
    set_command = set_command.to_s.gsub(%r{<type>}, property_hash[:type] ? " #{property_hash[:type]}" : '')
    set_command = set_command.to_s.gsub(%r{<security>}, property_hash[:security] ? " #{property_hash[:security]}" : '')
    set_command = set_command.to_s.gsub(%r{<vrf>}, property_hash[:vrf] ? " vrf #{property_hash[:vrf]}" : '')
    # rubocop:enable Style/TernaryParentheses
    set_command.strip!
    set_command.squeeze(' ') unless set_command.nil?
  end

  def get(_context)
    command = 'show running-config | section snmp-server host'
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(command)
    return [] if output.nil?
    parse(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:id] == name }
      should = change[:should]

      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name) do
          create(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name, is, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name, should)
        end
      end
    end
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end

  def update(_context, _name, is, should)
    # perform a delete on current, then add
    is[:ensure] = :absent
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(is))
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end

  def delete(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end
end

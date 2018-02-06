require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# NTP Server Puppet Provider for Cisco IOS devices
class Puppet::Provider::NtpServer::NtpServer < Puppet::ResourceApi::SimpleProvider
  def parse(output)
    new_instance_fields = []
    output.scan(%r{#{@commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      name_field = raw_instance_fields.match(%r{#{@commands_hash['default']['name']['get_value']}})
      key_field = raw_instance_fields.match(%r{#{@commands_hash['default']['key']['get_value']}})
      minpoll_field = raw_instance_fields.match(%r{#{@commands_hash['default']['minpoll']['get_value']}})
      maxpoll_field = raw_instance_fields.match(%r{#{@commands_hash['default']['maxpoll']['get_value']}})
      prefer_field = raw_instance_fields.match(%r{#{@commands_hash['default']['prefer']['get_value']}})
      source_field = raw_instance_fields.match(%r{#{@commands_hash['default']['source']['get_value']}})

      new_instance = { name: name_field ? name_field[:name] : nil,
                       ensure: :present,
                       key: key_field ? key_field[:key] : nil,
                       minpoll: minpoll_field ? minpoll_field[:minpoll] : nil,
                       maxpoll: maxpoll_field ? maxpoll_field[:maxpoll] : nil,
                       prefer: !prefer_field.nil?,
                       source_interface: source_field ? source_field[:source] : nil }

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def config_command(property_hash)
    set_command = @commands_hash['default']['set_values']
    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<ip>}, property_hash[:name])
    set_command = set_command.to_s.gsub(%r{<key>}, (property_hash[:key]) ? " key #{property_hash[:key]}" : '')
    set_command = set_command.to_s.gsub(%r{<minpoll>}, (property_hash[:minpoll]) ? " minpoll #{property_hash[:minpoll]}" : '')
    set_command = set_command.to_s.gsub(%r{<maxpoll>}, (property_hash[:maxpoll]) ? " maxpoll #{property_hash[:maxpoll]}" : '')
    set_command = set_command.to_s.gsub(%r{<source>}, (property_hash[:source_interface]) ? " source #{property_hash[:source_interface]}" : '')
    set_command.to_s.gsub(%r{<prefer>}, (property_hash[:prefer]) ? ' prefer' : '')
  end

  def initialize
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def get(_context)
    command = 'show running-config | section ntp server'
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(command)
    return [] if output.nil?
    parse(output)
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end

  alias update create

  def delete(_context, name)
    clear_hash = { name: name, ensure: :absent }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(clear_hash))
  end
end

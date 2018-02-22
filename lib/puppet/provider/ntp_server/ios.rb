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
      new_instance = Puppet::Utility.parse_resource(raw_instance_fields, @commands_hash)
      new_instance[:ensure] = :present
      new_instance[:prefer] = !new_instance[:prefer].nil?
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
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(@commands_hash['default']['get_values'])
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

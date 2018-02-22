require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# NTP Authentication Key Puppet Provider for Cisco IOS devices
class Puppet::Provider::NtpAuthKey::NtpAuthKey < Puppet::ResourceApi::SimpleProvider
  def parse(output)
    new_instance_fields = []
    output.scan(%r{#{@commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      new_instance = Puppet::Utility.parse_resource(raw_instance_fields, @commands_hash)
      new_instance[:ensure] = :present
      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def config_command(property_hash)
    set_command = @commands_hash['default']['set_values']
    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<name>}, property_hash[:name])
    set_command = set_command.to_s.gsub(%r{<algorithm>}, (property_hash[:algorithm]) ? " #{property_hash[:algorithm]}" : '')
    set_command = set_command.to_s.gsub(%r{<key>}, (property_hash[:key]) ? " #{property_hash[:key]}" : '')
    set_command.to_s.gsub(%r{<encryption_type>}, (property_hash[:encryption_type]) ? " #{property_hash[:encryption_type]}" : '')
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

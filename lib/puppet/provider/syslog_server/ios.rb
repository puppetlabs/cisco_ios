require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# Utility functions to parse out the Interface
class Puppet::Provider::SyslogServer::SyslogServer < Puppet::ResourceApi::SimpleProvider
  def parse_output(output)
    new_instance_fields = []
    output.scan(%r{#{@commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      name_value = raw_instance_fields.match(%r{#{@commands_hash['default']['name']['get_value']}})[:name]
      new_instance = { name: name_value,
                       ensure: :present }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def config_command(property_hash)
    set_command = @commands_hash['default']['set_values']
    set_command = set_command.to_s.gsub(%r{<name>}, property_hash[:name])
    set_command = "no #{set_command}" if property_hash[:ensure] == :absent
    set_command
  end

  def initialize
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(@commands_hash['default']['get_values'])
    return [] if output.nil?
    parse_output(output)
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end

  alias update create

  def delete(_context, name)
    delete_hash = { name: name, ensure: :absent }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(delete_hash))
  end
end

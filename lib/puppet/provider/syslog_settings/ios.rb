require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# Utility functions to parse out the Interface
class Puppet::Provider::SyslogSettings::SyslogSettings < Puppet::ResourceApi::SimpleProvider
  def parse_output(output)
    new_instance_fields = []
    name_value = 'default'
    console_string = output.match(%r{#{@commands_hash['default']['console']['get_value']}})[:console]
    monitor_string = output.match(%r{#{@commands_hash['default']['monitor']['get_value']}})[:monitor]
    source_interface = output.match(%r{#{@commands_hash['default']['source_interface']['get_value']}})[:source_interface]

    new_instance = { name: name_value,
                     monitor: Puppet::Utility.convert_level_name_to_int(monitor_string),
                     console: Puppet::Utility.convert_level_name_to_int(console_string),
                     source_interface: source_interface,
                     ensure: :present }

    new_instance_fields << new_instance
    new_instance_fields
  end

  def config_command(property_hash)
    set_command = "no interface #{property_hash[:name]}"
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

  def create(_context, _name, _should); end

  def update(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t(config_command(should))
  end

  def delete(_context, name); end
end

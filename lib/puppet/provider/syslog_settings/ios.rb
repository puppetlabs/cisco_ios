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
    enable_value = Puppet::Utility.parse_attribute(output, @commands_hash, 'enable')
    console_string = Puppet::Utility.parse_attribute(output, @commands_hash, 'console')
    monitor_string = Puppet::Utility.parse_attribute(output, @commands_hash, 'monitor')
    source_interface = Puppet::Utility.parse_attribute(output, @commands_hash, 'source_interface')
    time_stamp_units = Puppet::Utility.parse_attribute(output, @commands_hash, 'time_stamp_units')
    vrf = Puppet::Utility.parse_attribute(output, @commands_hash, 'vrf')
    new_instance = { name: name_value,
                     enable: Puppet::Utility.convert_no_to_boolean(enable_value),
                     monitor: Puppet::Utility.convert_level_name_to_int(monitor_string),
                     console: Puppet::Utility.convert_level_name_to_int(console_string),
                     source_interface: source_interface,
                     time_stamp_units: time_stamp_units,
                     vrf: vrf,
                     ensure: 'present' }

    new_instance.delete_if { |_k, v| v.nil? }

    new_instance_fields << new_instance
    new_instance_fields
  end

  def config_command(attribute, value)
    set_command = @commands_hash['default'][attribute]['set_value']
    if attribute == 'enable'
      enable = ''
      enable = 'no' unless value
      set_command = set_command.to_s.gsub(%r{<#{attribute}>}, enable)
    else
      set_command = set_command.to_s.gsub(%r{<#{attribute}>}, value.to_s)
    end
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
    # TODO: update every attribute if any change is detected.
    # we should use change[:should] and [:is] to only update what attributes has change
    # resource api will need to be augmented

    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command('enable', should[:enable]))
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command('console', should[:console]))
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command('monitor', should[:monitor]))
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command('source_interface', should[:source_interface]))
  end

  def delete(_context, _name); end
end

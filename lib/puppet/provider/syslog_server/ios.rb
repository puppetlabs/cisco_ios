require 'pry'
require 'puppet/provider/cisco_ios'
require 'puppet/resource_api'
require 'puppet/util/network_device/simple/device'

# Utility functions to parse out the Interface
class SyslogServerUtils
  command_yaml_path = '/provider/syslog_server/command.yaml'.freeze
  @commands_hash = Puppet::Provider::Cisco_ios.load_yaml(command_yaml_path)

  def self.all_command
    command = @commands_hash['default']['get_all_command']
    raise 'unable to find get_all_command in command.yaml' if command.nil?
    command
  end

  def self.parse_output(output)
    new_instance_fields = []
    name_value = output.match(%r{#{@commands_hash['default']['name']['get_value']}})[:name]

    new_instance = { name: name_value,
                     ensure: :present }

    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.interface_config_command(property_hash)
    if property_hash[:ensure] == :absent
      set_command = "default interface #{property_hash[:name]}\nno interface #{property_hash[:name]}"
    else

      speed_value = property_hash[:speed]

      speed = nil
      # Convert 10m/100m/1g speed values to modelled 10/100/1000 on Cisco 6500
      # TODO: Use facts to determine model
      if speed_value && !speed_value.nil?
        speed = if speed_value == :'10m'
                  '10'
                elsif speed_value == :'100m'
                  '100'
                elsif speed_value == :'1g'
                  '1000'
                else
                  speed_value
                end
      end

      commands = Puppet::Provider::Cisco_ios.load_yaml('/provider/network_interface/command.yaml')
      interface_config_string = commands['default']['set_values']
      set_command = interface_config_string.to_s.gsub(%r{<description>}, (property_hash[:description]) ? " description #{property_hash[:description]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<mtu>}, (property_hash[:mtu]) ? " mtu #{property_hash[:mtu]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<speed>}, speed ? " speed #{speed}\n" : '')
      set_command = set_command.to_s.gsub(%r{<duplex>}, (property_hash[:duplex]) ? " duplex #{property_hash[:duplex]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<shutdown>}, (property_hash[:enable] == true) ? " no shutdown\n" : " shutdown\n")
    end
    set_command
  end
end

# Resource API syslog_server Provider
class Puppet::Provider::SyslogServer::SyslogServer
  def initialize
    # no op
  end

  def get(_context)
    command = SyslogServerUtils.all_command
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?
    SyslogServerUtils.parse_output(output)
  end

  def create(_context, name, should)
    Puppet::Provider::Cisco_ios.run_command_interface_mode(name, InterfaceParseUtils.interface_config_command(should))
  end

  def update(_context, name, should)
    Puppet::Provider::Cisco_ios.run_command_interface_mode(name, InterfaceParseUtils.interface_config_command(should))
  end

  def delete(_context, name)
    delete_hash = { name: name, ensure: :absent }
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(InterfaceParseUtils.interface_config_command(delete_hash))
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
          update(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name)
        end
      end
    end
  end
end

require 'puppet/provider/cisco_ios'
require 'pry'
require 'puppet/resource_api'
require 'puppet/util/network_device/simple/device'

# Utility functions to parse out the Interface
class InterfaceParseUtils
  def self.interface_parse_out(output)
    commands = Puppet::Provider::Cisco_ios.load_yaml('/provider/network_interface/command.yaml')

    new_instance_fields = []
    output.scan(%r{#{commands['default']['get_instances']}}).each do |raw_instance_fields|
      name_value = raw_instance_fields.match(%r{#{commands['default']['name']['get_value']}})
      description_value = raw_instance_fields.match(%r{#{commands['default']['description']['get_value']}})
      mtu_value = raw_instance_fields.match(%r{#{commands['default']['mtu']['get_value']}})
      speed_value = raw_instance_fields.match(%r{#{commands['default']['speed']['get_value']}})
      duplex_value = raw_instance_fields.match(%r{#{commands['default']['duplex']['get_value']}})
      shutdown_value = raw_instance_fields.match(%r{#{commands['default']['shutdown']['get_value']}})

      # Convert 10/100/1000 speed values to modelled 10m/100m/1g
      if speed_value && !speed_value[:speed].nil?
        speed = if speed_value[:speed] == '10'
                  '10m'
                elsif speed_value[:speed] == '100'
                  '100m'
                elsif speed_value[:speed] == '1000'
                  '1g'
                else
                  speed_value[:speed]
                end
      end

      new_instance = { name: name_value ? name_value[:interface_name] : nil,
                       enable: shutdown_value.nil?,
                       ensure: :present,
                       description: description_value ? description_value[:description] : nil,
                       mtu: mtu_value ? mtu_value[:mtu].to_i : nil,
                       speed: speed,
                       duplex: duplex_value ? duplex_value[:duplex] : nil }

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
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

# Resource API-ified NetworkInterface Provider
class Puppet::Provider::NetworkInterface::NetworkInterface
  def initialize
    # no op
  end

  def get(_context)
    command = 'show running-config | section ^interface'
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?
    InterfaceParseUtils.interface_parse_out(output)
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

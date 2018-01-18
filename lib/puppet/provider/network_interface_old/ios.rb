require 'puppet/provider/cisco_ios'
require 'pry'

# Utility functions to parse out the Interface
class InterfaceOldParseUtils
  def self.interface_old_parse_out(output)
    commands = Puppet::Provider::Cisco_ios.load_yaml('/provider/network_interface_old/command.yaml')

    new_instance_fields = []
    output.scan(%r{#{commands['default']['get_instances']}}).each do |raw_instance_fields|
      name_value = raw_instance_fields.match(%r{#{commands['default']['name']['get_value']}})
      description_value = raw_instance_fields.match(%r{#{commands['default']['description']['get_value']}})
      mtu_value = raw_instance_fields.match(%r{#{commands['default']['mtu']['get_value']}})
      speed_value = raw_instance_fields.match(%r{#{commands['default']['speed']['get_value']}})
      duplex_value = raw_instance_fields.match(%r{#{commands['default']['duplex']['get_value']}})

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

      new_instance_fields << { name: name_value ? name_value[:interface_name] : nil,
                               enable: :true,
                               description: description_value ? description_value[:description] : nil,
                               mtu: mtu_value ? mtu_value[:mtu] : nil,
                               speed: speed,
                               duplex: duplex_value ? duplex_value[:duplex] : nil }
    end
    new_instance_fields
  end

  def self.interface_old_config_command(property_hash)
    if property_hash[:enable] == :false
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

      commands = Puppet::Provider::Cisco_ios.load_yaml('/provider/network_interface_old/command.yaml')
      interface_config_string = commands['default']['set_values']
      set_command = interface_config_string.to_s.gsub(%r{<description>}, (property_hash[:description]) ? " description #{property_hash[:description]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<mtu>}, (property_hash[:mtu]) ? " mtu #{property_hash[:mtu]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<speed>}, speed ? " speed #{speed}\n" : '')
      set_command = set_command.to_s.gsub(%r{<duplex>}, (property_hash[:duplex]) ? " duplex #{property_hash[:duplex]}\n" : '')
    end
    set_command
  end
end

Puppet::Type.type(:network_interface_old).provide(:rest, parent: Puppet::Provider::Cisco_ios) do
  confine feature: :posix
  defaultfor feature: :posix

  mk_resource_methods

  def self.instances
    command = 'show running-config | section ^interface'
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?
    raw_instances = InterfaceOldParseUtils.interface_old_parse_out(output)
    new_instances = []
    raw_instances.each do |raw_instance|
      new_instances << new(raw_instance)
    end
    new_instances
  end

  def flush
    if @property_hash[:enable] == :false
      destroy
    else
      create
    end
  end

  def create
    @create_elements = true
    @property_hash = resource.to_hash
    Puppet::Provider::Cisco_ios.run_command_interface_mode(@property_hash[:name], InterfaceOldParseUtils.interface_old_config_command(@property_hash))
  end

  def destroy
    @property_hash = resource.to_hash
    @property_hash[:enable] = :false
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(InterfaceOldParseUtils.interface_old_config_command(@property_hash))
  end
end

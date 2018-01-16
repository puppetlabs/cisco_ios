require 'puppet/provider/cisco_ios'
require 'pry'

class InterfaceParseUtils
  def self.interface_parse_out(output)
    @interface_instance_regex = Regexp.new(%r{interface (?:(?:.| |\n )*\n)})
    @interface_name_value_regex = Regexp.new(%r{^.*interface (?:(?<interface_name>\S*)\n)*})
    @interface_description_value_regex = Regexp.new(%r{.*(?:(?: description )(?:(?<description>[^\n]*)\n)).*})
    @interface_mtu_value_regex = Regexp.new(%r{.*(?:(?:[^ip] mtu )(?:(?<mtu>[^\n]*)\n)).*})
    @interface_speed_value_regex = Regexp.new(%r{.*(?:(?: speed )(?:(?<speed>[^\n]*)\n)).*})
    @interface_duplex_value_regex = Regexp.new(%r{.*(?:(?: duplex )(?:(?<duplex>[^\n]*)\n)).*})

    new_instance_fields = []
    output.scan(@interface_instance_regex).each do |raw_instance_fields|
      name_value = raw_instance_fields.match(@interface_name_value_regex)
      description_value = raw_instance_fields.match(@interface_description_value_regex)
      mtu_value = raw_instance_fields.match(@interface_mtu_value_regex)
      speed_value = raw_instance_fields.match(@interface_speed_value_regex)
      duplex_value = raw_instance_fields.match(@interface_duplex_value_regex)

      name = name_value ? name_value[:interface_name] : nil
      description = description_value ? description_value[:description] : nil
      mtu = mtu_value ? mtu_value[:mtu] : nil
      speed = nil
      duplex = duplex_value ? duplex_value[:duplex] : nil

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

      new_instance_fields << { name: name,
                               enable: :true,
                               description: description,
                               mtu: mtu,
                               speed: speed,
                               duplex: duplex }
    end
    new_instance_fields
  end

  def self.interface_config_command(property_hash)
    if property_hash[:enable] == :false
      set_command = "no interface #{property_hash[:name]}"
    else
      interface_config_string = '<description><mtu>'
      set_command = interface_config_string.to_s.gsub(%r{<description>}, (property_hash[:description]) ? " description #{property_hash[:description]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<mtu>}, (property_hash[:mtu]) ? " mtu #{property_hash[:mtu]}\n" : '')
    end
    set_command
  end
end

Puppet::Type.type(:network_interface).provide(:rest, parent: Puppet::Provider::Cisco_ios) do
  confine feature: :posix
  defaultfor feature: :posix

  mk_resource_methods

  def self.instances
    command = 'show running-config | section ^interface'
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?
    raw_instances = InterfaceParseUtils.interface_parse_out(output)
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
    Puppet::Provider::Cisco_ios.run_command_interface_mode(@property_hash[:name], InterfaceParseUtils.interface_config_command(@property_hash))
  end

  def destroy
    @property_hash = resource.to_hash
    @property_hash[:enable] = :false
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(InterfaceParseUtils.interface_config_command(@property_hash))
  end
end

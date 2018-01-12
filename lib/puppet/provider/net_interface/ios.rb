require 'puppet/provider/cisco_ios'
require 'pry'

class InterfaceParseUtils
  def self.interface_parse_out(output)
    @interface_instance_regex = Regexp.new(%r{interface (?:(?:.| |\n )*\n)})
    @interface_value_regex = Regexp.new(%r{^.*^.*interface (?:(?<interface_name>\S*)\n)*(?:(?: description )(?:(?<description>.*)\n+))?})

    new_instance_fields = []
    output.scan(@interface_instance_regex).each do |raw_instance_fields|
      value = raw_instance_fields.match(@interface_value_regex)
      new_instance_fields << { :name => value[:interface_name],
                               :ensure => :present,
                               :description => value[:description] }
    end
    new_instance_fields
  end

  def self.interface_config_command(property_hash)
    if property_hash[:ensure] == :absent
      set_command = "no interface #{property_hash[:name]}"
    else
      interface_config_string = "<description>"
      set_command = interface_config_string.to_s.gsub(/<description>/, property_hash[:description] ? " description #{property_hash[:description]}\n" : '')
    end
    set_command
  end

end

Puppet::Type.type(:net_interface).provide(:rest, :parent => Puppet::Provider::Cisco_ios) do

  confine :feature => :posix
  defaultfor :feature => :posix

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
    if @property_hash[:ensure] == :absent
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
    @property_hash[:ensure] = :absent
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(InterfaceParseUtils.interface_config_command(@property_hash))
  end

end

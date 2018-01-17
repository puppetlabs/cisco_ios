require 'puppet/provider/cisco_ios'
require 'pry'

# Helper functions for parsing
class NTPServerOldParseUtils
  def self.ntp_server_old_parse_out(output)
    commands = Puppet::Provider::Cisco_ios.load_yaml('/provider/ntp_server_old/command.yaml')

    new_instance_fields = []
    output.scan(%r{#{commands['default']['get_instances']}}).each do |raw_instance_fields|
      name_field = raw_instance_fields.match(%r{#{commands['default']['name']['get_value']}})
      key_field = raw_instance_fields.match(%r{#{commands['default']['key']['get_value']}})
      minpoll_field = raw_instance_fields.match(%r{#{commands['default']['minpoll']['get_value']}})
      maxpoll_field = raw_instance_fields.match(%r{#{commands['default']['maxpoll']['get_value']}})
      prefer_field = raw_instance_fields.match(%r{#{commands['default']['prefer']['get_value']}})
      source_field = raw_instance_fields.match(%r{#{commands['default']['source']['get_value']}})
      new_instance_fields << { name: name_field ? name_field[:name] : nil,
                               ensure: :present,
                               key: key_field ? key_field[:key] : nil,
                               minpoll: minpoll_field ? minpoll_field[:minpoll] : nil,
                               maxpoll: maxpoll_field ? maxpoll_field[:maxpoll] : nil,
                               prefer: !prefer_field.nil?,
                               source_interface: source_field ? source_field[:source] : nil }
    end
    new_instance_fields
  end

  def self.ntp_server_old_config_command(property_hash)
    ntp_server_config_string =
      Puppet::Provider::Cisco_ios.load_yaml('/provider/ntp_server_old/command.yaml')['default']['set_values']
    set_command = ntp_server_config_string.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<ip>}, property_hash[:name])
    set_command = set_command.to_s.gsub(%r{<key>}, (property_hash[:key]) ? " key #{property_hash[:key]}" : '')
    set_command = set_command.to_s.gsub(%r{<minpoll>}, (property_hash[:minpoll]) ? " minpoll #{property_hash[:minpoll]}" : '')
    set_command = set_command.to_s.gsub(%r{<maxpoll>}, (property_hash[:maxpoll]) ? " maxpoll #{property_hash[:maxpoll]}" : '')
    set_command = set_command.to_s.gsub(%r{<source>}, (property_hash[:source_interface]) ? " source #{property_hash[:source_interface]}" : '')
    set_command = set_command.to_s.gsub(%r{<prefer>}, (property_hash[:prefer] == :true) ? ' prefer' : '')
    set_command
  end
end

Puppet::Type.type(:ntp_server_old).provide(:rest, parent: Puppet::Provider::Cisco_ios) do
  confine feature: :posix
  defaultfor feature: :posix

  mk_resource_methods

  def self.instances
    command = 'show running-config | section ntp server'
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?
    raw_instances = NTPServerOldParseUtils.ntp_server_old_parse_out(output)
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
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(NTPServerOldParseUtils.ntp_server_old_config_command(@property_hash))
  end

  def destroy
    @property_hash = resource.to_hash
    @property_hash[:ensure] = :absent
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(NTPServerOldParseUtils.ntp_server_old_config_command(@property_hash))
  end
end

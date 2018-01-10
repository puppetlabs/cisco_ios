require 'puppet/provider/cisco_ios'
require 'pry'

class NTPServerParseUtils
  def self.ntp_server_parse_out(output)
    @ntp_server_instance_regex = Regexp.new(%r{ntp server.+\n})
    @ntp_server_value_regex = Regexp.new(%r{^.*ntp server (?<server_name>\S*)(?:(?: key )(?<key>\d+))?(?:(?: maxpoll )(?<maxpoll>\d+))?(?:(?: minpoll )(?<minpoll>\d+))?(?<prefer>( prefer)+)?(?:(?: source )(?<source>\S*))?})

    new_instance_fields = []
    output.scan(@ntp_server_instance_regex).each do |raw_instance_fields|
      value = raw_instance_fields.match(@ntp_server_value_regex)
      new_instance_fields << { :name => value[:server_name],
                               :ensure => :present,
                               :key => value[:key],
                               :minpoll => value[:minpoll],
                               :maxpoll => value[:maxpoll],
                               :prefer => !value[:prefer].nil?,
                               :source_interface => value[:source] }
    end
    new_instance_fields
  end

  def self.ntp_server_config_command(property_hash)
    ntp_server_config_string = '<state>ntp server <ip><key><minpoll><maxpoll><source><prefer>'
    set_command = ntp_server_config_string.gsub(/<state>/,(property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(/<ip>/, property_hash[:name])
    set_command = set_command.to_s.gsub(/<key>/, property_hash[:key] ? " key #{property_hash[:key]}" : '')
    set_command = set_command.to_s.gsub(/<minpoll>/, property_hash[:minpoll] ? " minpoll #{property_hash[:minpoll]}" : '')
    set_command = set_command.to_s.gsub(/<maxpoll>/, property_hash[:maxpoll] ? " maxpoll #{property_hash[:maxpoll]}" : '')
    set_command = set_command.to_s.gsub(/<source>/, property_hash[:source_interface] ? " source #{property_hash[:source_interface]}" : '')
    set_command = set_command.to_s.gsub(/<prefer>/, (property_hash[:prefer] == :true) ? ' prefer' : '')
    set_command
  end

end

Puppet::Type.type(:ntp_server).provide(:rest, :parent => Puppet::Provider::Cisco_ios) do

  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.instances
    command = 'show running-config | include ntp server'
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?
    raw_instances = NTPServerParseUtils.ntp_server_parse_out(output)
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
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(NTPServerParseUtils.ntp_server_config_command(@property_hash))
  end

  def destroy
    @property_hash = resource.to_hash
    @property_hash[:ensure] = :absent
    Puppet::Provider::Cisco_ios.run_command_conf_t_mode(NTPServerParseUtils.ntp_server_config_command(@property_hash))
  end

end

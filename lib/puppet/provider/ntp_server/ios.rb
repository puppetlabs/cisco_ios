require 'puppet/provider/cisco_ios'
require 'pry'

Puppet::Type.type(:ntp_server).provide(:rest, :parent => Puppet::Provider::Cisco_ios) do
  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.instances
    command = 'show running-config | include ntp server'
    instance_regex = %r{ntp server.+\n}
    value_regex = %r{^.*ntp server (?<server_name>\S*)}
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?

    raw_instances = output.scan(instance_regex)
    new_instances = []
    raw_instances.each do |raw_instance|
      value = raw_instance.match(value_regex)
      new_instances << new(:name => value[:server_name],
                              :ensure => :present,
                             )
    end
    new_instances
  end

  def flush
    # nothing happens at the minute
    name = @property_hash[:name]
    if @property_hash[:ensure] == :absent
      set_command = "no ntp server #{name}"
      Puppet::Provider::Cisco_ios.run_command_conf_t_mode(set_command)
    else
      set_command = "ntp server #{name}"
      Puppet::Provider::Cisco_ios.run_command_conf_t_mode(set_command)
    end
  end

  def create
    @create_elements = true
    @property_hash = resource.to_hash
  end

  def destroy
    @property_hash[:ensure] = :absent
  end
end

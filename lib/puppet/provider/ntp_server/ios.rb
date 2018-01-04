require 'puppet/provider/cisco_ios'
require 'pry'

Puppet::Type.type(:ntp_server).provide(:rest, :parent => Puppet::Provider::Cisco_ios) do
  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.instances
    binding.pry
    command = 'show running-config | include ntp server'
    instance_regex = %r{ntp server.+\n}
    value_regex = %r{^.*ntp server (.*)(?:\n)}
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    return [] if output.nil?
    instances = output.scan(instance_regex)
    return_instances = []
    instances.each { |instance|
      value = instance.to_s.scan(value_regex)
      return_instances << new(:name => value[0].to_s,
                              :ensure => :present,
                             )
      }
    return_instances
  end

  def flush
    # nothing happens at the minute
  end

  def create
    @create_elements = true
    @property_hash = resource.to_hash
  end

  def destroy
    @property_hash[:ensure] = :absent
  end
end

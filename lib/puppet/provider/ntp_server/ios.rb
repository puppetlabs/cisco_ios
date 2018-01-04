require 'puppet/provider/cisco_ios'
require 'pry'

Puppet::Type.type(:ntp_server).provide(:rest, :parent => Puppet::Provider::Cisco_ios) do
  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.retrieve_ntp_details
    command = 'show running-config | include ntp'
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    binding.pry
    ntp_auth_regex = Regexp.new(%r{^.*(ntp authenticate).*$})
    puts ("ntp authenticate set is: #{output.match ntp_auth_regex}")
    return [] if output.nil?
    output
  end

  def self.instances
    command = 'show running-config | include ntp server'
    instance_regex = %r{ntp server.+\n}
    value_regex = %r{^ntp server (?<server>.*)$}
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)

    return [] if output.nil?
    instances = output.scan(instance_regex)
    instances.each do |instance|
      values = instance.match(value_regex)
      instances << new(:name => values[:server])
    end
    # get_output = retrieve_ntp_details
    instances
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

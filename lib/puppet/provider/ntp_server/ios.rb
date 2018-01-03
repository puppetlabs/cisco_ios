require 'puppet/provider/cisco_ios'
  require 'pry'

Puppet::Type.type(:ntp_server).provide(:rest, :parent => Puppet::Provider::Cisco_ios) do
  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.instances
    command = 'ntp authenticate'
    output = Puppet::Provider::Cisco_ios.run_command_enable_mode(command)
    binding.pry
    return [] if output.nil?
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

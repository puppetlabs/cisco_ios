require 'puppet/util/network_device/cisco_ios'
require 'puppet/util/network_device/transport/cisco_ios'
require 'pry'

# This is the base class on which other providers are based.
class Puppet::Provider::Cisco_ios < Puppet::Provider # rubocop:disable all

  @local_connect = nil

  def initialize(value = {})
    super(value)
    @original_values = if value.is_a? Hash
                         value.clone
                       else
                         {}
                       end
    @create_elements = false
  end

  def self.prefetch(resources)
    nodes = instances
    resources.keys.each do |name|
      if provider = nodes.find { |node| node.name == name } # rubocop:disable all
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.device(url)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.new(url)
  end

  def self.transport
    if Puppet::Util::NetworkDevice.current
      # we are in `puppet device`
      Puppet::Util::NetworkDevice.current.transport
    else
      # we are in `puppet resource`
      Puppet::Util::NetworkDevice::Transport::Cisco_ios.new(Facter.value(:url))
    end
  end

  def self.connection
    if @local_connect.nil?
      @local_connect ||= transport.connection
    end
    @local_connect
  end

  def self.run_command(command)
    output = connection.cmd(command)
  end

  def self.run_command_enable_mode(command)
    binding.pry
    enable_cmd = {"String" =>  'enable', "Match" => %r{^Password:.*$}}
    output = connection.cmd(enable_cmd)
    connection.cmd('bayda.dune.inca.nymph')
    output = connection.cmd(command)
  end

  def self.run_command_conf_t_mode(command)
    conf_t_cmd = {"String" =>  'conf t', "Match" => %r{^.*\(config\).*$}}
    run_command_enable_mode(conf_t_cmd)
    output = connection.cmd(command)
  end

  def self.close()
    puts "***Closing Connection***"
    connection.close_session
  end

end

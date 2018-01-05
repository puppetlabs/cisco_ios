require 'puppet/util/network_device/cisco_ios'
require 'puppet/util/network_device/transport/cisco_ios'
require 'pry'

# Modes for line, interface etc to be added
class ModeState
  NOT_CONNECTED=1
  LOGGED_IN=2
  ENABLED=3
  CONF_T=4
end

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

  def self.retrieve_mode
    unless @local_connect.nil?
      re_login = Regexp.new(%r{^.*>$})
      re_enable = Regexp.new(%r{^.*#$})
      re_conf_t = Regexp.new(%r{^.*\(config\).*$})
      prompt = @local_connect.cmd("\n")
      if prompt.match re_login
        return ModeState::LOGGED_IN
      elsif prompt.match re_enable
        return ModeState::ENABLED
      elsif prompt.match re_conf_t
        return ModeState::CONF_T
      end
    end
    ModeState::NOT_CONNECTED
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
    re_enable = Regexp.new(%r{^.*#$})
    if retrieve_mode == ModeState::CONF_T
      connection.cmd({"String" =>  'exit', "Match" => re_enable})
    elsif retrieve_mode != ModeState::ENABLED
      enable_cmd = {"String" =>  'enable', "Match" => %r{^Password:.*$}}
      output = connection.cmd(enable_cmd)
      connection.cmd('bayda.dune.inca.nymph')
    end
    output = connection.cmd(command)
  end

  def self.run_command_conf_t_mode(command)
    conf_t_cmd = {"String" =>  'conf t', "Match" => %r{^.*\(config\).*$}}
    if retrieve_mode != ModeState::ENABLED
      run_command_enable_mode(conf_t_cmd)
    elsif retrieve_mode == ModeState::ENABLED
      run_command(conf_t_cmd)
    end
    output = connection.cmd(command)
  end

  def self.close()
    puts "***Closing Connection***"
    connection.close
  end

end

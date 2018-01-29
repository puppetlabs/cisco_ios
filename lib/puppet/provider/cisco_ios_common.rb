require 'puppet/util/network_device/cisco_ios'
require 'puppet/util/network_device/transport/cisco_ios'
require 'yaml'

# Modes for line, interface etc to be added
class ModeState
  NOT_CONNECTED = 1
  LOGGED_IN = 2
  ENABLED = 3
  CONF_T = 4
  CONF_INTERFACE = 5
end

# Provides common provider functionality to connect and control Cisco Ios devices
class Puppet::Provider::CiscoIosCommon
  @local_connect = nil

  def self.retrieve_mode
    unless @local_connect.nil?
      re_login = Regexp.new(%r{^.*>$})
      re_enable = Regexp.new(%r{^.*#$})
      re_conf_t = Regexp.new(%r{^.*\(config\).*$})
      re_conf_if = Regexp.new(%r{^.*\(config-if\).*$})
      prompt = @local_connect.cmd("\n")

      return ModeState::LOGGED_IN if prompt.match re_login
      return ModeState::CONF_T if prompt.match re_conf_t
      return ModeState::CONF_INTERFACE if prompt.match re_conf_if
      return ModeState::ENABLED if prompt.match re_enable
    end
    ModeState::NOT_CONNECTED
  end

  def self.prefetch(resources)
    nodes = instances
    resources.each_key do |name|
      if (provider = nodes.find { |node| node.name == name })
        resources[name].provider = provider
      end
    end
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
    connection.cmd(command)
  end

  def self.run_command_enable_mode(command)
    re_enable = Regexp.new(%r{^.*#$})
    conf_t_regex = Regexp.new(%r{^.*\(config\).*$})
    if retrieve_mode == ModeState::CONF_T
      connection.cmd('String' =>  'exit', 'Match' => re_enable)
    elsif retrieve_mode == ModeState::CONF_INTERFACE
      connection.cmd('String' =>  'exit', 'Match' => conf_t_regex)
      connection.cmd('String' =>  'exit', 'Match' => re_enable)
    elsif retrieve_mode != ModeState::ENABLED
      enable_cmd = { 'String' => 'enable', 'Match' => %r{^Password:.*$|#} }
      connection.cmd(enable_cmd)
      raise "Set the DEVICE_ENABLE_PASSWORD eg:'export DEVICE_ENABLE_PASSWORD=bla'" if ENV['DEVICE_ENABLE_PASSWORD'].nil?
      enable_password = ENV['DEVICE_ENABLE_PASSWORD'] ? ENV['DEVICE_ENABLE_PASSWORD'] : '' # rubocop:disable Style/TernaryParentheses
      connection.cmd(enable_password)
    end
    connection.cmd(command)
  end

  def self.run_command_conf_t_mode(command)
    conf_t_regex = Regexp.new(%r{^.*\(config\).*$})
    conf_t_cmd = { 'String' => 'conf t', 'Match' => conf_t_regex }
    if retrieve_mode == ModeState::CONF_INTERFACE
      connection.cmd('String' => 'exit', 'Match' => conf_t_regex)
    elsif retrieve_mode != ModeState::ENABLED
      run_command_enable_mode(conf_t_cmd)
    elsif retrieve_mode == ModeState::ENABLED
      run_command(conf_t_cmd)
    end
    connection.cmd(command)
  end

  def self.run_command_interface_mode(interface_name, command)
    conf_if_regex = Regexp.new(%r{^.*\(config-if\).*$})
    conf_if_cmd = { 'String' => "interface #{interface_name}", 'Match' => conf_if_regex }
    if retrieve_mode != ModeState::CONF_INTERFACE
      run_command_conf_t_mode(conf_if_cmd)
    end
    connection.cmd(command)
  end

  def self.close
    puts '***Closing Connection***'
    connection.close
  end

  def self.replace_double_escapes(data_hash)
    data_hash.each_pair do |key, value|
      if value.is_a?(Hash)
        replace_double_escapes(value)
      else
        data_hash[key] = value.gsub(%r{\\\\}, '\\')
      end
    end
    data_hash
  end

  def self.load_yaml(file)
    full_path = File.expand_path(File.dirname(File.dirname(__FILE__))) + file
    raise "File #{full_path} doesn't exist." unless File.exist?(full_path)
    yaml_file = File.read(full_path)
    data_hash = YAML.safe_load(yaml_file)
    replace_double_escapes(data_hash)
  end
end

require 'puppet/util/network_device'
require 'hocon'
require 'hocon/config_syntax'
require 'puppet/util/network_device/base'

module Puppet::Util::NetworkDevice::Cisco_ios
  class ModeState
    NOT_CONNECTED = 1
    LOGGED_IN = 2
    ENABLED = 3
    CONF_T = 4
    CONF_INTERFACE = 5
  end

  class Puppet::Util::NetworkDevice::Transport::Cisco_ios < Puppet::Util::NetworkDevice::Transport::Base
    attr_reader :connection, :enable_password

    def initialize(config, _options = {})
      require 'uri'
      require 'net/ssh/telnet'

      Puppet.debug "Trying to connect to #{config['default']['node']['address']} as #{config['default']['node']['username']}"
      @connection = Net::SSH::Telnet.new(
        'Dump_log' => './SSH_I_DUMPED',
        'Host' => config['default']['node']['address'],
        'Username' => config['default']['node']['username'],
        'Password' => config['default']['node']['password'],
        'Prompt' =>  %r{[#>]\s?\z},
        'Port' => config['default']['node']['port'] || 23,
      )
      @enable_password = config['default']['node']['enable_password']
      # IOS will page large results which breaks prompt search
      @connection.cmd('terminal length 0')
      @connection
    end
  end

  # Our fun happens here
  class Puppet::Util::NetworkDevice::Cisco_ios::Device
    attr_reader :connection
    attr_accessor :url, :transport

    def self.send_command(connection_to_use, options)
      return_value = connection_to_use.cmd(options)
      commands = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
      unknown_command = Regexp.new(%r{#{commands['default']['unknown_command']}})
      invalid_input = Regexp.new(%r{#{commands['default']['invalid_input']}})

      if return_value.match(unknown_command) || return_value.match(invalid_input)
        sent_string = if options.is_a?(Hash)
                        options['String']
                      else
                        options
                      end
        raise "'#{return_value}' Error sending '#{sent_string}'"
      end
      return_value
    end

    def self.retrieve_mode
      commands = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
      unless connection.nil?
        re_login = Regexp.new(%r{#{commands['default']['login_prompt']}})
        re_enable = Regexp.new(%r{#{commands['default']['enable_prompt']}})
        re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
        re_conf_if = Regexp.new(%r{#{commands['default']['interface_prompt']}})
        prompt = send_command(connection, "\n")

        return ModeState::LOGGED_IN if prompt.match re_login
        return ModeState::CONF_T if prompt.match re_conf_t
        return ModeState::CONF_INTERFACE if prompt.match re_conf_if
        return ModeState::ENABLED if prompt.match re_enable
      end
      ModeState::NOT_CONNECTED
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
        @transport ||= begin
          @url = URI.parse(Facter.value(:url))
          raise "The url '#{@url}' in your device.conf is not a valid file path." if @url.path == '' || @url.nil?
          raise "Trying to load config from '#{@url.path}', but file does not exist." unless File.exist? @url.path
          @config ||= Hocon.load(@url.path, syntax: Hocon::ConfigSyntax::HOCON)
          Puppet::Util::NetworkDevice::Transport::Cisco_ios.new(@config)
        end
      end
    end

    def self.connection
      transport.connection
    end

    def self.run_command(command)
      send_command(connection, command)
    end

    def self.run_command_enable_mode(command)
      commands = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
      re_enable = Regexp.new(%r{#{commands['default']['enable_prompt']}})
      re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
      if retrieve_mode == ModeState::CONF_T
        send_command(connection, 'String' =>  'exit', 'Match' => re_enable)
      elsif retrieve_mode == ModeState::CONF_INTERFACE
        send_command(connection, 'String' =>  'exit', 'Match' => re_conf_t)
        send_command(connection, 'String' =>  'exit', 'Match' => re_enable)
      elsif retrieve_mode != ModeState::ENABLED
        enable_cmd = { 'String' => 'enable', 'Match' => %r{^Password:.*$|#} }
        send_command(connection, enable_cmd)
        send_command(connection, transport.enable_password)
      end
      send_command(connection, command)
    end

    def self.run_command_conf_t_mode(command)
      commands = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
      re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
      conf_t_cmd = { 'String' => 'conf t', 'Match' => re_conf_t }
      if retrieve_mode == ModeState::CONF_INTERFACE
        send_command(connection, 'String' => 'exit', 'Match' => conf_t_regex)
      elsif retrieve_mode != ModeState::ENABLED
        run_command_enable_mode(conf_t_cmd)
      elsif retrieve_mode == ModeState::ENABLED
        run_command(conf_t_cmd)
      end
      send_command(connection, command)
    end

    def self.run_command_interface_mode(interface_name, command)
      commands = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
      re_conf_if = Regexp.new(%r{#{commands['default']['interface_prompt']}})
      conf_if_cmd = { 'String' => "interface #{interface_name}", 'Match' => re_conf_if }
      if retrieve_mode != ModeState::CONF_INTERFACE
        run_command_conf_t_mode(conf_if_cmd)
      end
      send_command(connection, command)
    end

    def self.close
      puts '***Closing Connection***'
      connection.close
    end

    def create_connection(config, _options = {})
      require 'uri'
      require 'net/ssh/telnet'

      Puppet.debug "Trying to connect to #{config['default']['node']['address']} as #{config['default']['node']['username']}"
      @connection = Net::SSH::Telnet.new(
        'Dump_log' => './SSH_I_DUMPED',
        'Host' => config['default']['node']['address'],
        'Username' => config['default']['node']['username'],
        'Password' => config['default']['node']['password'],
        'Prompt' => %r{[#>]\s?\z},
        'Port' => config['default']['node']['port'] || 22,
        'Enable_password' => config['default']['node']['enable_password'] || config['default']['node']['password'],
      )
      # IOS will page large results which breaks prompt search
      @connection.cmd('terminal length 0')
      @connection
    end

    def config
      raise "Trying to load config from '#{@url.path}', but file does not exist." unless File.exist? @url.path
      @config ||= Hocon.load(@url.path, syntax: Hocon::ConfigSyntax::HOCON)
    end

    def initialize(url, options = {})
      @url = URI.parse(url)
      raise "Unexpected url '#{url}' found. Only file:// URLs for configuration supported at the moment." unless @url.scheme == 'file'

      @transport = Puppet::Util::NetworkDevice::Transport::Cisco_ios.new(config, options[:debug])
      @enable_password = config['default']['node']['enable_password']
    end

    def parse_device_facts
      facts = { 'operatingsystem' => 'cisco_ios' }
      return_facts = {}
      # https://www.cisco.com/c/en/us/support/docs/switches/catalyst-6500-series-switches/41361-serial-41361.html
      begin
        version_info = @transport.connection.cmd('show version')
        if version_info
          facts['operatingsystemrelease'] = %r{Version\s+([^,]*)}.match(version_info)[1]
          if version_info =~ %r{WS-C65}
            backplane_info = @transport.connection.cmd('show idprom backplane')
            facts['hardwaremodel'] = %r{Product Number\s+=\s+\'([^']+)}.match(backplane_info)[1]
            facts['serialnumber'] = %r{Serial Number\s+=\s+\'([^']+)}.match(backplane_info)[1]
          else
            facts['hardwaremodel'] = %r{Model number\s+:\s+(\S+)}.match(version_info)[1]
            facts['serialnumber'] = %r{System serial number\s+:\s+(\S+)}.match(version_info)[1]
          end
        else
          raise Puppet::Error, 'Could not retrieve facts'
        end
      end
      return_facts.merge(facts)
    end

    def facts
      @facts ||= parse_device_facts
    end
  end
end

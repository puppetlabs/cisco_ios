require 'hocon'
require 'hocon/config_syntax'
require 'puppet/util/network_device'
require 'puppet/util/network_device/base'
require_relative '../../../../puppet_x/puppetlabs/cisco_ios/utility'

module Puppet::Util::NetworkDevice::Cisco_ios # rubocop:disable Style/ClassAndModuleCamelCase
  # configuration state, eg in tacacs mode
  class ModeState
    NOT_CONNECTED = 1 unless defined? NOT_CONNECTED
    LOGGED_IN = 2 unless defined? LOGGED_IN
    ENABLED = 3 unless defined? ENABLED
    CONF_T = 4 unless defined? CONF_T
    CONF_INTERFACE = 5 unless defined? CONF_INTERFACE
    CONF_TACACS = 6 unless defined? CONF_TACACS
    CONF_VLAN = 7 unless defined? CONF_VLAN
    CONF_TACACS_SERVER_GROUP = 8 unless defined? CONF_TACACS_SERVER_GROUP
    CONF_RADIUS_SERVER_GROUP = 9 unless defined? CONF_RADIUS_SERVER_GROUP
    CONF_RADIUS_SERVER = 10 unless defined? CONF_RADIUS_SERVER
    CONF_LINE = 11 unless defined? CONF_LINE
    CONF_MST = 12 unless defined? CONF_MST
    CONF_STD_NACL = 13 unless defined? CONF_STD_NACL
    CONF_EXT_NACL = 14 unless defined? CONF_EXT_NACL
  end

  # Our fun happens here
  class Puppet::Util::NetworkDevice::Cisco_ios::Device # rubocop:disable Style/ClassAndModuleCamelCase
    attr_reader :connection
    attr_accessor :url, :transport, :facts, :commands

    def send_command(connection_to_use, options, debug = false)
      return_value = connection_to_use.cmd(options)
      unknown_command = commands['default']['unknown_command']
      invalid_input = commands['default']['invalid_input']
      incomplete_command = commands['default']['incomplete_command']
      command_rejected = Regexp.new(%r{#{commands['default']['command_rejected']}})
      if return_value =~ %r{#{unknown_command}|#{invalid_input}|#{incomplete_command}|#{command_rejected}}
        sent_string = if options.is_a?(Hash)
                        options['String']
                      else
                        options
                      end
        raise "'#{return_value}' Error sending '#{sent_string}'"
      end
      if debug
        caller.each do |line|
          if line =~ %r{puppet/provider}
            Puppet.debug("cisco_ios.send_command from #{line}:'#{return_value.inspect}'")
          end
        end
      end
      return_value
    end

    def retrieve_mode
      unless connection.nil?
        re_login = Regexp.new(%r{#{commands['default']['login_prompt']}})
        re_enable = Regexp.new(%r{#{commands['default']['enable_prompt']}})
        re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
        re_conf_if = Regexp.new(%r{#{commands['default']['interface_prompt']}})
        re_conf_tacacs = Regexp.new(%r{#{commands['default']['tacacs_prompt']}})
        re_conf_vlan = Regexp.new(%r{#{commands['default']['vlan_prompt']}})
        re_conf_tacacs_server_group = Regexp.new(%r{#{commands['default']['tacacs_server_group_prompt']}})
        re_conf_radius_server_group = Regexp.new(%r{#{commands['default']['radius_server_group_prompt']}})
        re_conf_radius_server = Regexp.new(%r{#{commands['default']['radius_server_prompt']}})
        re_conf_line = Regexp.new(%r{#{commands['default']['line_prompt']}})
        re_conf_mst = Regexp.new(%r{#{commands['default']['mst_prompt']}})
        re_conf_std_nacl = Regexp.new(%r{#{commands['default']['std_nacl_prompt']}})
        re_conf_ext_nacl = Regexp.new(%r{#{commands['default']['ext_nacl_prompt']}})
        prompt = send_command(connection, ' ')

        return ModeState::LOGGED_IN if prompt.match re_login
        return ModeState::CONF_T if prompt.match re_conf_t
        return ModeState::CONF_INTERFACE if prompt.match re_conf_if
        return ModeState::CONF_TACACS if prompt.match re_conf_tacacs
        return ModeState::CONF_VLAN if prompt.match re_conf_vlan
        return ModeState::CONF_TACACS_SERVER_GROUP if prompt.match re_conf_tacacs_server_group
        return ModeState::CONF_RADIUS_SERVER_GROUP if prompt.match re_conf_radius_server_group
        return ModeState::CONF_RADIUS_SERVER if prompt.match re_conf_radius_server
        return ModeState::CONF_LINE if prompt.match re_conf_line
        return ModeState::CONF_MST if prompt.match re_conf_mst
        return ModeState::CONF_STD_NACL if prompt.match re_conf_std_nacl
        return ModeState::CONF_EXT_NACL if prompt.match re_conf_ext_nacl
        return ModeState::ENABLED if prompt.match re_enable
      end
      ModeState::NOT_CONNECTED
    end

    def commands
      @commands ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def run_command(command)
      send_command(connection, command, false)
    end

    def retrieve_mode_special_config_mode
      if  retrieve_mode == ModeState::CONF_INTERFACE ||
          retrieve_mode == ModeState::CONF_TACACS ||
          retrieve_mode == ModeState::CONF_VLAN ||
          retrieve_mode == ModeState::CONF_TACACS_SERVER_GROUP ||
          retrieve_mode == ModeState::CONF_RADIUS_SERVER_GROUP ||
          retrieve_mode == ModeState::CONF_RADIUS_SERVER ||
          retrieve_mode == ModeState::CONF_LINE ||
          retrieve_mode == ModeState::CONF_MST ||
          retrieve_mode == ModeState::CONF_STD_NACL ||
          retrieve_mode == ModeState::CONF_EXT_NACL
        return true
      end
      false
    end

    def run_command_enable_mode(command)
      re_enable = Regexp.new(%r{#{commands['default']['enable_prompt']}})
      re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
      if retrieve_mode == ModeState::CONF_T
        send_command(connection, 'String' =>  'exit', 'Match' => re_enable)
      elsif retrieve_mode_special_config_mode
        send_command(connection, 'String' =>  'exit', 'Match' => re_conf_t)
        send_command(connection, 'String' =>  'exit', 'Match' => re_enable)
      elsif retrieve_mode != ModeState::ENABLED
        enable_cmd = { 'String' => 'enable', 'Match' => %r{^Password:.*$|#} }
        send_command(connection, enable_cmd)
        send_command(connection, @enable_password)
      end
      send_command(connection, command, true)
    end

    def run_command_conf_t_mode(command)
      re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
      conf_t_cmd = { 'String' => 'conf t', 'Match' => re_conf_t }
      if retrieve_mode_special_config_mode
        send_command(connection, 'String' => 'exit', 'Match' => conf_t_regex)
      elsif retrieve_mode != ModeState::ENABLED
        run_command_enable_mode(conf_t_cmd)
      elsif retrieve_mode == ModeState::ENABLED
        send_command(connection, conf_t_cmd)
      end
      send_command(connection, command, true)
    end

    def run_command_interface_mode(interface_name, command)
      conf_if_cmd = "interface #{interface_name}"
      if retrieve_mode != ModeState::CONF_INTERFACE
        run_command_conf_t_mode(conf_if_cmd)
        # If we were unable to enter interface mode for whatever reason, throw error
        if retrieve_mode != ModeState::CONF_INTERFACE
          raise "Could not enter interface mode for interface #{interface_name}"
        end
      end
      prompt = send_command(connection, command, true)
      re_conf_confirm = Regexp.new(%r{#{commands['default']['network_trunk_confirm']}})
      # Network trunk confirm prompt eg.
      #   Subinterfaces configured on this interface will not be available after switchport.
      #   Proceed with the command? [confirm]
      if prompt.match(re_conf_confirm)
        send_command(connection, '', true)
      end
      # Exit out of interface mode to save changes
      send_command(connection, 'exit', true)
    end

    def run_command_radius_mode(radius_name, command)
      re_conf_radius = Regexp.new(%r{#{commands['default']['radius_prompt']}})
      conf_radius_cmd = { 'String' => "aaa group server radius #{radius_name}", 'Match' => re_conf_radius }
      if retrieve_mode != ModeState::CONF_RADIUS_SERVER_GROUP
        run_command_conf_t_mode(conf_radius_cmd)
      end
      send_command(connection, command, true)
      # Exit out of radius mode to save changes
      send_command(connection, 'exit', true)
    end

    def run_command_radius_server_mode(radius_name, command)
      re_conf_radius_server = Regexp.new(%r{#{commands['default']['radius_server_prompt']}})
      conf_radius_server_cmd = { 'String' => "radius server #{radius_name}", 'Match' => re_conf_radius_server }
      if retrieve_mode != ModeState::CONF_RADIUS_SERVER
        run_command_conf_t_mode(conf_radius_server_cmd)
      end
      send_command(connection, command, true)
      # Exit out of radius server mode to save changes
      send_command(connection, 'exit', true)
    end

    def run_command_tacacs_mode(tacacs_name, command)
      re_conf_tacacs = Regexp.new(%r{#{commands['default']['tacacs_prompt']}})
      conf_tacacs_cmd = { 'String' => "tacacs server #{tacacs_name}", 'Match' => re_conf_tacacs }
      if retrieve_mode != ModeState::CONF_TACACS
        run_command_conf_t_mode(conf_tacacs_cmd)
      end
      send_command(connection, command, true)
      # Exit out of tacacs mode to save changes
      send_command(connection, 'exit', true)
    end

    def run_command_vlan_mode(vlan_name, command)
      re_conf_vlan = Regexp.new(%r{#{commands['default']['vlan_prompt']}})
      conf_vlan_cmd = { 'String' => "vlan #{vlan_name}", 'Match' => re_conf_vlan }
      if retrieve_mode != ModeState::CONF_VLAN
        run_command_conf_t_mode(conf_vlan_cmd)
      end
      send_command(connection, command, true)
      # Exit out of vlan mode to save changes
      send_command(connection, 'exit', true)
    end

    def run_command_tacacs_server_group_mode(tacacs_server_group_name, command)
      re_conf_tacacs_server_group = Regexp.new(%r{#{commands['default']['tacacs_server_group_prompt']}})
      conf_tacacs_server_group_cmd = { 'String' => "aaa group server tacacs #{tacacs_server_group_name}", 'Match' => re_conf_tacacs_server_group }
      if retrieve_mode != ModeState::CONF_TACACS_SERVER_GROUP
        run_command_conf_t_mode(conf_tacacs_server_group_cmd)
      end
      send_command(connection, command, true)
      # Exit out of tacacs server group mode to save changes
      send_command(connection, 'exit', true)
    end

    def run_command_mst_mode(command)
      re_conf_mst = Regexp.new(%r{#{commands['default']['mst_prompt']}})
      conf_mst_cmd = { 'String' => 'spanning-tree mst configuration', 'Match' => re_conf_mst }
      if retrieve_mode != ModeState::CONF_MST
        run_command_conf_t_mode(conf_mst_cmd)
      end
      send_command(connection, command, true)
      # Exit out of mst mode to save changes
      send_command(connection, 'exit', true)
    end

    def config
      raise "Trying to load config from '#{@url.path}', but file does not exist." unless File.exist? @url.path
      @config ||= Hocon.load(@url.path, syntax: Hocon::ConfigSyntax::HOCON)
    end

    def initialize(url, options = {})
      @url = URI.parse(url)
      raise "Unexpected url '#{url}' found. Only file:// URLs for configuration supported at the moment." unless @url.scheme == 'file'

      create_connection(config, options[:debug])
      @enable_password = config['enable_password']
      PuppetX::CiscoIOS::Utility.facts(@facts)
    end

    def create_connection(config, _options = {})
      require 'uri'
      require 'net/ssh/telnet'

      Puppet.debug "Trying to connect to #{config['address']} as #{config['username']}"
      @connection = Net::SSH::Telnet.new(
        'Dump_log' => './SSH_I_DUMPED',
        'Host' => config['address'],
        'Username' => config['username'],
        'Password' => config['password'],
        'Prompt' =>  %r{[#>]\s?\z},
        'Port' => config['port'] || 22,
      )
      @enable_password = config['enable_password']
      # IOS will page large results which breaks prompt search
      @connection.cmd('terminal length 0')
      @facts = parse_device_facts
      @connection
    end

    def parse_device_facts
      facts = { 'operatingsystem' => 'cisco_ios' }
      return_facts = {}
      # https://www.cisco.com/c/en/us/support/docs/switches/catalyst-6500-series-switches/41361-serial-41361.html
      begin
        version_info = @connection.cmd('show version')
        raise Puppet::Error, 'Could not retrieve facts' unless version_info
        facts['hardwaremodel'] = version_info[%r{cisco\s+(\S+).+processor}i, 1]
        facts['serialnumber'] = version_info[%r{Processor board ID (\w*)}, 1]
        facts['operatingsystemrelease'] = version_info[%r{(?i)version.(\S*),}, 1]
      end
      return_facts.merge(facts)
    end

    def running_config_save(dest = 'startup-config')
      shhh_command = 'file prompt quiet'
      copy_command = "copy running-config #{dest}"
      run_command_conf_t_mode(shhh_command)
      copy_result = run_command_enable_mode(copy_command)
      copy_status = copy_result.match(%r{\[OK\]|\d+ bytes copied in \d+\.\d+ secs \(\d+ bytes\/sec\)})
      raise "Unexpected results for: #{copy_command}" unless copy_status
      copy_status
    end
  end
end

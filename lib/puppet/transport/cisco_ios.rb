require_relative '../../puppet_x/puppetlabs/cisco_ios/utility'

module Puppet::Transport
  # Provides a Transport for making remote calls to a Cisco Ios device
  class CiscoIos
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
      CONF_VRF = 15 unless defined? CONF_VRF
    end

    attr_reader :connection, :config
    attr_accessor :commands

    def initialize(context, connection_info)
      @context = context
      @config = connection_info

      create_connection
      @enable_password = connection_info[:enable_password].unwrap
      @facts = facts(context)
      PuppetX::CiscoIOS::Utility.facts(@facts)
    end

    def create_connection
      require 'uri'
      require 'net/ssh/telnet'

      Puppet.debug "Trying to connect to #{config[:host]} as #{config[:user]}"

      known_hosts_file = config[:known_hosts_file] || "#{Puppet[:vardir]}/ssl/known_hosts"

      # Create the known hosts directory if it does not exist
      # eg. using --wait
      dirname = File.dirname(known_hosts_file)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

      verify_host_key = (Gem.loaded_specs['net-ssh'].version < Gem::Version.create('4.2.0')) ? :paranoid : :verify_host_key
      session = if !config[:verify_hosts].nil? && !config[:verify_hosts]
                  Net::SSH.start(config[:host],
                                 config[:user],
                                 password: config[:password].unwrap,
                                 port: config[:port] || 22,
                                 timeout: config[:timeout] || 30,
                                 verify_host_key => false,
                                 user_known_hosts_file: known_hosts_file,
                                 append_all_supported_algorithms: true)
                else
                  Net::SSH.start(config[:host],
                                 config[:user],
                                 password: config[:password].unwrap,
                                 port: config[:port] || 22,
                                 timeout: config[:timeout] || 30,
                                 verify_host_key => :very,
                                 user_known_hosts_file: known_hosts_file,
                                 append_all_supported_algorithms: true)
                end

      @options = { 'Prompt' =>  %r{#{commands['default']['connect_prompt']}},
                   'Session' => session }

      if config[:ssh_logging] == true && (Puppet::Util::Log.level == :debug)
        if config[:ssh_log_file]
          @options['Dump_log'] = config[:ssh_log_file]
        else
          # ensure we have a cache folder structure exists for the device
          FileUtils.mkdir_p(Puppet[:statedir]) unless File.directory?(Puppet[:statedir])
          @options['Dump_log'] = "#{Puppet[:statedir]}/SSH_I_DUMPED"
        end
        FileUtils.touch @options['Dump_log']
        FileUtils.chmod 0o0640, @options['Dump_log']
      end
      @connection = Net::SSH::Telnet.new(@options)
      @enable_password = config[:enable_password].unwrap
      @command_timeout = config[:command_timeout] || 120
      # IOS will page large results which breaks prompt search
      send_command(@connection, 'terminal length 0')
      @connection
    end

    def facts(_context)
      facts = { 'operatingsystem' => 'cisco_ios' }
      # https://www.cisco.com/c/en/us/support/docs/switches/catalyst-6500-series-switches/41361-serial-41361.html
      begin
        version_info = @connection.cmd('show version')
        raise Puppet::Error, 'Could not retrieve facts' unless version_info
        facts['hardwaremodel'] = version_info[%r{cisco\s+(\S+).+processor}i, 1]
        facts['hostname'] = version_info[%r{(\S+)\s+uptime}, 1]
        facts['serialnumber'] = version_info[%r{Processor board ID (\w*)}, 1]
        facts['operatingsystemrelease'] = version_info[%r{(?i)IOS Software.*Version\s+([^,\s]+)}, 1]
        facts['os'] = {}
        facts['os']['family'] = version_info[%r{(.*Software)}]
      end
      facts
    end

    def close(_context)
      @connection.close if @connection.channel
      @connection = nil
    end

    def verify(_context)
      raise if @connection.channel.nil?
    end

    def send_command(connection_to_use, options, debug = false)
      if options.is_a?(Hash)
        options['Timeout'] = @command_timeout unless options.key?('Timeout')
      elsif options.is_a?(String)
        options = { 'String' => options, 'Timeout' => @command_timeout }
      end
      return_value = connection_to_use.cmd(options)
      # Check for authentication related errors
      access_denied = commands['default']['access_denied']
      command_authorization_failed = commands['default']['command_authorization_failed']
      error_in_authentication = commands['default']['error_in_authentication']
      # If authentication related, do not output value as it is most likely sensitive
      if return_value =~ %r{#{access_denied}|#{command_authorization_failed}|#{error_in_authentication}}
        raise return_value.to_s
      end
      unknown_command = commands['default']['unknown_command']
      invalid_input = commands['default']['invalid_input']
      incomplete_command = commands['default']['incomplete_command']
      command_rejected = commands['default']['command_rejected']
      default_vlan_only_allowed = commands['default']['default_vlan_only_allowed']
      default_vlan_name_change = commands['default']['default_vlan_name_change']
      if return_value =~ %r{#{unknown_command}|#{invalid_input}|#{incomplete_command}|#{command_rejected}|#{default_vlan_only_allowed}|#{default_vlan_name_change}}
        sent_string = if options.is_a?(Hash)
                        options['String']
                      else
                        options
                      end

        raise "\n'#{return_value}'\nError sending: '#{sent_string}'"
      end
      if debug && !return_value.strip.empty?
        message = "cisco_ios.send_command from:\n"
        caller.select { |line| line =~ %r{puppet/(provider|transport)+} }.each do |line|
          message += "\t#{line}\n"
        end
        message += "rtn: #{return_value.inspect}'"
        Puppet.debug(message)
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
        re_conf_vrf = Regexp.new(%r{#{commands['default']['vrf_prompt']}})
        prompt = send_command(connection, ' ').lines.last.rstrip

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
        return ModeState::CONF_VRF if prompt.match re_conf_vrf
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

    def retrieve_mode_special_config_mode(mode_in = nil)
      mode_in = retrieve_mode if mode_in.nil?
      if [ModeState::CONF_INTERFACE,
          ModeState::CONF_TACACS,
          ModeState::CONF_VLAN,
          ModeState::CONF_TACACS_SERVER_GROUP,
          ModeState::CONF_RADIUS_SERVER_GROUP,
          ModeState::CONF_RADIUS_SERVER,
          ModeState::CONF_LINE,
          ModeState::CONF_MST,
          ModeState::CONF_STD_NACL,
          ModeState::CONF_EXT_NACL,
          ModeState::CONF_VRF].include?(mode_in)

        return true
      end
      false
    end

    def run_command_enable_mode(command)
      re_enable = Regexp.new(%r{#{commands['default']['enable_prompt']}})
      re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
      mode = retrieve_mode
      if mode == ModeState::CONF_T
        send_command(connection, 'String' =>  'exit', 'Match' => re_enable)
      elsif retrieve_mode_special_config_mode(mode)
        send_command(connection, 'String' =>  'exit', 'Match' => re_conf_t)
        send_command(connection, 'String' =>  'exit', 'Match' => re_enable)
      elsif mode != ModeState::ENABLED
        # Match either nothing (password prompt), or cli prompt (error state)
        # Errors will be picked out by send_command
        enable_cmd = { 'String' => 'enable', 'Match' => %r{|#$|>$} }
        prompt = send_command(connection, enable_cmd, true)
        # Do not send password unless requried
        unless prompt =~ %r{#$}
          # Turn off dump log to prevent leaking enable password
          options = connection.instance_variable_get(:@options)
          dump_log = options['Dump_log']
          if dump_log
            options.delete('Dump_log')
            connection.instance_variable_set(:@options, options)
            send_command(connection, @enable_password)
            options['Dump_log'] = dump_log
            connection.instance_variable_set(:@options, options)
          else
            send_command(connection, @enable_password)
          end
        end
      end
      send_command(connection, command, true)
    end

    def restore_config_conf_t_mode(conf)
      re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
      run_command_enable_mode({ 'String' => 'conf t', 'Match' => re_conf_t })
      conf.each do |c|
        send_command(connection, "#{c}\n")
      end
    end

    def run_command_conf_t_mode(command)
      re_conf_t = Regexp.new(%r{#{commands['default']['config_prompt']}})
      conf_t_cmd = { 'String' => 'conf t', 'Match' => re_conf_t }
      mode = retrieve_mode
      if retrieve_mode_special_config_mode(mode)
        send_command(connection, 'String' => 'exit', 'Match' => re_conf_t)
      elsif mode != ModeState::ENABLED
        run_command_enable_mode(conf_t_cmd)
      elsif mode == ModeState::ENABLED
        send_command(connection, conf_t_cmd)
      end

      return_value = send_command(connection, command, true)
      confirm_prompt = Regexp.new(%r{#{commands['default']['new_model_confirm']}})
      acc_confirm_prompt = Regexp.new(%r{#{commands['default']['aaa_accounting_identity_confirm']}})
      # confirm prompt eg.
      #   Proceed with the command? [confirm]
      if return_value.match(confirm_prompt) || return_value.match(acc_confirm_prompt)
        send_command(connection, '', true)
      end
      # Belt and braces approach to potential motd matching as a prompt - send a space with an implicit newline to clear the prompt
      send_command(connection, ' ', true)
      return_value
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
      command.split("\n").each do |sub_command|
        prompt = send_command(connection, sub_command, true)
        re_conf_confirm = Regexp.new(%r{#{commands['default']['network_trunk_confirm']}})
        # Network trunk confirm prompt eg.
        #   Subinterfaces configured on this interface will not be available after switchport.
        #   Proceed with the command? [confirm]
        if prompt.match(re_conf_confirm)
          send_command(connection, '', true)
        end
      end
      # Exit out of interface mode to save changes
      send_command(connection, 'exit', true)
    end

    def run_command_vrf_mode(vrf_name, command)
      re_conf_vrf = Regexp.new(%r{#{commands['default']['vrf_prompt']}})
      conf_vrf_cmd = { 'String' => "ip vrf #{vrf_name}", 'Match' => re_conf_vrf }
      if retrieve_mode != ModeState::CONF_VRF
        run_command_conf_t_mode(conf_vrf_cmd)
      end
      send_command(connection, command, true)
      # Exit out of vrf mode to save changes
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

    def run_command_acl_mode(acl_name, acl_type, command)
      conf_acl_cmd = "ip access-list #{acl_type} #{acl_name}"
      modestate_type = if acl_type.casecmp('extended').zero?
                         ModeState::CONF_EXT_NACL
                       else
                         ModeState::CONF_STD_NACL
                       end

      if retrieve_mode != modestate_type
        run_command_conf_t_mode(conf_acl_cmd)
        # If we were unable to enter ACL mode for whatever reason, throw error
        if retrieve_mode != modestate_type
          raise "Could not enter ACL mode for #{acl_name}"
        end
      end
      send_command(connection, command, true)
      # Exit out of ACL mode to save changes
      send_command(connection, 'exit', true)
    end

    def save_config(from: 'running-config', to: 'startup-config')
      shhh_command = 'file prompt quiet'
      copy_command = "copy #{from} #{to}"
      run_command_conf_t_mode(shhh_command)
      copy_result = run_command_enable_mode(copy_command)
      copy_status = copy_result.match(%r{\[OK\]|\d+ bytes copied in \d+\.\d+ secs \(\d+ bytes\/sec\)})
      raise "Unexpected results for: #{copy_command}: \n: #{copy_result}" unless copy_status
      copy_status
    end
  end
end

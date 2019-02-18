begin
  require 'puppet/resource_api/transport/wrapper'
rescue LoadError
  require 'puppet_x/puppetlabs/cisco_ios/transport_shim'
end

class Puppet::Util::NetworkDevice; end

module Puppet::Util::NetworkDevice::Cisco_ios # rubocop:disable Style/ClassAndModuleCamelCase
  # The main class for handling the connection and command parsing to the IOS Catalyst device
<<<<<<< HEAD
  class Device < Puppet::ResourceApi::Transport::Wrapper
    def backwards_compatible_schema_load(url_or_config)
      if url_or_config.is_a? String
        url = URI.parse(url_or_config)
        raise "Unexpected url '#{url_or_config}' found. Only file:/// URLs for configuration supported at the moment." unless url.scheme == 'file'
        raise "Trying to load config from '#{url.path}, but file does not exist." if url && !File.exist?(url.path)
        url_or_config = self.class.deep_symbolize(Hocon.load(url.path, syntax: Hocon::ConfigSyntax::HOCON) || {})
      end

      # Allow for backwards compatibility with the fields
      # - address  (map to host)
      # - username (map to user)
      if url_or_config[:address]
        unless url_or_config[:host]
          url_or_config[:host] = url_or_config[:address]
=======
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    attr_reader :connection
    attr_accessor :transport, :facts, :commands

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
          ModeState::CONF_EXT_NACL].include?(mode_in)
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
        enable_cmd = { 'String' => 'enable', 'Match' => %r{.*#|.*:} }
        prompt = send_command(connection, enable_cmd, true)
        # Do not send password unless requried
        unless prompt =~ %r{#$} || @enable_password.nil?
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
>>>>>>> (FM-7740) Add XE functionality for ios_aaa_accounting
        end
        url_or_config.delete(:address)
      end

      if url_or_config[:username]
        unless url_or_config[:user]
          url_or_config[:user] = url_or_config[:username]
        end
        url_or_config.delete(:username)
      end
      url_or_config
    end

    def initialize(url_or_config, _options = {})
      super('cisco_ios', backwards_compatible_schema_load(url_or_config))
    end
  end
end

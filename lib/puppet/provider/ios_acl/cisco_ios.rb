require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure Access Lists on the device
class Puppet::Provider::IosAcl::CiscoIos
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.parse_standard(split_output, instance)
    unless split_output.nil?
      next_token = split_output.shift
      if next_token == 'any'
        instance[:source_address_any] = true
      elsif next_token == 'host'
        instance[:source_address_host] = split_output.shift
      else
        instance[:source_address] = next_token
        if split_output[0] =~ %r{(^\d+[.]\d+[.]\d+[.]\d+$)}
          instance[:source_address_wildcard_mask] = split_output.shift
        end
      end
    end

    if split_output.shift == 'log'
      instance[:log] = true
    end

    instance
  end

  def self.parse_extended(split_output, instance)
    tcp_port_types = ['bgp', 'chargen', 'cifs', 'citrix-ica', 'cmd', 'ctiqbe', 'daytime', 'discard', 'domain', 'echo', 'exec', 'finger', 'ftp', 'ftp-data', 'gopher', 'h323', 'hostname', 'http',
                      'https', 'ident', 'imap4', 'irc', 'kerberos', 'klogin', 'kshell', 'ldap', 'ldaps', 'login', 'lotusnotes', 'lpd', 'netbios-ssn', 'nfs', 'nntp', 'pcanywhere-data', 'pim-auto-rp',
                      'pop2', 'pop3', 'pptp', 'rsh', 'rtsp', 'sip', 'smtp', 'sqlnet', 'ssh', 'sunrpc', 'tacacs', 'talk', 'telnet', 'uucp', 'whois', 'www']
    udp_port_types = ['biff', 'bootpc', 'bootps', 'discard', 'dnsix', 'domain', 'echo', 'isakmp', 'mobile-ip', 'nameserver', 'netbios-dgm', 'netbios-ns', 'netbios-ss', 'ntp', 'pim-auto-rp', 'rip',
                      'snmp', 'snmptrap', 'sunrpc', 'syslog', 'tacacs', 'talk', 'tftp', 'time', 'who', 'xdmcp']
    icmp_types = ['administratively-prohibited', 'alternate-address', 'conversion-error', 'dod-host-prohibited', 'dod-net-prohibited', 'echo', 'echo-reply', 'general-parameter-problem',
                  'host-isolated', 'host-precedence-unreachable', 'host-redirect', 'host-tos-redirect', 'host-tos-unreachable', 'host-unknown', 'host-unreachable', 'information-reply',
                  'information-request', 'mask-reply', 'mask-request', 'mobile-redirect', 'net-redirect', 'net-tos-redirect', 'net-tos-unreachable', 'net-unreachable', 'network-unknown',
                  'no-room-for-option', 'option-missing', 'packet-too-big', 'parameter-problem', 'port-unreachable', 'precedence-unreachable', 'protocol-unreachable', 'reassembly-timeout',
                  'redirect', 'router-advertisement', 'router-solicitation', 'source-quench', 'source-route-failed', 'time-exceeded', 'timestamp-reply', 'timestamp-request', 'traceroute',
                  'ttl-exceeded', 'unreachable']
    igmp_types = ['dvmrp', 'host-query', 'host-report', 'mtrace', 'mtrace-response', 'pim', 'trace', 'v2-leave', 'v2-report', 'v3-report']

    instance[:protocol] = split_output.shift

    unless split_output.nil?
      next_token = split_output.shift
      if next_token == 'any'
        instance[:source_address_any] = true
      elsif next_token == 'host'
        instance[:source_address_host] = split_output.shift
      elsif next_token == 'addrgroup'
        instance[:source_address_group] = split_output.shift
      elsif split_output[0] =~ %r{(^\d+[.]\d+[.]\d+[.]\d+$)}
        instance[:source_address] = next_token
        if split_output[0] =~ %r{(^\d+[.]\d+[.]\d+[.]\d+$)}
          instance[:source_address_wildcard_mask] = split_output.shift
        end
      end

      next_token = split_output.shift
      if next_token == 'eq'
        instance[:source_eq] = []
        while split_output[0] && (split_output[0] =~ %r{(^\d+$)} || tcp_port_types.include?(split_output[0]) || udp_port_types.include?(split_output[0]))
          instance[:source_eq] << split_output.shift
        end
        next_token = split_output.shift
      elsif next_token == 'gt'
        instance[:source_gt] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'lt'
        instance[:source_lt] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'neq'
        instance[:source_neq] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'portgroup'
        instance[:source_portgroup] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'range'
        instance[:source_range] = []
        instance[:source_range] << split_output.shift
        instance[:source_range] << split_output.shift
        next_token = split_output.shift
      end
      if next_token == 'any'
        instance[:destination_address_any] = true
      elsif next_token == 'host'
        instance[:destination_address_host] = split_output.shift
      elsif next_token == 'addrgroup'
        instance[:destination_address_group] = split_output.shift
      elsif split_output[0] =~ %r{(^\d+[.]\d+[.]\d+[.]\d+$)}
        instance[:destination_address] = next_token
        if split_output[0] =~ %r{(^\d+[.]\d+[.]\d+[.]\d+$)}
          instance[:destination_address_wildcard_mask] = split_output.shift
        end
      end

      next_token = split_output.shift
      if next_token == 'eq'
        instance[:destination_eq] = []
        while split_output[0] && (split_output[0] =~ %r{(^\d+$)} || tcp_port_types.include?(split_output[0]) || udp_port_types.include?(split_output[0]))
          instance[:destination_eq] << split_output.shift
        end
        next_token = split_output.shift
      elsif next_token == 'gt'
        instance[:destination_gt] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'lt'
        instance[:destination_lt] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'neq'
        instance[:destination_neq] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'portgroup'
        instance[:destination_portgroup] = split_output.shift
        next_token = split_output.shift
      elsif next_token == 'range'
        instance[:destination_range] = []
        instance[:destination_range] << split_output.shift
        instance[:destination_range] << split_output.shift
        next_token = split_output.shift
      end
    end

    until next_token.nil?
      if next_token == 'ack'
        instance[:ack] = true
      elsif next_token == 'dscp'
        instance[:dscp] = split_output.shift
      elsif next_token == 'fin'
        instance[:fin] = true
      elsif next_token == 'fragments'
        instance[:fragments] = true
      elsif next_token == 'log'
        instance[:log] = true
      elsif next_token == 'log-input'
        instance[:log_input] = true
      elsif next_token == 'lt'
        instance[:lt] = split_output.shift
      elsif next_token == 'match-all'
        instance[:match_all] = []
        while split_output[0][0] == '-' || split_output[0][0] == '+'
          instance[:match_all] << split_output.shift
          break if split_output.empty?
        end
      elsif next_token == 'match-any'
        instance[:match_any] = []
        while split_output[0][0] == '-' || split_output[0][0] == '+'
          instance[:match_any] << split_output.shift
          break if split_output.empty?
        end
      elsif next_token == 'option'
        instance[:option] = split_output.shift
      elsif next_token == 'precedence'
        instance[:precedence] = split_output.shift
      elsif next_token == 'psh'
        instance[:psh] = true
      elsif next_token == 'reflect'
        instance[:reflect] = split_output.shift
        if split_output[0] == 'timeout'
          split_output.shift
          instance[:reflect_timeout] = split_output.shift
        end
      elsif next_token == 'rst'
        instance[:rst] = true
      elsif next_token == 'syn'
        instance[:syn] = true
      elsif next_token == 'time-range'
        instance[:time_range] = split_output.shift
      elsif next_token == 'tos'
        instance[:tos] = split_output.shift
      elsif next_token == 'urg'
        instance[:urg] = true
      elsif instance[:protocol] == 'icmp' && (next_token =~ %r{(^\d+$)} || icmp_types.include?(next_token))
        instance[:icmp_message_type] = next_token
        if split_output[0] =~ %r{(^\d+$)}
          instance[:icmp_message_code] = split_output.shift
        end
      elsif instance[:protocol] == 'igmp' && (next_token =~ %r{(^\d+$)} || igmp_types.include?(next_token))
        instance[:igmp_message_type] = next_token
      # If we reach the end with a matches summary
      # eg. (188 matches)
      # (time left 295)
      # Then break
      elsif next_token =~ %r{^\(\S*$}
        break
      end

      next_token = split_output.shift
    end

    instance
  end

  def self.type_of_access_list(output)
    output.scan(%r{(\S*) IP access list.*}).flatten.first.downcase
  end

  def self.name_of_access_list(output)
    output.scan(%r{.*IP access list\s+(\S+)}).flatten.first
  end

  def self.instances_from_cli(output)
    new_instance_fields = []

    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      acl_name = name_of_access_list(raw_instance_fields)
      acl_type = type_of_access_list(raw_instance_fields)
      acl_entries = raw_instance_fields.scan(%r{\n (.*)})

      acl_entries.flatten.each do |raw_acl_entry|
        new_instance = {}
        split_output = raw_acl_entry.split

        next_token = split_output.shift
        next unless next_token =~ %r{^\d+$}
        new_instance[:entry] = next_token
        next_token = split_output.shift

        if next_token.casecmp('dynamic').zero?
          new_instance[:dynamic] = split_output.shift
          next_token = split_output.shift
        end

        new_instance[:permission] = next_token
        if new_instance[:permission].casecmp('evaluate').zero?
          new_instance[:evaluation_name] = split_output.shift
        end
        new_instance[:title] = "#{acl_name} #{acl_type} #{new_instance[:entry]}"
        new_instance[:access_list] = acl_name
        new_instance[:access_list_type] = acl_type
        new_instance[:ensure] = 'present'

        new_instance = if acl_type != 'extended' && !new_instance[:permission].casecmp('evaluate').zero?
                         parse_standard(split_output, new_instance)
                       else
                         parse_extended(split_output, new_instance)
                       end

        new_instance.delete_if { |_k, v| v.nil? }
        new_instance_fields << new_instance
      end
    end
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    commands = []

    # some validation
    if instance[:access_list_type] == 'extended'
      raise "ios_acl requires 'source_address_wildcard_mask' to be set alongside 'source_address' " if (!instance[:source_address].nil? && instance[:source_address_wildcard_mask].nil?) ||
                                                                                                       (instance[:source_address].nil? && !instance[:source_address_wildcard_mask].nil?)
      raise "ios_acl requires 'destination_address_wildcard_mask' to be set alongside 'destination_address' " if (!instance[:destination_address].nil? &&
                                                                                                                        instance[:destination_address_wildcard_mask].nil?) ||
                                                                                                                 (instance[:destination_address].nil? &&
                                                                                                                  !instance[:destination_address_wildcard_mask].nil?)
      raise 'Either Source Address, address object-group, any or source host are required.' if instance[:source_address].nil? &&
                                                                                               instance[:source_address_group].nil? &&
                                                                                               instance[:source_address_any].nil? &&
                                                                                               instance[:source_address_host].nil? && !instance[:permission].casecmp('evaluate').zero?
      raise 'Either log or log_input can be set, but not both' if !instance[:log].nil? && !instance[:log_input].nil?
      raise 'reflect_timeout requires reflect entry to be set' if !instance[:relect_timeout].nil? && instance[:relfect].nil?
      raise 'protocol must be icmp to set icmp_message_type' if instance[:protocol] && !instance[:protocol].casecmp('icmp') && instance[:icmp_message_type]
      raise 'protocol must be igmp to set igmp_message_type' if instance[:protocol] && !instance[:protocol].casecmp('igmp') && instance[:igmp_message_type]
    end

    unless instance[:icmp_message_type].to_s =~ %r{(^\d+$)}
      if instance[:icmp_message_code]
        warn 'icmp_message_code can only be set when icmp_message_type is an Integer'
        instance[:icmp_message_code] = nil
      end
    end

    if instance[:permission] && instance[:permission].casecmp('evaluate').zero?
      command_line = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, 'evaluation_name', 'set_value', false)
      command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command_line, 'evaluation_name', instance[:evaluation_name], false)
      command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command, 'entry', instance[:entry], false)
    else
      # some tidyup
      unless instance[:dynamic].nil?
        instance[:dynamic] = "Dynamic #{instance[:dynamic]}"
      end
      unless instance[:source_address_host].nil?
        instance[:source_address_host] = "host #{instance[:source_address_host]}"
      end
      unless instance[:source_address_group].nil?
        instance[:source_address_group] = "addrgroup #{instance[:source_address_group]}"
      end
      unless instance[:source_address_any].nil?
        if instance[:source_address_any]
          instance[:source_address_any] = 'any'
        end
      end
      unless instance[:source_eq].nil?
        instance[:source_eq] = "eq #{instance[:source_eq].join(' ')}"
      end
      unless instance[:source_gt].nil?
        instance[:source_gt] = "gt #{instance[:source_gt]}"
      end
      unless instance[:source_lt].nil?
        instance[:source_lt] = "lt #{instance[:source_lt]}"
      end
      unless instance[:source_neq].nil?
        instance[:source_neq] = "neq #{instance[:source_neq]}"
      end
      unless instance[:source_portgroup].nil?
        instance[:source_portgroup] = "portgroup #{instance[:source_portgroup]}"
      end
      unless instance[:source_range].nil?
        instance[:source_range] = "range #{instance[:source_range][0]} #{instance[:source_range][1]}"
      end
      unless instance[:destination_address_host].nil?
        instance[:destination_address_host] = "host #{instance[:destination_address_host]}"
      end
      unless instance[:destination_address_group].nil?
        instance[:destination_address_group] = "addrgroup #{instance[:destination_address_group]}"
      end
      unless instance[:destination_address_any].nil?
        if instance[:destination_address_any] == true
          instance[:destination_address_any] = 'any'
        end
      end
      unless instance[:destination_eq].nil?
        instance[:destination_eq] = "eq #{instance[:destination_eq].join(' ')}"
      end
      unless instance[:destination_gt].nil?
        instance[:destination_gt] = "gt #{instance[:destination_gt]}"
      end
      unless instance[:destination_lt].nil?
        instance[:destination_lt] = "lt #{instance[:destination_lt]}"
      end
      unless instance[:destination_neq].nil?
        instance[:destination_neq] = "neq #{instance[:destination_neq]}"
      end
      unless instance[:destination_portgroup].nil?
        instance[:destination_portgroup] = "portgroup #{instance[:destination_portgroup]}"
      end
      unless instance[:destination_range].nil?
        instance[:destination_range] = "range #{instance[:destination_range][0]} #{instance[:destination_range][1]}"
      end
      unless instance[:ack].nil?
        instance[:ack] = 'ack'
      end
      unless instance[:dscp].nil?
        instance[:dscp] = "dscp #{instance[:dscp]}"
      end
      unless instance[:fin].nil?
        instance[:fin] = 'fin'
      end
      unless instance[:fragments].nil?
        instance[:fragments] = 'fragments'
      end
      unless instance[:log].nil?
        instance[:log] = 'log'
      end
      unless instance[:log_input].nil?
        instance[:log_input] = 'log_input'
      end
      unless instance[:match_all].nil?
        instance[:match_all] = "match-all #{instance[:match_all].join(' ')}"
      end
      unless instance[:match_any].nil?
        instance[:match_any] = "match-any #{instance[:match_any].join(' ')}"
      end
      unless instance[:option].nil?
        instance[:option] = "option #{instance[:option]}"
      end
      unless instance[:precedence].nil?
        instance[:precedence] = "precedence #{instance[:precedence]}"
      end
      unless instance[:psh].nil?
        instance[:psh] = 'psh'
      end
      unless instance[:reflect].nil?
        instance[:reflect] = "reflect #{instance[:reflect]}"
      end
      unless instance[:reflect_timeout].nil?
        instance[:reflect_timeout] = "timeout #{instance[:reflect_timeout]}"
      end
      unless instance[:rst].nil?
        instance[:rst] = 'rst'
      end
      unless instance[:syn].nil?
        instance[:syn] = 'syn'
      end
      unless instance[:time_range].nil?
        instance[:time_range] = "time-range #{instance[:time_range]}"
      end
      unless instance[:tos].nil?
        instance[:tos] = "tos #{instance[:tos]}"
      end
      unless instance[:urg].nil?
        instance[:urg] = 'urg'
      end
      command = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
    end

    if instance[:ensure].to_s == 'absent'
      command = 'no ' + command
    end
    commands << command
    commands
  end

  def commands_hash
    self.class.commands_hash
  end

  def get(context)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, self.class.instances_from_cli(output))
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
      should = change[:should]
      if should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name, is)
        end
      else
        context.updating(name) do
          update(context, name, is, should)
        end
      end
    end
  end

  def update(context, name, is, should)
    if is[:ensure] == 'present'
      delete(context, name, is)
    end
    array_of_commands_to_run = self.class.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_acl_mode(should[:access_list], should[:access_list_type], command)
    end
  end

  def delete(context, _name, is)
    is[:ensure] = 'absent'
    # this will delete the entry
    array_of_commands_to_run = self.class.commands_from_instance(is)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_acl_mode(is[:access_list], is[:access_list_type], command)
    end

    # Check if this was the last entry that used the access list
    command_line = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'cleanup_check')
    command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command_line, 'access_list', is[:access_list], false)
    check = context.transport.run_command_enable_mode(command)

    # check will return the command and the command prompt if there are no other entries
    return unless check.lines.count == 2

    # this will delete the access list
    command_line = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'delete_command_default')
    command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command_line, 'access_list_type', is[:access_list_type], false)
    command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command, 'access_list', is[:access_list], false)
    context.transport.run_command_conf_t_mode(command)
  end

  def canonicalize(_context, resources)
    # if the puppet file contains an optional boolean with a false,
    # remove it so that we don't break idempotency i.e. <blank> changed to 'false'
    bool_attrs = [:source_address_any, :destination_address_any, :ack, :fin, :fragments, :log, :log_input, :psh, :rst, :urg]
    resources.each do |resource|
      bool_attrs.each do |attr|
        resource.reject! { |key| key == attr && resource[key] == false }
      end
    end
    resources
  end
end

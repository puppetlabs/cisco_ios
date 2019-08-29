require 'puppet_x'
if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.3.0')
  require 'backport_dig'
end

module PuppetX::CiscoIOS
  # Helper functions for the Cisco IOS module
  class Utility
    def self.load_yaml(full_path, replace_double_escapes = true)
      raise "File #{full_path} doesn't exist." unless File.exist?(full_path)
      yaml_file = File.read(full_path)
      data_hash = YAML.safe_load(yaml_file, [Symbol])
      data_hash = replace_double_escapes(data_hash) if replace_double_escapes
      data_hash
    end

    def self.replace_double_escapes(data_hash)
      data_hash.each_pair do |key, value|
        if value.is_a?(Hash)
          replace_double_escapes(value)
        elsif value.is_a?(String)
          data_hash[key] = value.gsub(%r{\\\\}, '\\')
        end
      end
      data_hash
    end

    def self.os_family_match_ok(exclusion_hash)
      exclusion_hash.each do |exclusion|
        next if exclusion['os_family'].nil?
        next unless PuppetX::CiscoIOS::Utility.ios_os_family_type =~ %r{#{exclusion['os_family']}}
        return false
      end
      true
    end

    def self.version_match_ok
      true
    end

    # Return false if the device is on the exclusion list true otherwise
    def self.device_match_ok(exclusion_hash)
      exclusion_hash.each do |exclusion|
        next if exclusion['device'].nil?
        next unless PuppetX::CiscoIOS::Utility.ios_device_type =~ %r{#{exclusion['device']}}
        return false
      end
      true
    end

    def self.safe_to_run(exclusion_hash)
      version_match_ok && device_match_ok(exclusion_hash) && os_family_match_ok(exclusion_hash)
    end

    def self.facts(facts) # rubocop:disable Style/TrivialAccessors
      @facts = facts
    end

    def self.ios_device_type
      unless @facts.nil? || @facts['hardwaremodel'].nil?
        device_type = @facts['hardwaremodel'][%r{(\d\d\d\d)}, 1]
        return device_type
      end
      'default'
    end

    def self.ios_os_family_type
      if @facts && !@facts['os']['family'].nil?
        family_type = @facts['os']['family'][%r{(?:,\s*)(([^,]*))}, 1]
        return family_type
      end
      'default'
    end

    # for a command_hash entry try to retrive advice specific value first then the default value
    # ---
    # delete_values:
    #  '4948': 'no snmp-server host <name> <username> <port> <vrf> <type> <version> <security>'
    #  default: 'no snmp-server host <name> <port> <vrf> <type> <version> <security> <username>'
    def self.value_foraged_from_command_hash(command_hash, top_level_key)
      device_type = PuppetX::CiscoIOS::Utility.ios_device_type
      # see if there is a device specific entry
      unless device_type.nil?
        return_val = command_hash.dig(top_level_key, device_type)
      end
      # if not try default
      if return_val.nil?
        return_val = command_hash.dig(top_level_key, 'default')
      end
      raise "This key 'command_hash => #{top_level_key} => #{device_type}/default' is not in the #{command_hash}" if return_val.nil?
      return_val
    end

    # Raise an error is a resource wide exclusion, otherwise return true
    def self.resource_safe_for_device(commands_hash)
      if commands_hash['exclusions'].is_a? Array
        device_type = PuppetX::CiscoIOS::Utility.ios_device_type
        commands_hash['exclusions'].each do |exclusion|
          raise "This device #{PuppetX::CiscoIOS::Utility.ios_device_type} is not capable of running this resource and associated commands" if exclusion['device'] == device_type
        end
      end
      true
    end

    # for a command_hash entry try to retrive advice specific attribute value first then the default value
    # ---
    # attributes:
    #   mtu:
    #     '4948':
    #       get_value: 'regex for mtu'
    #     'default:
    #       get_value: 'different regex for mtu'
    def self.attribute_value_foraged_from_command_hash(command_hash, attribute, key, attribute_can_be_nil = false)
      device_type = PuppetX::CiscoIOS::Utility.ios_device_type
      # see if there is a device specific entry
      unless device_type.nil?
        return_val = command_hash.dig('attributes', attribute, device_type, key)
      end
      # if not try default
      if return_val.nil?
        return_val = command_hash.dig('attributes', attribute, 'default', key)
      end
      if !attribute_can_be_nil && return_val.nil?
        raise "This key 'command_hash => attributes => #{attribute} => #{device_type}/default => #{key}' is not in the #{command_hash}"
      end
      return_val
    end

    def self.get_interface_names(command_hash)
      value_foraged_from_command_hash(command_hash, 'get_interfaces_command')
    end

    def self.get_values(command_hash)
      value_foraged_from_command_hash(command_hash, 'get_values')
    end

    def self.get_instances(command_hash)
      value_foraged_from_command_hash(command_hash, 'get_instances')
    end

    def self.parse_resource(output, command_hash)
      attributes_hash = {}
      attributes = command_hash.dig('attributes')
      raise "This key 'command_hash => attributes' is not in the #{command_hash}" if attributes.nil?
      attributes.each do |attribute|
        value = parse_attribute(output, command_hash, attribute.first)
        attributes_hash[attribute.first.to_sym] = value
      end
      attributes_hash
    end

    def self.attribute_safe_to_run(command_hash, attribute)
      device_type = PuppetX::CiscoIOS::Utility.ios_device_type
      exclusions = command_hash.dig('attributes', attribute, 'exclusions')
      # try device specific command
      attribute_is_empty = command_hash.dig('attributes', attribute, device_type).nil?
      # try default command
      attribute_is_empty = command_hash.dig('attributes', attribute, 'default').nil? if attribute_is_empty
      if !exclusions.nil? && (!safe_to_run(exclusions) || attribute_is_empty)
        Puppet.debug "This attribute '#{attribute}', is not available for this device "\
                     "'#{@facts['hardwaremodel']}'"\
                     ", version '#{@facts['operatingsystemrelease']}' "\
                     "and/or OS family '#{@facts['os']['family']}'"
        return false
      end
      true
    end

    def self.parse_attribute(output, commands_hash, attribute)
      return unless attribute_safe_to_run(commands_hash, attribute)
      default_value = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, attribute, 'default', true)
      optional_match = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, attribute, 'optional_match', true)
      multiline = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, attribute, 'multiline', true)
      regex = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, attribute, 'get_value')
      returned_value = if regex.nil?
                         []
                       elsif multiline
                         output.scan(%r{#{regex}}m)
                       else
                         output.scan(%r{#{regex}})
                       end
      if returned_value.empty?
        # there is no match
        if optional_match
          # it is ok for this attribute to return nil
          returny = nil
        elsif default_value
          # use the default value
          returny = default_value
        else
          Puppet.debug "Regex for attribute '#{attribute}' failed"
        end
      elsif returned_value.size == 1
        # there is a single match
        returny = returned_value.flatten.first
      else
        # we have an array of matches.
        returny = returned_value.flatten
      end
      returny
    end

    # build a single command_line from attributes
    def self.set_values(instance, commands_hash)
      PuppetX::CiscoIOS::Utility.resource_safe_for_device(commands_hash)
      command_line = if !commands_hash['delete_values'].nil? && instance[:ensure] == 'absent'
                       PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'delete_values')
                     else
                       PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'set_values')
                     end
      # Set the state, of the commandline eg 'no ntp server
      if !commands_hash['ensure_is_state'].nil? && !PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'ensure_is_state').nil?
        command_line = if instance[:ensure] == 'present'
                         command_line.to_s.gsub(%r{<state>}, '')
                       else
                         command_line.to_s.gsub(%r{<state>}, 'no')
                       end
      end
      instance.each do |key, value|
        # if print_key exists then print the key, otherwise dont
        print_key = if key == :ensure
                      false
                    else
                      # if print_key exists then print the key, otherwise dont
                      !PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, key.to_s, 'print_key', true).nil?
                    end
        command_line = insert_attribute_into_command_line(command_line, key, value, print_key) if key == :ensure || PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, key.to_s)
      end
      command_line = command_line.to_s.gsub(%r{<\S*>}, '')
      command_line = command_line.strip
      command_line
    end

    def self.build_commmands_from_attribute_set_values(instance, commands_hash)
      command_lines = []
      # check to see if the device can run the command at all
      PuppetX::CiscoIOS::Utility.resource_safe_for_device(commands_hash)
      instance.each do |key, value|
        if key != :ensure && !commands_hash.dig('attributes', key.to_s, 'exclusions').nil?
          next unless attribute_safe_to_run(commands_hash, key.to_s)
        end

        command_line = ''
        # if print_key exists then print the key, otherwise dont
        print_key = false
        if value == 'unset'
          command_line = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, key.to_s, 'unset_value', true)
        elsif key != :ensure
          command_line = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, key.to_s, 'set_value', true)
          # if print_key exists then print the key, otherwise dont
          print_key = !PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, key.to_s, 'print_key', true).nil?
        end
        command_line = insert_attribute_into_command_line(command_line, key, value, print_key)
        command_line = command_line.to_s.gsub(%r{<\S*>}, '')
        command_line = command_line.strip
        command_lines << command_line if command_line != ''
      end
      command_lines
    end

    def self.insert_attribute_into_command_line(command_line, key, value, print_key)
      command_line = if value.nil?
                       # no value so remove the key from the command_line
                       command_line.to_s.gsub(%r{<#{key}>}, '')
                     elsif print_key
                       command_line.to_s.gsub(%r{<#{key}>}, value ? "#{key} #{value}" : '')
                     else
                       command_line.to_s.gsub(%r{<#{key}>}, value ? value.to_s : '')
                     end
      command_line
    end

    def self.detect_ipv4_or_ipv6(address)
      # Is it IPv4?
      return "ipv4 #{address}" if address =~ Resolv::IPv4::Regex
      # Is it IPv6?
      return "ipv6 #{address}" if address =~ Resolv::IPv6::Regex
      # Some other type of hostname that is neither IPv4 or IPv6, just return
      address
    end

    def self.convert_no_to_boolean(value)
      return_value = if value.nil?
                       true
                     else
                       false
                     end
      return_value
    end

    def self.convert_enable_to_string(enable_value)
      return_value = if enable_value == false
                       'no'
                     else
                       ''
                     end
      return_value
    end

    def self.convert_level_name_to_int(level_enum)
      level = if level_enum == 'debugging'
                7
              elsif level_enum == 'informational'
                6
              elsif level_enum == 'notifications'
                5
              elsif level_enum == 'warnings'
                4
              elsif level_enum == 'errors'
                3
              elsif level_enum == 'critical'
                2
              elsif level_enum == 'alerts'
                1
              elsif level_enum == 'emergencies'
                0
              else
                raise "Cannot convert logging level '#{level_enum}' to an integer."
              end
      level
    end

    def self.convert_speed_int_to_modelled_value(speed_value)
      speed = if speed_value == '10'
                '10m'
              elsif speed_value == '100'
                '100m'
              elsif speed_value == '1000'
                '1g'
              else
                speed_value
              end
      speed
    end

    def self.convert_modelled_speed_value_to_int(speed_value)
      speed_value = if speed_value == '10m'
                      '10'
                    elsif speed_value == '100m'
                      '100'
                    elsif speed_value == '1g'
                      '1000'
                    else
                      speed_value
                    end
      speed_value
    end

    def self.commands_from_diff_of_two_arrays(commands_hash, is, should, attribute)
      is = [] if is.nil?
      should = [] if should.nil?

      new_entities =  should - is
      remove_entities = is - should

      array_of_commands = []

      new_entities.each do |new_entity|
        add_command = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, attribute, 'set_value')
        add_command = add_command.gsub(%r{<#{attribute}>}, new_entity.to_s).strip
        array_of_commands.push(add_command)
      end

      remove_entities.each do |remove_entity|
        remove_command = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, attribute, 'unset_value')
        remove_command = remove_command.gsub(%r{<#{attribute}>}, remove_entity.to_s)
        array_of_commands.push(remove_command)
      end
      array_of_commands
    end

    def self.convert_network_trunk_mode_cli(trunk_mode_output)
      if trunk_mode_output == 'dynamic auto'
        trunk_mode_output = 'dynamic_auto'
      elsif trunk_mode_output == 'dynamic desirable'
        trunk_mode_output = 'dynamic_desirable'
      elsif trunk_mode_output == 'static access'
        trunk_mode_output = 'access'
      end
      trunk_mode_output
    end

    def self.convert_network_trunk_mode_modelled(trunk_mode_output)
      if trunk_mode_output == 'dynamic_auto'
        trunk_mode_output = 'dynamic auto'
      elsif trunk_mode_output == 'dynamic_desirable'
        trunk_mode_output = 'dynamic desirable'
      end
      trunk_mode_output
    end

    # Parses tuple values
    # convert_position_to_integer converts any value at array position 'x' to an integer
    # eg. ['5', 'test_value'] with convert_position_to_integer 0 will return [5, 'test_value']
    def self.parse_multiples(output, commands_hash, attribute, convert_position_to_integer = nil)
      return_value = output.scan(%r{#{PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, attribute, 'get_value')}})
      unless convert_position_to_integer.nil?
        return_value.each do |value|
          value[convert_position_to_integer] = value[convert_position_to_integer].to_i
        end
      end
      if return_value.empty?
        return nil
      end
      return_value
    end

    def self.set_tuple_values(instance, commands_hash, name, first_value, second_value)
      commands = []
      unless instance[name.to_sym].nil?
        if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, name) && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, name)
          instance[name.to_sym].each do |a, b|
            command = PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, name, 'set_value')
            command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command, first_value, a, false)
            command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(command, second_value, b, false)
            commands.push(command)
          end
        end
        # remove from instance, so we dont add twice
        instance.delete(name.to_sym)
      end
      commands
    end

    def self.instances_contains_name(instances, name)
      instances.each do |instance|
        if instance[:name] == name
          return true
        end
      end
      false
    end

    def self.generate_server_groups_command_string(instance)
      return '' if instance[:server_groups].nil?
      server_groups_string = ''
      instance[:server_groups].each do |server_group|
        server_groups_string += " group #{server_group}"
      end
      server_groups_string
    end

    def self.get_interface_status_command(commands_hash, name)
      instance_status_command = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_speed_status')
      instance_status_command.gsub(%r{<name>}, name)
    end

    def self.convert_to_offsets(widths, line_length, min_field_size)
      offsets = []
      position = 0

      total_title_width = 0
      widths.each do |width|
        total_title_width += width
      end

      if total_title_width < line_length
        widths[-1] = line_length - total_title_width + widths.last
      end

      widths.each.with_index do |width, index|
        # If field is less than minimum size, get from previous field.
        # Used for the right hand justified Interface status - Speed column
        while width < min_field_size
          widths[index] = widths[index] + 1
          widths[index - 1] = widths[index - 1] - 1
          width = widths[index]
        end
      end
      widths.each.with_index do |width, _index|
        offsets << (position...(width + position))
        position += width
      end

      offsets
    end

    def self.extract_values(line, offsets)
      return if line.nil? || line.empty?
      offsets.map { |range| line[range].strip }
    end

    def self.read_table(table, min_field_size = 7)
      lines = table.lstrip.split "\n"
      return nil unless lines.size >= 5
      fields = lines[2].split %r{\s+}
      title_widths = lines[2].scan(%r{(\S+\s*)}).flatten.map(&:length)

      lines[3..-2].map do |line|
        next if line.empty?
        offsets = convert_to_offsets(title_widths, line.length, min_field_size)
        values = extract_values line, offsets
        Hash[*fields.zip(values).flatten]
      end
    end

    def self.device_safe_instance(change, commands_hash)
      new_should = {}
      change.each do |key, value|
        next unless PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, key.to_s)
        new_should[key] = value
      end
      if change[:name]
        new_should[:name] = change[:name]
      end
      if change[:ensure]
        new_should[:ensure] = change[:ensure]
      end
      new_should
    end

    def self.enforce_simple_types(context, return_value)
      return_value.each do |individual_value_hash|
        individual_value_hash.each do |k, v|
          type_to_use = context.type.definition[:attributes][k][:type]

          string_t = Puppet::Pops::Types::TypeFactory.string
          boolean_t = Puppet::Pops::Types::TypeFactory.boolean

          calculated_type = Puppet::Pops::Types::TypeParser.new.parse(type_to_use)

          # Are you an integer?
          int_result = begin
            Integer(v)
          rescue
            false
          end

          if int_result
            if Puppet::Pops::Types::TypeCalculator.instance?(calculated_type, int_result)
              individual_value_hash[k] = v.to_i
            end
            # Is our type a string?
          elsif Puppet::Pops::Types::TypeCalculator.assignable?(calculated_type, string_t)
            individual_value_hash[k] = v.to_s
            # Is our type a boolean?
          elsif Puppet::Pops::Types::TypeCalculator.assignable?(calculated_type, boolean_t)
            individual_value_hash[k] = if v.to_s.casecmp('true').zero?
                                         true
                                       else
                                         false
                                       end
          end
        end
      end
      return_value
    end

    def self.shorthand_to_full(name)
      shorthand = name[%r{(^[a-zA-Z]{2})}, 1]
      port = name[%r{^[a-zA-Z]{2}(.*$)}, 1]
      full = case shorthand
             when 'Gi'
               'GigabitEthernet'
             when 'Te'
               'TenGigabitEthernet'
             when 'Fa'
               'FastEthernet'
             when 'Po'
               'Port-channel'
             end
      full + port
    end
  end
end

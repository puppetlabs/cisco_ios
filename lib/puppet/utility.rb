require 'pry'
# A set up helper functions for the module
class Puppet::Utility
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

  def self.version_match_ok
    true
  end

  def self.device_match_ok(_exclusion_hash)
    true
  end

  def self.safe_to_run(exclusion_hash)
    # TODO: iterate over the exclusion entries, if any exclusion matched it is not safe and break.
    version_match_ok && device_match_ok(exclusion_hash)
  end

  def self.ios_device_type
    'no_device_for_now'
  end

  def self.parent_device(commands_hash)
    device_type = Puppet::Utility.ios_device_type
    if commands_hash[device_type].nil?
      'default'
    else
      # else use device specific yaml
      device_type
    end
  end

  def self.get_values(command_hash)
    parent_device = parent_device(command_hash)
    return_val = command_hash['get_values'][parent_device]
    # TODO: error check that the attribute exists in the yaml
    return_val
  end

  def self.get_instances(command_hash)
    parent_device = parent_device(command_hash)
    return_val = command_hash['get_instances'][parent_device]
    # TODO: error check that the attribute exists in the yaml
    return_val
  end

  def self.parse_resource(output, command_hash)
    attributes_hash = {}
    command_hash['attributes'].each do |attribute|
      value = parse_attribute(output, command_hash, attribute.first)
      attributes_hash[attribute.first.to_sym] = value
    end
    attributes_hash
  end

  def self.parse_attribute(output, command_hash, attribute)
    # Is there a whole new device in the yaml at the top level
    # eg
    # ---
    # default:
    #  ...
    # nxos:  <---- this is a device specific implementation
    # is there an device version of the attribute

    attribute_device = parent_device(command_hash)
    exclusions = command_hash['attributes'][attribute]['exclusions']
    attribute_is_empty = command_hash['attributes'][attribute][attribute_device].nil?
    if !exclusions.nil? && (!safe_to_run(exclusions) || attribute_is_empty)
      Puppet.debug "This attribute '#{attribute}', is not available for this device '' and/or version ''"
      return
    end

    default_value = command_hash['attributes'][attribute][attribute_device]['default']
    can_have_no_match = command_hash['attributes'][attribute][attribute_device]['can_have_no_match']
    regex = command_hash['attributes'][attribute][attribute_device]['get_value']
    if regex.nil?
      Puppet.debug "Missing key/pair in yaml file for '#{attribute}'.\nExpects:->attributes:->#{attribute}:->#{attribute_device}:->get_value: 'regex here'"
      returned_value = []
    else
      returned_value = output.scan(%r{#{regex}})
    end
    if returned_value.empty?
      # there is no match
      if !can_have_no_match.nil?
        # it is ok for this attribute to return nil
        returny = nil
      elsif !default_value.nil?
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

  # build_command_from_resource_set_value
  def self.set_values(instance, command_hash)
    parent_device = parent_device(command_hash)
    command_line = command_hash['set_values'][parent_device]
    # Set the state, of the commandline eg 'no ntp server
    if command_hash['ensure_is_state'][parent_device]
      command_line = if instance[:ensure] == :present
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
                    !command_hash['attributes'][key.to_s][parent_device]['print_key'].nil?
                  end
      command_line = insert_attribute_into_command_line(command_line, key, value, print_key)
    end
    command_line = command_line.to_s.gsub(%r{<\S*>}, '')
    command_line = command_line.squeeze(' ')
    command_line = command_line.strip
    # TODO: if there is anything that looks like this <.*> it is probably a bug
    command_line
  end

  def self.build_commmands_from_attribute_set_values(instance, command_hash)
    command_lines = []
    parent_device = parent_device(command_hash)
    instance.each do |key, value|
      command_line = ''
      # if print_key exists then print the key, otherwise dont
      print_key = if key == :ensure
                    false
                  else
                    command_line = command_hash['attributes'][key.to_s][parent_device]['set_value']
                    # if print_key exists then print the key, otherwise dont
                    !command_hash['attributes'][key.to_s][parent_device]['print_key'].nil?
                  end
      command_line = insert_attribute_into_command_line(command_line, key, value, print_key)
      command_line = command_line.to_s.gsub(%r{<\S*>}, '')
      command_line = command_line.squeeze(' ')
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

  def self.convert_no_to_boolean(value)
    return_value = if value.nil?
                     true
                   else
                     false
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

  def self.convert_level_int_to_name(level)
    level_enum = if level == 7
                   'debugging'
                 elsif level == 6
                   'informational'
                 elsif level == 5
                   'notifications'
                 elsif level == 4
                   'warnings'
                 elsif level == 3
                   'errors'
                 elsif level == 2
                   'critical'
                 elsif level == 1
                   'alerts'
                 elsif level.zero?
                   'emergencies'
                 else
                   raise "Cannot convert logging name '#{level}' to an named level"
                 end
    level_enum
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

  def self.convert_ntp_config_trusted_key_to_cli(trusted_keys)
    trusted_key_field = []
    if trusted_keys.nil?
      trusted_key_field = trusted_keys
    else
      trusted_keys.each do |trusted_key|
        trusted_key_field << trusted_key
      end
      trusted_key_field = trusted_key_field.sort_by(&:to_i)
      trusted_key_field = trusted_key_field.join(',')
    end
    trusted_key_field
  end

  def self.convert_ntp_config_authenticate(commands_hash, should, parent_device)
    if !should[:authenticate].nil?
      set_command_auth = commands_hash['attributes']['authenticate'][parent_device]['set_value']
      set_command_auth = set_command_auth.gsub(%r{<state>},
                                               (should[:authenticate]) ? '' : 'no ')
    else
      set_command_auth = ''
    end
    set_command_auth
  end

  def self.convert_ntp_config_source_interface(commands_hash, should, parent_device)
    if should[:source_interface]
      set_command_source = commands_hash['attributes']['source_interface'][parent_device]['set_value']
      set_command_source = set_command_source.gsub(%r{<source_interface>},
                                                   (should[:source_interface] == 'unset') ? '' : should[:source_interface])
      set_command_source = set_command_source.gsub(%r{<state>},
                                                   (should[:source_interface] == 'unset') ? 'no ' : '')
    else
      set_command_source = ''
    end
    set_command_source
  end

  def self.convert_ntp_config_keys(commands_hash, is, should, parent_device)
    should_keys = []
    unless should[:trusted_key].nil?
      should_keys = should[:trusted_key].split(',')
    end

    is_keys = []
    unless is[:trusted_key].nil?
      is_keys = is[:trusted_key].split(',')
    end

    new_keys =  should_keys - is_keys
    remove_keys = is_keys - should_keys

    array_of_keys = []

    new_keys.each do |new_key|
      set_new_key = commands_hash['attributes']['trusted_key'][parent_device]['set_value']
      set_new_key = set_new_key.gsub(%r{<state>}, '')
      set_new_key = set_new_key.gsub(%r{<trusted_key>}, new_key)
      array_of_keys.push(set_new_key)
    end

    remove_keys.each do |remove_key|
      set_remove_key = commands_hash['attributes']['trusted_key'][parent_device]['set_value']
      set_remove_key = set_remove_key.gsub(%r{<state>}, 'no ')
      set_remove_key = set_remove_key.gsub(%r{<trusted_key>}, remove_key)
      array_of_keys.push(set_remove_key)
    end
    array_of_keys
  end
end

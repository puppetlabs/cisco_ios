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
      else
        data_hash[key] = value.gsub(%r{\\\\}, '\\')
      end
    end
    data_hash
  end

  def self.version_match_ok
    true
  end

  def self.safe_to_run(_exclusion_hash)
    version_match_ok
    # check device
    true
  end

  def self.get_values(command_hash)
    device_type = 'no_device_for_now'
    parent_device = if command_hash[device_type].nil?
                      'default'
                    else
                      # else use device specific yaml
                      device_type
                    end
    return_val = command_hash['get_values'][parent_device]
    # TODO: error check that the attribute exists in the yaml
    return_val
  end

  def self.get_instances(command_hash)
    device_type = 'no_device_for_now'
    parent_device = if command_hash[device_type].nil?
                      'default'
                    else
                      # else use device specific yaml
                      device_type
                    end
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
    device_type = 'no_device_for_now'

    # is there an device version of the attribute
    attribute_device = if command_hash['attributes'][device_type].nil?
                         'default'
                       else
                         device_type
                       end

    exclusion_hash = command_hash['attributes'][attribute][attribute_device]['excluded']
    default_value = command_hash['attributes'][attribute][attribute_device]['default']
    can_have_no_match = command_hash['attributes'][attribute][attribute_device]['can_have_no_match']
    regex = command_hash['attributes'][attribute][attribute_device]['get_value']
    if regex.nil?
      Puppet.debug "Missing key/pair in yaml file for '#{attribute}'.\nExpects:->attributes:->#{attribute}:->#{attribute_device}:->get_value: 'regex here'"
      returned_value = []
    else
      returned_value = output.scan(%r{#{regex}})
    end
    if safe_to_run(exclusion_hash)
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
    else
      Puppet.debug "This attribute '#{attribute}', is not available for this device '' and/or version ''"
    end
    returny
  end

  def self.ios_device_type
    'no_device_for_now'
  end

  # build_command_from_resource_set_value
  def self.set_values(instance, command_hash)
    device_type = 'no_device_for_now'
    parent_device = if command_hash[device_type].nil?
                      'default'
                    else
                      # else use device specific yaml
                      device_type
                    end
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
    device_type = 'no_device_for_now'
    parent_device = if command_hash[device_type].nil?
                      'default'
                    else
                      # else use device specific yaml
                      device_type
                    end
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
end

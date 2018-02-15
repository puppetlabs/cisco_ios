# A set up helper functions for the module
class Puppet::Utility
  def self.load_yaml(full_path, replace_double_escapes = true)
    raise "File #{full_path} doesn't exist." unless File.exist?(full_path)
    yaml_file = File.read(full_path)
    data_hash = YAML.safe_load(yaml_file)
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

  def self.parse_attribute(output, command_hash, attribute)
    # Is there a whole new device in the yaml at the top level
    # eg
    # ---
    # default:
    #  ...
    # nxos:  <---- this is a device specific implementation
    device_type = 'no_device_for_now'
    parent_device = if command_hash[device_type].nil?
                      'default'
                    else
                      # else use device specific yaml
                      device_type
                    end

    # is there an device version of the attribute
    attribute_device = if command_hash[parent_device]['attributes'][device_type].nil?
                         'default'
                       else
                         device_type
                       end
    exclusion_hash = command_hash[parent_device]['attributes'][attribute][attribute_device]['excluded']
    default_value = command_hash[parent_device]['attributes'][attribute][attribute_device]['default']
    can_have_no_match = command_hash[parent_device]['attributes'][attribute][attribute_device]['can_have_no_match']
    regex = command_hash[parent_device]['attributes'][attribute][attribute_device]['get_value']
    if regex.nil?
      Puppet.debug "Missing key/pair in yaml file for '#{attribute}'.\nExpects:#{parent_device}:->attributes:->#{attribute}:->#{attribute_device}:->get_value: 'regex here'"
      returned_value = nil
    else
      returned_value = output.match(%r{#{regex}})
    end

    if safe_to_run(exclusion_hash)
      if returned_value.nil?
        # there is no match
        if !can_have_no_match.nil?
          # it is ok for this attribute to return nil
          returny = returned_value
        elsif !default_value.nil?
          # use the default value
          returny = default_value
        else
          Puppet.debug "Regex for attribute '#{attribute}' failed"
        end
      elsif returned_value.size > 1
        # there is at least one match
        returny = returned_value[attribute.to_sym]
      else
        # we dont have a nil or a match
        raise 'Something is wrong if we hit this'
      end
    else
      Puppet.debug "This attribute '#{attribute}', is not available for this device '' and/or version ''"
    end
    returny
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

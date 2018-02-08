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
end

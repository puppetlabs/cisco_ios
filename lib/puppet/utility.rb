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
end

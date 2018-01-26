# Helper functions for parsing
class NTPServerParseUtils
  def self.parse(output)
    commands = Puppet::Util::NetworkDevice::Cisco_ios::Device.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    new_instance_fields = []
    output.scan(%r{#{commands['default']['get_instances']}}).each do |raw_instance_fields|
      name_field = raw_instance_fields.match(%r{#{commands['default']['name']['get_value']}})
      key_field = raw_instance_fields.match(%r{#{commands['default']['key']['get_value']}})
      minpoll_field = raw_instance_fields.match(%r{#{commands['default']['minpoll']['get_value']}})
      maxpoll_field = raw_instance_fields.match(%r{#{commands['default']['maxpoll']['get_value']}})
      prefer_field = raw_instance_fields.match(%r{#{commands['default']['prefer']['get_value']}})
      source_field = raw_instance_fields.match(%r{#{commands['default']['source']['get_value']}})

      new_instance = { name: name_field ? name_field[:name] : nil,
                       ensure: :present,
                       key: key_field ? key_field[:key] : nil,
                       minpoll: minpoll_field ? minpoll_field[:minpoll] : nil,
                       maxpoll: maxpoll_field ? maxpoll_field[:maxpoll] : nil,
                       prefer: !prefer_field.nil?,
                       source_interface: source_field ? source_field[:source] : nil }

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.config_command(property_hash)
    set_command = Puppet::Util::NetworkDevice::Cisco_ios::Device.load_yaml(File.expand_path(__dir__) + '/command.yaml')['default']['set_values']

    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<ip>}, property_hash[:name])
    # rubocop:disable Style/TernaryParentheses
    set_command = set_command.to_s.gsub(%r{<key>}, property_hash[:key] ? " key #{property_hash[:key]}" : '')
    set_command = set_command.to_s.gsub(%r{<minpoll>}, property_hash[:minpoll] ? " minpoll #{property_hash[:minpoll]}" : '')
    set_command = set_command.to_s.gsub(%r{<maxpoll>}, property_hash[:maxpoll] ? " maxpoll #{property_hash[:maxpoll]}" : '')
    set_command = set_command.to_s.gsub(%r{<source>}, property_hash[:source_interface] ? " source #{property_hash[:source_interface]}" : '')
    set_command = set_command.to_s.gsub(%r{<prefer>}, property_hash[:prefer] ? ' prefer' : '')
    # rubocop:enable Style/TernaryParentheses
    set_command
  end
end

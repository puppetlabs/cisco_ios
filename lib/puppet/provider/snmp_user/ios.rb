require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# SNMP user Puppet Provider for Cisco IOS devices
class Puppet::Provider::SnmpUser::SnmpUser < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.parse(output)
    new_instance_fields = []
    return new_instance_fields if output.nil? || output.empty?
    output.scan(%r{#{commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      core_user = raw_instance_fields.match(%r{#{commands_hash['default']['core']['get_value']}})
      auth_field = raw_instance_fields.match(%r{#{commands_hash['default']['auth']['get_value']}})
      privacy_field = raw_instance_fields.match(%r{#{commands_hash['default']['privacy']['get_value']}})
      enforce_privacy_field = raw_instance_fields.match(%r{#{commands_hash['default']['enforce_privacy']['get_value']}})

      name_field = ''
      name_field += core_user[:username] + ' '
      name_field += core_user[:version]
      name_field.strip!

      new_instance = { name:  name_field ? name_field : nil,
                       ensure: :present,
                       username: core_user ? core_user[:username] : nil,
                       roles: core_user ? core_user[:roles].strip! : nil,
                       version: core_user ? core_user[:version] : nil,
                       auth: auth_field ? auth_field[:auth] : nil,
                       password: auth_field ? auth_field[:password] : nil,
                       privacy: privacy_field ? privacy_field[:privacy] : nil,
                       enforce_privacy: enforce_privacy_field ? true : nil,
                       private_key: privacy_field ? privacy_field[:private_key] : nil }

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.parse_v3(output)
    new_instance_fields = []
    return new_instance_fields if output.nil? || output.empty?
    output.split("\n\n").each do |raw_instance_fields|
      v3_username = raw_instance_fields.match(%r{#{commands_hash['default']['v3_username']['get_value']}})
      v3_auth = raw_instance_fields.match(%r{#{commands_hash['default']['v3_auth']['get_value']}})
      v3_engine_id = raw_instance_fields.match(%r{#{commands_hash['default']['v3_engine_id']['get_value']}})
      v3_roles = raw_instance_fields.match(%r{#{commands_hash['default']['v3_roles']['get_value']}})
      v3_privacy = raw_instance_fields.match(%r{#{commands_hash['default']['v3_privacy']['get_value']}})

      next if v3_username.nil?
      v3_name = v3_username[:username] + ' v3'
      v3_name.strip!

      new_instance = { name:  v3_name,
                       ensure: :present,
                       username: v3_username ? v3_username[:username] : nil,
                       roles: v3_roles ? v3_roles[:roles] : nil,
                       version: 'v3',
                       auth: v3_auth ? v3_auth[:auth].downcase : nil,
                       privacy: v3_privacy ? v3_privacy[:priv] : nil,
                       engine_id: v3_engine_id ? v3_engine_id[:engine_id] : nil }

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.config_command(property_hash)
    set_command = commands_hash['default']['set_values']

    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<username>}, property_hash[:username])
    # rubocop:disable Style/TernaryParentheses
    set_command = set_command.to_s.gsub(%r{<roles>}, property_hash[:roles] ? " #{property_hash[:roles]}" : '')
    set_command = set_command.to_s.gsub(%r{<version>}, property_hash[:version] ? " #{property_hash[:version]}" : '')
    set_command = set_command.to_s.gsub(%r{<enforce_privacy>}, property_hash[:enforce_privacy] ? ' encrypted' : '')
    set_command = set_command.to_s.gsub(%r{<auth>}, property_hash[:auth] ? " auth #{property_hash[:auth]}" : '')
    set_command = set_command.to_s.gsub(%r{<engine_id>}, property_hash[:engine_id] ? " #{property_hash[:engine_id]}" : '')
    set_command = set_command.to_s.gsub(%r{<password>}, property_hash[:password] ? " #{property_hash[:password]}" : '')
    set_command = set_command.to_s.gsub(%r{<privacy>}, property_hash[:privacy] ? " priv #{property_hash[:privacy]}" : '')
    set_command = set_command.to_s.gsub(%r{<private_key>}, property_hash[:private_key] ? " #{property_hash[:private_key]}" : '')
    # rubocop:enable Style/TernaryParentheses
    set_command.strip!
    set_command.squeeze(' ') unless set_command.nil?
  end

  def commands_hash
    Puppet::Provider::SnmpUser::SnmpUser.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(commands_hash['default']['get_values'])
    output_v3 = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(commands_hash['default']['get_v3_values'])
    (Puppet::Provider::SnmpUser::SnmpUser.parse(output) << Puppet::Provider::SnmpUser::SnmpUser.parse_v3(output_v3)).flatten!
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:id] == name }
      should = change[:should]

      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name) do
          create(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name, is, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name, should)
        end
      end
    end
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.config_command(should))
  end

  def update(_context, _name, is, should)
    # perform a delete on current, then add
    is[:ensure] = :absent
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.config_command(is))
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.config_command(should))
  end

  def delete(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.config_command(should))
  end
end

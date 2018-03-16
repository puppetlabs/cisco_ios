require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet_x/puppetlabs/cisco_ios/utility'
require 'pry'

# SNMP user Puppet Provider for Cisco IOS devices
class Puppet::Provider::SnmpUser::SnmpUser
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    return new_instance_fields if output.nil? || output.empty?
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = :present
      # making a composite key
      name_field = ''
      name_field += new_instance[:user] + ' '
      name_field += new_instance[:version]
      name_field.strip!
      new_instance[:name] = name_field
      new_instance[:roles] = new_instance[:roles].strip!
      new_instance.delete(:user)
      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.instances_from_cli_v3(output)
    new_instance_fields = []
    return new_instance_fields if output.nil? || output.empty?
    output.split("\n\n").each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = :present
      new_instance[:version] = 'v3'

      next if new_instance[:v3_user].nil?
      new_instance[:name] = new_instance[:v3_user] + ' v3'
      new_instance[:roles] = new_instance[:v3_roles] unless new_instance[:v3_roles].nil?
      new_instance[:auth] = new_instance[:v3_auth].downcase unless new_instance[:v3_auth].nil?
      new_instance[:privacy] = new_instance[:v3_privacy] unless new_instance[:v3_privacy].nil?
      new_instance[:engine_id] = new_instance[:v3_engine_id] unless new_instance[:v3_engine_id].nil?
      # remove the v3_ keys
      new_instance.delete_if { |k, _v| k.to_s =~ %r{^v3_} }
      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.command_from_instance(property_hash)
    parent_device = PuppetX::CiscoIOS::Utility.parent_device(commands_hash)
    set_command = commands_hash['set_values'][parent_device]
    raw_user = property_hash[:name].split.first
    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<user>}, raw_user)
    set_command = set_command.to_s.gsub(%r{<roles>},
                                        (property_hash[:roles] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'roles')) ? " #{property_hash[:roles]}" : '')
    set_command = set_command.to_s.gsub(%r{<version>},
                                        (property_hash[:version] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'version')) ? " #{property_hash[:version]}" : '')
    set_command = set_command.to_s.gsub(%r{<enforce_privacy>},
                                        (property_hash[:enforce_privacy] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'enforce_privacy')) ? ' encrypted' : '')
    set_command = set_command.to_s.gsub(%r{<auth>},
                                        (property_hash[:auth] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'auth')) ? " auth #{property_hash[:auth]}" : '')
    set_command = set_command.to_s.gsub(%r{<engine_id>},
                                        (property_hash[:engine_id] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'engine_id')) ? " #{property_hash[:engine_id]}" : '')
    set_command = set_command.to_s.gsub(%r{<password>},
                                        (property_hash[:password] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'password')) ? " #{property_hash[:password]}" : '')
    set_command = set_command.to_s.gsub(%r{<privacy>},
                                        (property_hash[:privacy] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'privacy')) ? " priv #{property_hash[:privacy]}" : '')
    set_command = set_command.to_s.gsub(%r{<private_key>},
                                        (property_hash[:private_key] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'private_key')) ? " #{property_hash[:private_key]}" : '')
    set_command.strip!
    set_command.squeeze(' ') unless set_command.nil?
  end

  def commands_hash
    Puppet::Provider::SnmpUser::SnmpUser.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    output_v3 = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(commands_hash['get_v3_values']['default'])
    (Puppet::Provider::SnmpUser::SnmpUser.instances_from_cli(output) << Puppet::Provider::SnmpUser::SnmpUser.instances_from_cli_v3(output_v3)).flatten!
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
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
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(should))
  end

  def update(_context, _name, is, should)
    # perform a delete on current, then add
    is[:ensure] = :absent
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(is))
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(should))
  end

  def delete(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(should))
  end
end

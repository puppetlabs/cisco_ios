require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet_x/puppetlabs/cisco_ios/utility'
require 'pry'

# SNMP Notification Receiver Puppet Provider for Cisco IOS devices
class Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    commands = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    new_instance_fields = []
    output.scan(%r{#{commands['get_instances']}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands)
      new_instance[:ensure] = :present
      # making a composite key
      name_field = ''
      name_field += new_instance[:host] + ' ' unless new_instance[:host].nil?
      name_field += new_instance[:username] + ' ' unless new_instance[:username].nil?
      name_field += new_instance[:vrf] + ' ' unless new_instance[:vrf].nil?
      name_field += new_instance[:port] + ' ' unless new_instance[:port].nil?
      name_field.strip!
      new_instance[:name] = name_field

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def commands_hash
    Puppet::Provider::NtpConfig::NtpConfig.commands_hash
  end

  def self.command_from_instance(property_hash)
    set_command = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')['set_values']
    set_command = set_command.gsub(%r{<state>}, (property_hash[:ensure] == :absent) ? 'no ' : '')
    set_command = set_command.to_s.gsub(%r{<ip>}, property_hash[:host])
    set_command = set_command.to_s.gsub(%r{<port>}, (property_hash[:port]) ? " udp-port #{property_hash[:port]}" : '')
    set_command = set_command.to_s.gsub(%r{<username>}, (property_hash[:username]) ? " #{property_hash[:username]}" : '')
    set_command = set_command.to_s.gsub(%r{<version>}, (property_hash[:version]) ? " version #{property_hash[:version]}" : '')
    set_command = set_command.to_s.gsub(%r{<type>}, (property_hash[:type]) ? " #{property_hash[:type]}" : '')
    set_command = set_command.to_s.gsub(%r{<security>}, (property_hash[:security]) ? " #{property_hash[:security]}" : '')
    set_command = set_command.to_s.gsub(%r{<vrf>}, (property_hash[:vrf]) ? " vrf #{property_hash[:vrf]}" : '')
    set_command.strip!
    set_command.squeeze(' ') unless set_command.nil?
  end

  def get(_context)
    command = 'show running-config | section snmp-server host'
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(command)
    return [] if output.nil?
    Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.instances_from_cli(output)
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
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.command_from_instance(should))
  end

  def update(_context, _name, is, should)
    # perform a delete on current, then add
    is[:ensure] = :absent
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.command_from_instance(is))
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.command_from_instance(should))
  end

  def delete(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.command_from_instance(should))
  end
end

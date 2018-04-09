require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# SNMP Notification Receiver Puppet Provider for Cisco IOS devices
class Puppet::Provider::SnmpNotification::SnmpNotification < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    commands = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands)
      new_instance[:enable] = if new_instance[:enable].nil?
                                true
                              else
                                false
                              end
      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def commands_hash
    Puppet::Provider::SnmpNotification::SnmpNotification.commands_hash
  end

  def self.command_from_instance(property_hash)
    command = PuppetX::CiscoIOS::Utility.set_values(property_hash, commands_hash)
    command = command.to_s.gsub(%r{^snmp-server}, 'no snmp-server')
    command = command.to_s.gsub(%r{true }, '')
    command
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::SnmpNotification::SnmpNotification.instances_from_cli(output)
  end

  def update(_context, _name, should)
    # perform a delete on current, then add
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::SnmpNotification::SnmpNotification.command_from_instance(should))
  end

  def create(_context, _name, should); end

  def delete(_context, _name, should); end
end

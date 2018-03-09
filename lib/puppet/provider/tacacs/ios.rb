require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet_x/puppetlabs/cisco_ios/utility'
require 'pry'

# Tacacs Provider for Cisco IOS devices
class Puppet::Provider::Tacacs::Tacacs < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance[:ensure] = (new_instance[:key] || new_instance[:source_interface] || new_instance[:timeout]) ? :present : :absent
    new_instance.delete_if { |_k, v| v.nil? }

    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.command_from_instance(should)
    parent_device = PuppetX::CiscoIOS::Utility.parent_device(commands_hash)
    set_command = ''
    set_command << PuppetX::CiscoIOS::Utility.convert_tacacs_key(commands_hash, should, parent_device)
    set_command << PuppetX::CiscoIOS::Utility.convert_tacacs_source_interface(commands_hash, should, parent_device)
    set_command << PuppetX::CiscoIOS::Utility.convert_tacacs_timeout(commands_hash, should, parent_device)
  end

  def commands_hash
    Puppet::Provider::Tacacs::Tacacs.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::Tacacs::Tacacs.instances_from_cli(output)
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::Tacacs::Tacacs.command_from_instance(should))
  end

  alias update create

  def delete(_context, name)
    clear_hash = { name: name, ensure: :absent, source_interface: 'unset' }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::Tacacs::Tacacs.command_from_instance(clear_hash))
  end
end

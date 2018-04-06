require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Tacacs Server Group Puppet Provider for Cisco IOS devices
class Puppet::Provider::TacacsServerGroup::TacacsServerGroup
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:servers] = PuppetX::CiscoIOS::Utility.convert_tacacs_server_group_servers_to_cli(new_instance[:servers])
      new_instance[:ensure] = 'present'
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    parent_device = PuppetX::CiscoIOS::Utility.parent_device(commands_hash)
    array_of_commands = []

    if should[:ensure] == 'absent'
      # delete with a 'no'
      delete_no_command = commands_hash['delete_command_no'][parent_device]
      delete_no_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(delete_no_command, 'name', should[:name], nil)
      array_of_commands.push(delete_no_command)
    elsif PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'servers')
      array_of_commands.push(*PuppetX::CiscoIOS::Utility.convert_tacacs_server_group_servers(commands_hash, is, should, parent_device))
    end
    # If commands empty eg. no servers, still create the Tacacs server group
    # by populating our commands array with a newline
    array_of_commands.push("\n") if array_of_commands.empty?
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::TacacsServerGroup::TacacsServerGroup.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::TacacsServerGroup::TacacsServerGroup.instances_from_cli(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
      should = change[:should]

      context.updating(name) do
        update(context, name, is, should)
      end
    end
  end

  def update(_context, _name, is, should)
    array_of_commands_to_run = Puppet::Provider::TacacsServerGroup::TacacsServerGroup.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_tacacs_server_group_mode(should[:name], command)
    end
  end

  def create(_context, _name, _should); end

  def delete(_context, name)
    delete_hash = { name: name, ensure: 'absent' }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::NetworkInterface::NetworkInterface.command_from_instance(delete_hash).join("\n"))
  end
end

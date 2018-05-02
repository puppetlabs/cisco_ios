require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Network Interface Puppet Provider for Cisco IOS devices
class Puppet::Provider::NetworkVlan::NetworkVlan
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    get_values = PuppetX::CiscoIOS::Utility.get_values(commands_hash)
    header_rows = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'header_rows')
    output = output.sub(%r{(#{get_values}\n\n)#{header_rows}}, '')
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields.first, commands_hash)
      new_instance[:ensure] = 'present'
      # convert cli values to puppet values
      new_instance[:shutdown] = !new_instance[:shutdown].nil?
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    array_of_commands = []
    parent_device = 'default'
    attributes_that_differ = (should.to_a - is.to_a).to_h
    attributes_that_differ.each do |key, value|
      next unless PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, key.to_s)
      if key.to_s == 'ensure' && value.to_s == 'absent'
        array_of_commands.push(PuppetX::CiscoIOS::Utility.convert_vlan_absent(commands_hash, should, parent_device))
        return array_of_commands
      elsif key.to_s == 'vlan_name'
        set_command = PuppetX::CiscoIOS::Utility.convert_vlan_name(commands_hash, value, parent_device)
      elsif key.to_s == 'shutdown'
        set_command = PuppetX::CiscoIOS::Utility.convert_vlan_shutdown(commands_hash, value, parent_device)
      end
      array_of_commands.push(set_command) unless set_command.nil?
    end
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::NetworkVlan::NetworkVlan.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NetworkVlan::NetworkVlan.instances_from_cli(output)
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

  def update(context, _name, is, should)
    array_of_commands_to_run = Puppet::Provider::NetworkVlan::NetworkVlan.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_vlan_mode(should[:name], command)
    end
  end

  def create(context, _name, _should); end

  def delete(context, _name); end
end

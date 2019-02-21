require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure the STP global config of the device
class Puppet::Provider::IosStpGlobal::CiscoIos
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:mst_inst_vlan_map] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'mst_inst_vlan_map', 0)
    new_instance[:mst_priority] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'mst_priority', 1)
    new_instance[:vlan_forward_time] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_forward_time', 1)
    new_instance[:vlan_hello_time] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_hello_time', 1)
    new_instance[:vlan_max_age] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_max_age', 1)
    new_instance[:vlan_priority] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_priority', 1)
    new_instance[:name] = 'default'
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'bridge_assurance')
      new_instance[:bridge_assurance] = PuppetX::CiscoIOS::Utility.convert_no_to_boolean(new_instance[:bridge_assurance])
    end
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'loopguard')
      new_instance[:loopguard] = if new_instance[:loopguard].nil?
                                   false
                                 else
                                   true
                                 end
    end
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    instance.delete(:mst_revision)
    instance.delete(:mst_name)
    instance.delete(:mst_inst_vlan_map)
    commands = []
    commands.concat PuppetX::CiscoIOS::Utility.set_tuple_values(instance, commands_hash, 'mst_priority', 'mst_ids', 'priority')
    commands.concat PuppetX::CiscoIOS::Utility.set_tuple_values(instance, commands_hash, 'vlan_forward_time', 'vlans', 'forward_time')
    commands.concat PuppetX::CiscoIOS::Utility.set_tuple_values(instance, commands_hash, 'vlan_hello_time', 'vlans', 'hello_time')
    commands.concat PuppetX::CiscoIOS::Utility.set_tuple_values(instance, commands_hash, 'vlan_max_age', 'vlans', 'max_age')
    commands.concat PuppetX::CiscoIOS::Utility.set_tuple_values(instance, commands_hash, 'vlan_priority', 'vlans', 'priority')
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'bridge_assurance') && instance[:bridge_assurance] == false && instance[:enable] != false
      instance[:bridge_assurance] = 'unset'
    end
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'loopguard') && instance[:loopguard] == false && instance[:enable] != false
      instance[:loopguard] = 'unset'
    end
    commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
    commands
  end

  def self.mst_commands_from_instance(instance)
    commands = []
    new_instance = { 'mst_name' => instance[:mst_name], 'mst_revision' => instance[:mst_revision] }
    new_instance.delete_if { |_k, v| v.nil? }
    commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(new_instance, commands_hash)
    commands.concat PuppetX::CiscoIOS::Utility.set_tuple_values(instance, commands_hash, 'mst_inst_vlan_map', 'instance_id', 'vlans')
    commands
  end

  def commands_hash
    Puppet::Provider::IosStpGlobal::CiscoIos.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosStpGlobal::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
      should = change[:should]
      if should[:enable].to_s == 'false'
        context.deleting(name) do
          delete(context, name, is)
        end
      else
        context.updating(name) do
          update(context, name, should)
        end
      end
    end
  end

  def update(context, _name, should)
    array_of_commands_mst_mode = Puppet::Provider::IosStpGlobal::CiscoIos.mst_commands_from_instance(should)
    array_of_commands_mst_mode.each do |command|
      context.device.run_command_mst_mode(command)
    end
    array_of_commands_to_run = Puppet::Provider::IosStpGlobal::CiscoIos.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
  end

  def delete(context, _name, is)
    array_of_commands_mst_mode = Puppet::Provider::IosStpGlobal::CiscoIos.mst_commands_from_instance(is)
    array_of_commands_mst_mode.each do |command|
      command = 'no ' + command
      context.device.run_command_mst_mode(command)
    end
    array_of_commands_to_run = Puppet::Provider::IosStpGlobal::CiscoIos.commands_from_instance(is)
    array_of_commands_to_run.each do |command|
      command = 'no ' + command
      context.device.run_command_conf_t_mode(command)
    end
  end
end

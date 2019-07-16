require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure the STP global config of the device
class Puppet::Provider::IosStpGlobal::CiscoIos
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:extend_system_id] = (new_instance[:extend_system_id]) ? true : false
    new_instance[:loopguard] = (new_instance[:loopguard]) ? true : false
    new_instance[:uplinkfast] = (new_instance[:uplinkfast]) ? true : false
    new_instance[:mst_inst_vlan_map] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'mst_inst_vlan_map', 0)
    new_instance[:mst_priority] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'mst_priority', 1)
    new_instance[:vlan_forward_time] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_forward_time', 1)
    new_instance[:vlan_hello_time] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_hello_time', 1)
    new_instance[:vlan_max_age] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_max_age', 1)
    new_instance[:vlan_priority] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'vlan_priority', 1)
    new_instance[:name] = 'default'
    new_instance[:portfast] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'portfast')
    if new_instance[:portfast]
      new_portfast_array = []
      new_instance[:portfast].each do |portfast_option|
        portfast_option = portfast_option.first
        if portfast_option.casecmp('bpduguard default').zero?
          new_portfast_array.push('bpduguard_default')
        elsif portfast_option.casecmp('bpdufilter default').zero?
          new_portfast_array.push('bpdufilter_default')
        else
          new_portfast_array.push(portfast_option)
        end
      end
      new_instance[:portfast] = new_portfast_array
    end
    new_instance[:enable] = false if new_instance[:extend_system_id] && !new_instance[:loopguard] && !new_instance[:uplinkfast]
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  # Return true if enabled, false if disabled, nil otherwise.
  def self.bridge_assurance_from_output(output)
    bridge_output = output.match(PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, 'bridge_assurance', 'get_value'))
    if bridge_output && bridge_output[1]
      return true if bridge_output[1].casecmp('enabled').zero?
      return false if bridge_output[1].casecmp('disabled').zero?
    end
    nil
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
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'extend_system_id') && instance[:extend_system_id] == false && instance[:enable] != false
      instance[:extend_system_id] = 'unset'
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

  def self.portfast_commands_from_instance(instance_portfast)
    commands = []
    Array(instance_portfast).each do |portfast_option|
      if portfast_option.casecmp('bpduguard_default').zero?
        portfast_option = 'bpduguard default'
      elsif portfast_option.casecmp('bpdufilter_default').zero?
        portfast_option = 'bpdufilter default'
      end
      new_instance = { 'portfast' => portfast_option }
      commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(new_instance, commands_hash)
    end
    commands
  end

  def commands_hash
    Puppet::Provider::IosStpGlobal::CiscoIos.commands_hash
  end

  def get(context)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosStpGlobal::CiscoIos.instances_from_cli(output)
    if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'bridge_assurance')
      bridge_output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_bridge_assurance'))
      bridge_output_return = Puppet::Provider::IosStpGlobal::CiscoIos.bridge_assurance_from_output(bridge_output)
      unless bridge_output_return.nil?
        return_value.first[:bridge_assurance] = bridge_output_return
      end
    end
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
      should = change[:should]
      raise "The property `enable` can only be used on its own, i.e. ios_stp_global { 'default': enable => false }" if should[:enable] == false && should.size > 2
      if should[:enable].to_s == 'false'
        context.deleting(name) do
          delete(context, name, is)
        end
      else
        context.updating(name) do
          if is[:portfast]
            should[:current_portfast] = is[:portfast]
          end
          update(context, name, should)
        end
      end
    end
  end

  def update(context, _name, should)
    array_of_commands_mst_mode = Puppet::Provider::IosStpGlobal::CiscoIos.mst_commands_from_instance(should)
    array_of_commands_mst_mode.each do |command|
      context.transport.run_command_mst_mode(command)
    end
    # Remove current portfast options
    if should[:current_portfast]
      array_of_commands_portfast = Puppet::Provider::IosStpGlobal::CiscoIos.portfast_commands_from_instance(should[:current_portfast])
      array_of_commands_portfast.each do |command|
        unless command.start_with?('no ')
          command = 'no ' + command
        end
        context.transport.run_command_conf_t_mode(command)
      end
      should.delete(:current_portfast)
    end
    if should[:portfast]
      array_of_commands_portfast = Puppet::Provider::IosStpGlobal::CiscoIos.portfast_commands_from_instance(should[:portfast])
      array_of_commands_portfast.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
      should.delete(:portfast)
    end
    array_of_commands_to_run = Puppet::Provider::IosStpGlobal::CiscoIos.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def delete(context, _name, is)
    array_of_commands_mst_mode = Puppet::Provider::IosStpGlobal::CiscoIos.mst_commands_from_instance(is)
    array_of_commands_mst_mode.each do |command|
      unless command.start_with?('no ')
        command = 'no ' + command
      end
      context.transport.run_command_mst_mode(command)
    end
    if is[:portfast]
      array_of_commands_portfast = Puppet::Provider::IosStpGlobal::CiscoIos.portfast_commands_from_instance(is[:portfast])
      array_of_commands_portfast.each do |command|
        unless command.start_with?('no ')
          command = 'no ' + command
        end
        context.transport.run_command_conf_t_mode(command)
      end
      is.delete(:portfast)
    end
    array_of_commands_to_run = Puppet::Provider::IosStpGlobal::CiscoIos.commands_from_instance(is)
    array_of_commands_to_run.each do |command|
      unless command.start_with?('no ')
        command = 'no ' + command
      end
      context.transport.run_command_conf_t_mode(command)
    end
  end
end

require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/resource_api/simple_provider'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'
require_relative '../network_trunk/cisco_ios'

# Network Trunk Puppet Provider for Cisco IOS devices
class Puppet::Provider::IosNetworkTrunk::CiscoIos < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @local_commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    @network_trunk_commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/../network_trunk/command.yaml')
    @commands_hash ||= @local_commands_hash.merge(@network_trunk_commands_hash) { |_key, oldval, newval| (oldval.to_a + newval.to_a).to_h }
  end

  def self.instance_from_cli(output, interface_name)
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = interface_name
    new_instance[:mode] = PuppetX::CiscoIOS::Utility.convert_network_trunk_mode_cli(new_instance[:mode])
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance[:ensure] = if new_instance[:ensure] || new_instance.size > 1
                              'present'
                            else
                              'absent'
                            end
    new_instance
  end

  def self.commands_from_instance(property_hash)
    commands_array = []
    ensure_command = if PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'ensure')
                       PuppetX::CiscoIOS::Utility.attribute_value_foraged_from_command_hash(commands_hash, 'ensure', 'set_value')
                     else
                       ''
                     end
    if property_hash[:ensure] == 'absent'
      # delete with a 'no'
      ensure_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(ensure_command, 'state', 'no', false)
      commands_array.push(ensure_command) if ensure_command != ''
    else
      ensure_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(ensure_command, 'state', '', false)
      commands_array.push(ensure_command.strip) if ensure_command != ''
      unless property_hash[:mode].nil?
        property_hash[:mode] = PuppetX::CiscoIOS::Utility.convert_network_trunk_mode_modelled(property_hash[:mode])
      end
      unless property_hash[:allowed_vlans].nil?
        property_hash[:allowed_vlans] = Puppet::Provider::IosNetworkTrunk::CiscoIos.array_to_string(property_hash[:allowed_vlans])
      end
      property_hash.each do |key, _value|
        property_hash[key] = Puppet::Provider::IosNetworkTrunk::CiscoIos.false_to_unset(property_hash[key])
      end
      commands_array += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
    end
    commands_array
  end

  # Replaces switchport_nonegotiate value 'Off' with true and 'On' with false
  def self.switchport_nonegotiate_from_output(output)
    output_switchport = output[:switchport_nonegotiate]
    if output_switchport
      output[:switchport_nonegotiate] = true if output_switchport == 'Off'
      output[:switchport_nonegotiate] = false if output_switchport == 'On'
    end
    output
  end

  # Returns 'unset' if the given calue is false
  def self.false_to_unset(false_value)
    return 'unset' if false_value == false
    false_value
  end

  # If given an array, converts it to a string
  def self.array_to_string(array_value)
    return array_value unless array_value.class == Array
    _string_value = "#{array_value[0]} #{array_value[1]}"
  end

  def commands_hash
    Puppet::Provider::IosNetworkTrunk::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    name_output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_interface_names(commands_hash))
    interface_names = Puppet::Provider::NetworkTrunk::CiscoIos.interface_names_from_cli(name_output)

    return_instances = []
    [*interface_names].each do |interface_name|
      get_value_cmd = PuppetX::CiscoIOS::Utility.get_values(commands_hash).to_s.gsub(%r{<name>}, interface_name)
      output = context.transport.run_command_enable_mode(get_value_cmd)
      # If this interface is not a switchable port ignore
      if !output.nil? && (!output.include? ' is not a switchable port')
        return_instance = Puppet::Provider::IosNetworkTrunk::CiscoIos.instance_from_cli(output, interface_name)
        return_instances << Puppet::Provider::IosNetworkTrunk::CiscoIos.switchport_nonegotiate_from_output(return_instance)
      end
    end
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_instances)
  end

  def create(context, name, should)
    commands = Puppet::Provider::IosNetworkTrunk::CiscoIos.commands_from_instance(should).join("\n")
    context.transport.run_command_interface_mode(name, commands)
  end

  alias update create

  def delete(context, name)
    delete_hash = { name: name, ensure: 'absent' }
    context.transport.run_command_interface_mode(name, Puppet::Provider::IosNetworkTrunk::CiscoIos.commands_from_instance(delete_hash).join("\n"))
  end

  def canonicalize(_context, resources)
    resources
  end
end

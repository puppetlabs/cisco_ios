require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/resource_api/simple_provider'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# pre-declare the module to load the provider without error
module Puppet::Provider::NetworkTrunk; end
require_relative '../network_trunk/cisco_ios'

# Network Trunk Puppet Provider for Cisco IOS devices
class Puppet::Provider::IosNetworkTrunk::CiscoIos < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @local_commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    @network_trunk_commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/../network_trunk/command.yaml')
    @commands_hash ||= @local_commands_hash.merge(@network_trunk_commands_hash) { |_key, oldval, newval| (oldval.to_a + newval.to_a).to_h }
  end

  def self.instance_from_cli(output)
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = PuppetX::CiscoIOS::Utility.shorthand_to_full(new_instance[:name])
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

  # the cli will return the allowed_vlans in the following format,
  # '1-3,5,7,100-300' to specify the ranges, or individual vlans allowed.
  #
  # if all vlans are allowed, it'll return 'ALL', if none then 'NONE' is used.
  # this method will convert user manifests in to the expected format of the cli
  # allowing idempotency to be maintained even for complex things like
  # `allowed_vlans => ['except', '500-600']``
  def self.make_allowed_vlans_idempotent(current_vlans, allowed_vlans)
    # if it is not an arrary then it'll either already be a valid cli range
    # i.e. '1-3,6-10,100-300' or one of the key words, `all`, `none` etc.
    return allowed_vlans.upcase unless allowed_vlans.class == Array
    if allowed_vlans[0] == 'add'
      # add needs to know what current vlans are
      # allowed and extend them
      return allowed_vlans[1] if current_vlans == 'NONE'
      # if current vlans is `ALL` then
      # there is no need to add to them
      # so returning all will surfice
      return 'ALL' if current_vlans == 'ALL'
      # need to create a string with the current and
      # ones that need to be added
      all_vlans = current_vlans + ',' + allowed_vlans[1]
      array_of_all_vlans = Puppet::Provider::IosNetworkTrunk::CiscoIos.create_array_from_string(all_vlans)
      return Puppet::Provider::IosNetworkTrunk::CiscoIos.create_cli_range_from_array(array_of_all_vlans)
    elsif allowed_vlans[0] == 'remove'
      if current_vlans == 'ALL'
        # if it is all vlans, we need to remove the
        # expected vlans that need removed from
        # all available vlans
        array_of_all_vlans = (1..4094).to_a
        array_of_allowed_vlans = Puppet::Provider::IosNetworkTrunk::CiscoIos.create_array_from_string(allowed_vlans[1])
        array_without_allowed = array_of_all_vlans - array_of_allowed_vlans
        return Puppet::Provider::IosNetworkTrunk::CiscoIos.create_cli_range_from_array(array_without_allowed)
      elsif current_vlans == 'NONE'
        # if current vlans is `NONE` then
        # there is no need to remove any from them
        # so returning none is enough
        return 'NONE'
      else
        array_of_current_vlans = Puppet::Provider::IosNetworkTrunk::CiscoIos.create_array_from_string(current_vlans)
        array_of_allowed_vlans = Puppet::Provider::IosNetworkTrunk::CiscoIos.create_array_from_string(allowed_vlans[1])
        array_without_allowed = array_of_current_vlans - array_of_allowed_vlans
        return Puppet::Provider::IosNetworkTrunk::CiscoIos.create_cli_range_from_array(array_without_allowed)
      end
    elsif allowed_vlans[0] == 'except'
      # except is all possible vlans without the specified ones
      # so no need to handle if it is currently 'all' or 'none' etc.
      array_of_all_vlans = (1..4094).to_a
      array_of_allowed_vlans = Puppet::Provider::IosNetworkTrunk::CiscoIos.create_array_from_string(allowed_vlans[1])
      array_without_allowed = array_of_all_vlans - array_of_allowed_vlans
      return Puppet::Provider::IosNetworkTrunk::CiscoIos.create_cli_range_from_array(array_without_allowed)
    end
  end

  # convert [1,2,3,4,5,8,100,101,102] in to a valid cli range such as,
  # '1-5,8,100-102'
  def self.create_cli_range_from_array(array)
    # inspiration and code gathered from https://www.rosettacode.org/wiki/Range_extraction#Ruby
    array.sort.slice_when { |i, j| i + 1 != j }.map { |a| (a.size < 3) ? a : "#{a[0]}-#{a[-1]}" }.join(',')
  end

  def self.create_array_from_string(all_vlans)
    # split the string based on ',' and then '-'
    # so "1-3,5-9" becomes [["1", "3"], ["5", "9"]]
    split_vlans = all_vlans.split(',').map { |x| x.split('-') }
    # create the Range of the values from the split, i.e.
    # [["1", "3"], ["5", "9"]] will become
    # [[1,2,3], [5,6,7,8,9]]
    ranged_vlans = split_vlans.map do |x|
      if x[1].nil?
        [x[0].to_i]
      else
        (x[0].to_i..x[1].to_i).to_a unless x[1].nil?
      end
    end
    # reconstruct the full array of all values sort them and
    # only return uniques
    ranged_vlans.join(',').split(',').sort.map { |x| x.to_i }.uniq
  end

  def commands_hash
    Puppet::Provider::IosNetworkTrunk::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    # convert the output to an array, breaking at `Name:`
    output_array = output.split("\n").slice_before(%r{Name:(.*)}).to_a

    return_instances = []
    # drop the first item in the array which is the command...
    output_array.drop(1).each do |interface|
      interface_output = interface.join("\n")
      unless interface_output.include? ' is not a switchable port'
        return_instance = Puppet::Provider::IosNetworkTrunk::CiscoIos.instance_from_cli(interface_output)
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

  def canonicalize(context, resources)
    resources.each do |resource|
      if resource[:allowed_vlans]
        current_vlans = (get(context) || []).find { |key| key[:name] == resource[:name] }[:allowed_vlans]
        resource[:allowed_vlans] = Puppet::Provider::IosNetworkTrunk::CiscoIos.make_allowed_vlans_idempotent(current_vlans, resource[:allowed_vlans])
      end
    end
    resources
  end
end

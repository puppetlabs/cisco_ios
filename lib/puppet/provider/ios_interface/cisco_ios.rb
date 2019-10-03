require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# IOS Interface Puppet Provider for Cisco IOS devices
class Puppet::Provider::IosInterface::CiscoIos
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance_fields << PuppetX::CiscoIOS::Utility.device_safe_instance(new_instance, commands_hash)
    end
    cleaned_value = []
    new_instance_fields.each do |instance|
      instance[:mac_notification_added] = instance[:mac_notification_added].nil? ? false : true
      instance[:mac_notification_removed] = instance[:mac_notification_removed].nil? ? false : true
      instance[:link_status_duplicates] = instance[:link_status_duplicates].nil? ? false : true
      instance[:ip_dhcp_snooping_trust] = instance[:ip_dhcp_snooping_trust].nil? ? false : true
      instance[:flowcontrol_receive] = 'off' unless instance[:flowcontrol_receive]
      instance[:ip_dhcp_snooping_limit] = false unless instance[:ip_dhcp_snooping_limit]
      instance[:vrf] = 'unset' unless instance[:vrf]
      instance = Puppet::Provider::IosInterface::CiscoIos.clean_logging_event(instance)
      # Converts 'logging_event_link_status' to a boolean value. The value only appears when
      #   it is unset as it's set by default, so if it is found it should be set to false.
      instance[:logging_event_link_status] = (instance[:logging_event_link_status]) ? false : true
      cleaned_value << instance
    end
    cleaned_value
  end

  def self.commands_from_instance(property_hash, current)
    commands = []
    if property_hash[:vrf] == 'unset' && current[:vrf] && current[:vrf] != 'unset'
      commands << "no #{PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ vrf: current[:vrf] }, commands_hash)[0]}"
      property_hash.delete(:vrf)
    elsif property_hash[:vrf] == 'unset' && !current[:vrf]
      property_hash.delete(:vrf)
    end
    # If unset is supplied in logging_event then if a value is currently set is not in the
    #   applied manifest, it needs to be removed.
    if property_hash[:logging_event] == 'unset' && current[:logging_event] && current[:logging_event] != 'unset'
      current[:logging_event].each do |remove|
        commands << "no #{PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ logging_event: remove }, commands_hash)[0]}"
      end
    elsif property_hash[:logging_event] && current[:logging_event] && current[:logging_event] != 'unset'
      to_remove = []
      to_remove += current[:logging_event] - property_hash[:logging_event]
      to_remove.each do |remove|
        commands << "no #{PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ logging_event: remove }, commands_hash)[0]}"
      end
    end

    # logging_event requires multiple commands to be built in most cases, as such it is handled
    #   seperately from the remaining attributes
    if property_hash[:logging_event] && property_hash[:logging_event].class == Array
      property_hash[:logging_event].each do |event|
        commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ logging_event: event }, commands_hash)
      end
    end
    property_hash.delete(:logging_event)

    property_hash.each do |key, value|
      property_hash[key] = Puppet::Provider::IosInterface::CiscoIos.false_to_unset(value)
    end
    commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
    commands
  end

  # Returns 'unset' if the given calue is false
  def self.false_to_unset(false_value)
    return 'unset' if false_value == false
    false_value
  end

  # Clears 'link-status' from 'logging-event'. This is done as it's default nature is
  #   different than the remaining logging events.
  def self.clean_logging_event(instance)
    if instance[:logging_event]
      if instance[:logging_event].class == Array
        instance[:logging_event] -= ['link-status']
      elsif instance[:logging_event].class == String
        instance.delete(:logging_event) if instance[:logging_event] == 'link-status'
      end
    end
    if instance[:logging_event] && instance[:logging_event].class == String
      instance[:logging_event] = [instance[:logging_event]]
    elsif instance[:logging_event].nil?
      instance[:logging_event] = 'unset'
    end
    instance
  end

  def commands_hash
    Puppet::Provider::IosInterface::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosInterface::CiscoIos.instances_from_cli(output)
    instances = PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
    instances
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      is = change[:is]
      context.updating(name) do
        update(context, name, should, is)
      end
    end
  end

  def update(context, name, should, is)
    array_of_commands_to_run = Puppet::Provider::IosInterface::CiscoIos.commands_from_instance(should, is)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_interface_mode(name, command)
    end
  end

  def canonicalize(_context, resources)
    resources
  end
end

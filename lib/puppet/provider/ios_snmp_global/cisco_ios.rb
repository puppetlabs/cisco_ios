require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure the domain name of the device
class Puppet::Provider::IosSnmpGlobal::CiscoIos
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance[:system_shutdown] = Puppet::Provider::IosSnmpGlobal::CiscoIos.convert_to_boolean(new_instance[:system_shutdown])
    new_instance[:manager] = Puppet::Provider::IosSnmpGlobal::CiscoIos.convert_to_boolean(new_instance[:manager])
    new_instance[:ifmib_ifindex_persist] = Puppet::Provider::IosSnmpGlobal::CiscoIos.convert_to_boolean(new_instance[:ifmib_ifindex_persist])
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    commands = []
    commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
    commands
  end

  def self.convert_to_boolean(value)
    if value.nil?
      false
    else
      true
    end
  end

  def self.false_to_unset(value)
    return 'unset' if value == false
    value
  end

  def commands_hash
    Puppet::Provider::IosSnmpGlobal::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosSnmpGlobal::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      context.updating(name) do
        update(context, name, should)
      end
    end
  end

  def update(context, _name, should)
    should.each do |key, value|
      should[key] = Puppet::Provider::IosSnmpGlobal::CiscoIos.false_to_unset(value)
    end
    array_of_commands_to_run = Puppet::Provider::IosSnmpGlobal::CiscoIos.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def canonicalize(_context, resources)
    resources
  end
end

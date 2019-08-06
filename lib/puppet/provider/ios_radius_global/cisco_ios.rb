require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# pre-declare the module to load the provider without error
module Puppet::Provider::RadiusGlobal; end
require_relative '../radius_global/cisco_ios'

# Configure the domain name of the device
class Puppet::Provider::IosRadiusGlobal::CiscoIos
  def self.commands_hash
    local_commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    radius_global_commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/../radius_global/command.yaml')
    @commands_hash = local_commands_hash.merge(radius_global_commands_hash) { |_key, oldval, newval| (oldval.to_a + newval.to_a).to_h }
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = {}
    new_instance[:attributes] = PuppetX::CiscoIOS::Utility.parse_multiples(output, commands_hash, 'attributes', 0) || []
    new_instance = new_instance.merge(Puppet::Provider::RadiusGlobal::CiscoIos.instances_from_cli(output).first)
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    commands = []
    if instance[:remove_attributes]
      remove_instance = { name: (instance[:name]).to_s, attributes: instance[:remove_attributes] }
      remove_commands = PuppetX::CiscoIOS::Utility.set_tuple_values(remove_instance, commands_hash, 'attributes', 'attribute_id', 'attribute_string')
      remove_commands.each do |remove_command|
        commands << "no #{remove_command}"
      end
      instance.delete(:remove_attributes)
    end
    commands.concat(PuppetX::CiscoIOS::Utility.set_tuple_values(instance, commands_hash, 'attributes', 'attribute_id', 'attribute_string'))
    commands += Puppet::Provider::RadiusGlobal::CiscoIos.commands_from_instance(instance)
    commands
  end

  def commands_hash
    Puppet::Provider::IosRadiusGlobal::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosRadiusGlobal::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      if change[:is][:attributes]
        should[:remove_attributes] = change[:is][:attributes] - should[:attributes]
        should[:attributes] = should[:attributes] - change[:is][:attributes]
      end
      context.updating(name) do
        update(context, name, should)
      end
    end
  end

  def update(context, _name, should)
    array_of_commands_to_run = Puppet::Provider::IosRadiusGlobal::CiscoIos.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def canonicalize(_context, resources)
    resources
  end
end

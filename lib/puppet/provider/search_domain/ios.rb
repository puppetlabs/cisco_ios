require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure the search domain of the device
class Puppet::Provider::SearchDomain::SearchDomain < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:ensure] = 'present'
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    commands_array = []
    commands_array.push(PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash))
    commands_array
  end

  def commands_hash
    Puppet::Provider::SearchDomain::SearchDomain.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::SearchDomain::SearchDomain.instances_from_cli(output)
  end

  def update(context, _name, should)
    array_of_commands_to_run = Puppet::Provider::SearchDomain::SearchDomain.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
  end

  def delete(context, name)
    clear_hash = { name: name, ensure: 'absent' }
    array_of_commands_to_run = Puppet::Provider::SearchDomain::SearchDomain.commands_from_instance(clear_hash)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
  end
  alias create update
end

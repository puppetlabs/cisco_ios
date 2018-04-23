require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Tacacs Provider for Cisco IOS devices
class Puppet::Provider::Tacacs::Tacacs < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance.delete_if { |_k, v| v.nil? }

    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
  end

  def commands_hash
    Puppet::Provider::Tacacs::Tacacs.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::Tacacs::Tacacs.instances_from_cli(output)
  end

  def update(context, _name, should)
    array_of_commands_to_run = Puppet::Provider::Tacacs::Tacacs.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
  end

  def create(context, _name, should) end

  def delete(context, name) end
end

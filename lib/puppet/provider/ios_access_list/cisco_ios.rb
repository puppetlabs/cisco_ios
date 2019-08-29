require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure Access List on the device
class Puppet::Provider::IosAccessList::CiscoIos
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []

    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = 'present'
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_instance(instance)
    commands = []
    if instance[:access_list_type].casecmp('none').zero?
      instance[:access_list_type] = nil
    end
    command = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
    if instance[:ensure].to_s == 'absent'
      command = 'no ' + command
    end
    commands << command
    commands
  end

  def commands_hash
    self.class.commands_hash
  end

  def get(context)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    instances_from_cli(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
      should = change[:should]
      if should[:ensure].to_s == 'absent'
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
    array_of_commands_to_run = commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def delete(context, _name, is)
    is[:ensure] = 'absent'
    array_of_commands_to_run = commands_from_instance(is)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end
end

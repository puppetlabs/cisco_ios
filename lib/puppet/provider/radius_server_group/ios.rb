require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure rad of the device
class Puppet::Provider::RadiusServerGroup::RadiusServerGroup
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = 'present'
      new_instance[:servers] = [].push(new_instance[:servers]) if new_instance[:servers].is_a?(String)
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_instance(property_hash)
    commands_array = []
    # servers are special
    property_hash[:servers] = nil unless property_hash[:servers].nil?
    command = PuppetX::CiscoIOS::Utility.set_values(property_hash, commands_hash)
    commands_array.push(command)
    commands_array
  end

  def self.commands_from_is_should(is, should)
    array_of_commands = []
    parent_device = PuppetX::CiscoIOS::Utility.parent_device(commands_hash)
    is[:servers] = [] if is[:servers].nil?
    should[:servers] = [] if should[:servers].nil?
    array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:servers], should[:servers], parent_device, 'servers')
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::RadiusServerGroup::RadiusServerGroup.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::RadiusServerGroup::RadiusServerGroup.instances_from_cli(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = if context.feature_support?('simple_get_filter')
             change.key?(:is) ? change[:is] : (get(context, [name]) || []).find { |r| r[:name] == name }
           else
             change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }
           end
      should = change[:should]
      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?
      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name) do
          create(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name, is, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name)
        end
      end
    end
  end

  def update(context, name, is, should)
    # only called if adding/removing servers
    array_of_commands_to_run = Puppet::Provider::RadiusServerGroup::RadiusServerGroup.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_radius_mode(name, command)
    end
  end

  def delete(context, name)
    clear_hash = { name: name, ensure: 'absent' }
    array_of_commands_to_run = Puppet::Provider::RadiusServerGroup::RadiusServerGroup.commands_from_instance(clear_hash)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
  end

  def create(context, name, should)
    array_of_commands_to_run = Puppet::Provider::RadiusServerGroup::RadiusServerGroup.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
    is = { name: name, ensure: 'absent' }
    update(context, name, is, should)
  end
end

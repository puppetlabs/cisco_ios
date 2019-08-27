require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure rad of the device
class Puppet::Provider::IosRadiusServerGroup::CiscoIos
  def self.commands_hash
    local_commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    radius_server_group_commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/../radius_server_group/command.yaml')
    @commands_hash = local_commands_hash.merge(radius_server_group_commands_hash) { |_key, oldval, newval| (oldval.to_a + newval.to_a).to_h }
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = 'present'
      new_instance[:servers] = [].push(new_instance[:servers]) if new_instance[:servers].is_a?(String)
      new_instance[:private_servers] = [].push(new_instance[:private_servers]) if new_instance[:private_servers].is_a?(String)
      new_instance[:servers] = new_instance[:servers].sort if new_instance[:servers]
      new_instance[:private_servers] = new_instance[:private_servers].sort if new_instance[:private_servers]
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_instance(property_hash)
    commands_array = []
    # servers are special
    property_hash[:servers] = nil unless property_hash[:servers].nil?
    property_hash[:private_servers] = nil unless property_hash[:private_servers].nil?
    command = PuppetX::CiscoIOS::Utility.set_values(property_hash, commands_hash)
    commands_array.push(command)
    commands_array
  end

  def self.commands_from_is_should(is, should)
    array_of_commands = []
    array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:servers], should[:servers], 'servers')
    array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:private_servers], should[:private_servers], 'private_servers')
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::IosRadiusServerGroup::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosRadiusServerGroup::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }
      should = change[:should]
      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?
      if should[:ensure].to_s == 'present'
        context.updating(name) do
          create(context, name, is, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name)
        end
      end
    end
  end

  def delete(context, name)
    array_of_commands_to_run = Puppet::Provider::IosRadiusServerGroup::CiscoIos.commands_from_instance(name: name, ensure: 'absent')
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def create(context, name, is, should)
    saved_should = Marshal.load(Marshal.dump(should))
    array_of_commands_to_run = Puppet::Provider::IosRadiusServerGroup::CiscoIos.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
    # only called if adding/removing servers
    array_of_commands_to_run = Puppet::Provider::IosRadiusServerGroup::CiscoIos.commands_from_is_should(is, saved_should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_radius_mode(name, command)
    end
  end

  alias update create

  def canonicalize(_context, resources)
    resources.each do |resource|
      resource[:servers] = resource[:servers].sort if resource[:servers]
      resource[:private_servers] = resource[:private_servers].sort if resource[:private_servers]
    end
  end
end

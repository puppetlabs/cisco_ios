require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure the domain name of the device
class Puppet::Provider::NetworkDns::NetworkDns
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance[:ensure] = 'present'
    new_instance[:search] = [].push(new_instance[:search]) if new_instance[:search].is_a?(String)
    new_instance[:servers] = [].push(new_instance[:servers]) if new_instance[:servers].is_a?(String)
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    array_of_commands = []
    parent_device = PuppetX::CiscoIOS::Utility.parent_device(commands_hash)
    array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:search], should[:search], parent_device, 'search')
    array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:servers], should[:servers], parent_device, 'servers')
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::NetworkDns::NetworkDns.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NetworkDns::NetworkDns.instances_from_cli(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
      should = change[:should]

      context.updating(name) do
        update(context, name, is, should)
      end
    end
  end

  def update(_context, _name, is, should)
    array_of_commands_to_run = Puppet::Provider::NetworkDns::NetworkDns.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(command)
    end
  end

  def create(_context, _name, _should); end

  def delete(_context, name) end
end

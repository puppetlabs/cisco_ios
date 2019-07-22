require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure the domain name of the device
class Puppet::Provider::IosNetworkDns::CiscoIos
  def self.commands_hash
    local_commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    network_dns_commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/../network_dns/command.yaml')
    @commands_hash = local_commands_hash.merge(network_dns_commands_hash) { |_key, oldval, newval| (oldval.to_a + newval.to_a).to_h }
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance[:ensure] = 'present'
    new_instance[:search] = [].push(new_instance[:search]) if new_instance[:search].is_a?(String)
    new_instance[:servers] = [].push(new_instance[:servers]) if new_instance[:servers].is_a?(String)
    # servers can come as either a single value or space separated list - deal with it (-O_O)
    new_instance[:servers] = new_instance[:servers].flatten.map(&:split).flatten.sort if new_instance[:servers]
    new_instance.delete_if { |_k, v| v.nil? }
    new_instance_fields << Puppet::Provider::IosNetworkDns::CiscoIos.convert_ip_domain_lookup(new_instance)
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    array_of_commands = []
    array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:search], should[:search], 'search')
    array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:servers], should[:servers], 'servers')
    should.delete(:search) unless should.delete(:search).nil?
    should.delete(:servers) unless should.delete(:servers).nil?
    should.each do |key, _vlaue|
      should[key] = Puppet::Provider::IosNetworkDns::CiscoIos.false_to_unset(should[key])
    end
    # this builds the command to set the domain-name
    puts should
    puts array_of_commands
    commands = array_of_commands + PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(should, commands_hash)
    puts commands
    commands
  end

  # Returns 'unset' if the given calue is false
  def self.false_to_unset(false_value)
    return 'unset' if false_value == false
    false_value
  end

  def self.convert_ip_domain_lookup(output)
    output_no_ip = output[:ip_domain_lookup]
    output[:ip_domain_lookup] = if output_no_ip
                                  false
                                else
                                  true
                                end
    output
  end

  def commands_hash
    Puppet::Provider::IosNetworkDns::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    values = PuppetX::CiscoIOS::Utility.get_values(commands_hash)
    output = context.transport.run_command_enable_mode(values)
    return [] if output.nil?
    return_value = Puppet::Provider::IosNetworkDns::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
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

  def update(context, _name, is, should)
    array_of_commands_to_run = Puppet::Provider::IosNetworkDns::CiscoIos.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def create(context, _name, _should); end

  def delete(context, name) end

  def canonicalize(_context, resources)
    resources.each do |resource|
      resource[:servers] = resource[:servers].sort if resource[:servers]
    end
    resources
  end
end

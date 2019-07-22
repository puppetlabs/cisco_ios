require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:network_dns).provide(:ios) do
  end

  # Configure the domain name of the device
  class Puppet::Provider::NetworkDns::CiscoIos
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
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
      new_instance_fields << new_instance
      new_instance_fields
    end

    def self.commands_from_is_should(is, should)
      array_of_commands = []
      array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:search], should[:search], 'search')
      array_of_commands += PuppetX::CiscoIOS::Utility.commands_from_diff_of_two_arrays(commands_hash, is[:servers], should[:servers], 'servers')
      should.delete(:search) unless should.delete(:search).nil?
      should.delete(:servers) unless should.delete(:servers).nil?
      # this builds the command to set the domain-name
      array_of_commands + PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(should, commands_hash)
    end

    def commands_hash
      Puppet::Provider::NetworkDns::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::NetworkDns::CiscoIos.instances_from_cli(output)
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
      array_of_commands_to_run = Puppet::Provider::NetworkDns::CiscoIos.commands_from_is_should(is, should)
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
end

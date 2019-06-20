require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require 'puppet/resource_api/simple_provider'
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:radius_server).provide(:ios) do
  end

  # Configure a radius_server on the device
  class Puppet::Provider::RadiusServer::CiscoIos < Puppet::ResourceApi::SimpleProvider
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
      array_of_commands = []
      # if we create / delete only send a single command
      if instance[:ensure] == 'absent'
        array_of_commands.push(PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash))
      elsif instance[:ensure] == 'create'
        instance[:ensure] = 'present'
        array_of_commands.push(PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash))
      else
        # if key exists but not key_format, we need to fail
        raise 'radius_server requires key_format to be set if setting key' if !instance[:key].nil? && instance[:key_format].nil?
        raise 'radius_server requires hostname to be set if setting auth_port and/or acct_port' if (!instance[:auth_port].nil? || !instance[:acct_port].nil?) && instance[:hostname].nil?
        instance[:timeout] = 'unset' if instance[:timeout].to_s == '0'
        instance[:retransmit_count] = 'unset' if instance[:retransmit_count].to_s == '0'
        unless instance[:hostname].nil?
          # address command is special we need to craft it ( hostname, auth_port and acct_port )
          address_ports_string = ''
          address_ports_string += " auth-port #{instance[:auth_port]}" if instance[:auth_port] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'auth_port')
          address_ports_string += " acct-port #{instance[:acct_port]}" if instance[:acct_port] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'acct_port')
          instance[:hostname] = "#{PuppetX::CiscoIOS::Utility.detect_ipv4_or_ipv6(instance[:hostname])}#{address_ports_string}"
        end
        unless instance[:key].to_s == 'unset'
          # key is made up of key and key_format
          instance[:key] = "#{instance[:key_format]} #{instance[:key]}" unless instance[:key_format].nil?
        end
        array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      end
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::RadiusServer::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = Puppet::Provider::RadiusServer::CiscoIos.instances_from_cli(output)
      PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
    end

    def update(context, _name, should)
      array_of_commands_to_run = Puppet::Provider::RadiusServer::CiscoIos.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_radius_server_mode(should[:name], command)
      end
    end

    def delete(context, name)
      clear_hash = { name: name, ensure: 'absent' }
      array_of_commands_to_run = Puppet::Provider::RadiusServer::CiscoIos.commands_from_instance(clear_hash)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    def create(context, name, should)
      create_hash = { name: name, ensure: 'create' }
      array_of_commands_to_run = Puppet::Provider::RadiusServer::CiscoIos.commands_from_instance(create_hash)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
      update(context, name, should)
    end

    def canonicalize(_context, resources)
      resources
    end
  end
end

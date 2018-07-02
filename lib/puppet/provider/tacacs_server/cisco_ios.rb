require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require 'puppet/resource_api/simple_provider'
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:tacacs_server).provide(:ios) do
  end

  # Tacacs Server Puppet Provider for Cisco IOS devices
  class Puppet::Provider::TacacsServer::CiscoIos < Puppet::ResourceApi::SimpleProvider
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.tidy_up_instance_hash(instance)
      instance[:single_connection] = !(instance[:single_connection].nil? || instance[:single_connection] == '')
      instance[:ensure] = 'present'
      instance.delete_if { |_k, v| (v.nil? || v == '') }
      instance
    end

    def self.instances_from_old_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_instances_old_cli')}}).each do |raw_instance_fields|
        new_instance = raw_instance_fields.first.match(PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_value_old_cli'))
        next if new_instance.nil?
        new_instance_hash = Hash[new_instance.names.map(&:to_sym).zip(new_instance.captures)]
        new_instance_hash[:hostname] = new_instance_hash[:name]
        new_instance_hash = tidy_up_instance_hash(new_instance_hash)
        new_instance_fields << new_instance_hash
      end
      new_instance_fields
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, @commands_hash)
        new_instance = tidy_up_instance_hash(new_instance)
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
        raise 'tacacs_server requires key_format to be set if setting key' if !instance[:key].nil? && instance[:key_format].nil?
        # key and keyformat go in the same command
        unless instance[:key].nil?
          instance[:key] = instance[:key_format].to_s + " #{instance[:key]}" unless instance[:key] == 'unset'
          instance.delete(:key_format)
        end
        # single_connection
        instance[:single_connection] = 'unset' if !instance[:single_connection].nil? && instance[:single_connection] == false
        # the address type needs to be inserted
        instance[:hostname] = PuppetX::CiscoIOS::Utility.detect_ipv4_or_ipv6(instance[:hostname]) unless instance[:hostname].nil?
        # timeout 0 = unset = no timeout
        instance[:timeout] = 'unset' if !instance[:timeout].nil? && instance[:timeout].to_i.zero?
        array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      end
      array_of_commands
    end

    def self.old_cli_commands_from_instance(instance)
      raise 'tacacs_server requires key to be set if setting key_format' if instance[:key].nil? && !instance[:key_format].nil?
      if instance[:hostname].nil?
        instance[:hostname] = instance[:name]
      end
      instance[:single_connection] = if instance[:single_connection] == true && instance[:ensure].to_s != 'absent'
                                       ' single-connection'
                                     else
                                       ''
                                     end
      if instance[:port]
        instance[:port] = " port #{instance[:port]}"
      end
      if instance[:timeout]
        instance[:timeout] = " timeout #{instance[:timeout]}"
      end
      if instance[:key]
        instance[:key] = if instance[:key_format]
                           " key #{instance[:key_format]} #{instance[:key]}"
                         else
                           " key #{instance[:key]}"
                         end
      end
      instance[:ensure] = if instance[:ensure].to_s == 'absent'
                            'no '
                          else
                            ''
                          end
      command_line = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash.dig('set_values_old_cli'))
      command_line
    end

    def commands_hash
      Puppet::Provider::TacacsServer::CiscoIos.commands_hash
    end

    def test_for_new_cli(context)
      test_for_new_cli_output = context.device.run_command_conf_t_mode("tacacs ?\b\b\b\b\b\b\b\b")
      if test_for_new_cli_output =~ %r{(\n\s{2}server)}
        return true
      end
      false
    end

    def test_and_get_new_instances(context)
      return_values = []
      if test_for_new_cli(context)
        output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
        unless output.nil?
          return_values << Puppet::Provider::TacacsServer::CiscoIos.instances_from_cli(output)
        end
      end
      return_values
    end

    def test_and_get_old_instances(context)
      return_values = []
      output_oldcli = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'get_values_old_cli'))
      unless output_oldcli.nil?
        return_values << Puppet::Provider::TacacsServer::CiscoIos.instances_from_old_cli(output_oldcli)
      end
      return_values
    end

    def get(context, _names = nil)
      return_values = []
      new_instances = test_and_get_new_instances(context)
      new_instances.each do |new_instance|
        PuppetX::CiscoIOS::Utility.enforce_simple_types(context, new_instance)
      end
      return_values << new_instances
      old_instances = test_and_get_old_instances(context)
      old_instances.each do |old_instance|
        PuppetX::CiscoIOS::Utility.enforce_simple_types(context, old_instance)
      end
      return_values << old_instances
      return_values.flatten
    end

    def run_update(context, name, should)
      if PuppetX::CiscoIOS::Utility.instances_contains_name(test_and_get_new_instances(context).flatten, name)
        array_of_commands_to_run = Puppet::Provider::TacacsServer::CiscoIos.commands_from_instance(should)
        array_of_commands_to_run.each do |command|
          context.device.run_command_tacacs_mode(name, command)
        end
      end
      return unless PuppetX::CiscoIOS::Utility.instances_contains_name(test_and_get_old_instances(context).flatten, name)
      context.device.run_command_conf_t_mode(Puppet::Provider::TacacsServer::CiscoIos.old_cli_commands_from_instance(should))
    end

    def delete(context, name)
      delete_hash = { name: name, ensure: 'absent' }
      run_update(context, name, delete_hash)
    end

    def update(context, name, should)
      run_update(context, name, should)
    end

    def create(context, name, should)
      if test_for_new_cli(context)
        array_of_commands_to_run = Puppet::Provider::TacacsServer::CiscoIos.commands_from_instance(should)
        array_of_commands_to_run.each do |command|
          context.device.run_command_tacacs_mode(name, command)
        end
      else
        context.device.run_command_conf_t_mode(Puppet::Provider::TacacsServer::CiscoIos.old_cli_commands_from_instance(should))
      end
    end

    def canonicalize(_context, resources)
      resources
    end
  end
end

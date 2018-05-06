require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Tacacs Server Puppet Provider for Cisco IOS devices
class Puppet::Provider::TacacsServer::TacacsServer < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, @commands_hash)
      new_instance[:single_connection] = !new_instance[:single_connection].nil?
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
      # port 0 = unset = no port
      instance[:port] = 'unset' if !instance[:port].nil? && instance[:port].to_i.zero?
      # timeout 0 = unset = no timeout
      instance[:timeout] = 'unset' if !instance[:timeout].nil? && instance[:timeout].to_i.zero?
      array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
    end
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::TacacsServer::TacacsServer.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::TacacsServer::TacacsServer.instances_from_cli(output)
  end

  def delete(context, name)
    delete_hash = { name: name, ensure: 'absent' }
    array_of_commands_to_run = Puppet::Provider::TacacsServer::TacacsServer.commands_from_instance(delete_hash)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
  end

  def update(context, name, should)
    array_of_commands_to_run = Puppet::Provider::TacacsServer::TacacsServer.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_tacacs_mode(name, command)
    end
  end

  def create(context, name, should)
    create_hash = { name: name, ensure: 'create' }
    array_of_commands_to_run = Puppet::Provider::TacacsServer::TacacsServer.commands_from_instance(create_hash)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
    update(context, name, should)
  end
end

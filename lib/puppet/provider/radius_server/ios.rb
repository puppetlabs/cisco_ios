require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure a radius_server on the device
class Puppet::Provider::RadiusServer::RadiusServer < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
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
    # if key exists but not key_format, we need to fail
    raise 'radius_server requires key_format to be set if setting key' if !instance[:key].nil? && instance[:key_format].nil?
    raise 'radius_server requires hostname to be set if setting auth_port and/or acct_port' if (!instance[:auth_port].nil? || !instance[:acct_port].nil?) && instance[:hostname].nil?

    commands_array = []
    device_type = PuppetX::CiscoIOS::Utility.ios_device_type
    parent_device = if commands_hash[device_type].nil?
                      'default'
                    else
                      # else use device specific yaml
                      device_type
                    end

    if instance[:ensure] == 'absent'
      delete_command = commands_hash['delete_command'][parent_device]
      delete_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(delete_command, 'name', instance[:name], nil)
      commands_array.push(delete_command)
    else
      if instance[:timeout].to_s == '0'
        instance[:timeout] = 'unset'
      end
      if instance[:retransmit_count].to_s == '0'
        instance[:retransmit_count] = 'unset'
      end
      raw_commands_array = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      raw_commands_array.each do |command|
        if command =~ %r{timeout} || command =~ %r{retransmit}
          commands_array << command
          next
        end
        # clean address ports
        address_ports_string = ''
        if instance[:auth_port] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'auth_port')
          address_ports_string += " auth-port #{instance[:auth_port]}"
        end
        if instance[:acct_port] && PuppetX::CiscoIOS::Utility.attribute_safe_to_run(commands_hash, 'acct_port')
          address_ports_string += " acct-port #{instance[:acct_port]}"
        end
        if command =~ %r{address}
          # detect ipv4/ipv6 correctly
          commands_array << "#{command} #{PuppetX::CiscoIOS::Utility.detect_ipv4_or_ipv6(instance[:hostname])}#{address_ports_string}"
          next
        end
        # clean key key/key_format
        next unless command =~ %r{key}
        if command =~ %r{^(?!no )(?:key).*}
          command += " #{instance[:key_format]} #{instance[:key]}"
        end
        commands_array << command
      end
    end
    commands_array
  end

  def commands_hash
    Puppet::Provider::RadiusServer::RadiusServer.commands_hash
  end

  def get(context)
    output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::RadiusServer::RadiusServer.instances_from_cli(output)
  end

  def update(context, _name, should)
    array_of_commands_to_run = Puppet::Provider::RadiusServer::RadiusServer.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_radius_server_mode(should[:name], command)
    end
  end

  def delete(context, name)
    clear_hash = { name: name, ensure: 'absent' }
    array_of_commands_to_run = Puppet::Provider::RadiusServer::RadiusServer.commands_from_instance(clear_hash)
    array_of_commands_to_run.each do |command|
      context.device.run_command_conf_t_mode(command)
    end
  end
  alias create update
end

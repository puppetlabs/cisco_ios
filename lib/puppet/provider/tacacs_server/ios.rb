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

  def self.commands_from_instance(property_hash)
    commands_array = []
    device_type = PuppetX::CiscoIOS::Utility.ios_device_type
    parent_device = if commands_hash[device_type].nil?
                      'default'
                    else
                      # else use device specific yaml
                      device_type
                    end

    if property_hash[:ensure] == 'absent'
      delete_command = commands_hash['delete_command'][parent_device]
      delete_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(delete_command, 'name', property_hash[:name], nil)
      commands_array.push(delete_command)
    else
      raw_commands_array = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
      raw_commands_array.each do |command|
        if command =~ %r{tacacs}
          commands_array << command
        end
        # clean timeout
        if command =~ %r{timeout}
          commands_array << if command == 'timeout 0'
                              'no timeout'
                            else
                              command
                            end
        end
        # clean address
        if command =~ %r{address}
          commands_array << if command =~ %r{unset}
                              'no address'
                            else
                              # detect ipv4/ipv6 and hostname correctly
                              'address ' + PuppetX::CiscoIOS::Utility.detect_ipv4_or_ipv6(command.scan(%r{(?:address )(.*)}).flatten.first)
                            end
        end
        # clean port
        if command =~ %r{port}
          commands_array << if command == 'port 0'
                              'no port'
                            else
                              command
                            end
        end
        # clean single_connection
        if command =~ %r{single_connection}
          commands_array << if command =~ %r{true}
                              'single-connection'
                            else
                              'no single-connection'
                            end
        end
        # clean key key/key_format
        next unless command =~ %r{key }
        commands_array << if command =~ %r{unset}
                            'no key'
                          elsif property_hash[:key_format]
                            "key #{property_hash[:key_format]} #{property_hash[:key]}"
                          else
                            "key 0 #{property_hash[:key]}"
                          end
      end
    end
    commands_array
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
    context.device.run_command_conf_t_mode(Puppet::Provider::TacacsServer::TacacsServer.commands_from_instance(delete_hash).first)
  end

  def update(context, name, should)
    array_of_commands_to_run = Puppet::Provider::TacacsServer::TacacsServer.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.device.run_command_tacacs_mode(name, command)
    end
  end

  alias create update
end

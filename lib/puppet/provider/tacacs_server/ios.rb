require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# Tacacs Server Puppet Provider for Cisco IOS devices
class Puppet::Provider::TacacsServer::TacacsServer < Puppet::ResourceApi::SimpleProvider
  def interface_parse_out(output)
    new_instance_fields = []
    output.scan(%r{#{@commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      new_instance = Puppet::Utility.parse_resource(raw_instance_fields, @commands_hash)

      key_field = raw_instance_fields.match(%r{#{@commands_hash['default']['attributes']['key']['default']['get_value']}})

      if key_field
        new_instance[:key] = key_field[:key_value]
        if key_field[:key_format]
          new_instance[:key_format] = key_field[:key_format]
        end
      end

      address_field = raw_instance_fields.match(%r{#{@commands_hash['default']['attributes']['address']['default']['get_value']}})

      new_instance[:address] = nil

      if address_field
        if address_field[:address_type] == 'ipv4'
          new_instance[:addressv4] = address_field[:address]
        else
          new_instance[:addressv6] = address_field[:address]
        end
      end

      new_instance[:single_connection] = !new_instance[:single_connection].nil?

      new_instance[:ensure] = :present

      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def tacacs_config_command(property_hash)
    if property_hash[:ensure] == :absent
      set_command = "no tacacs server #{property_hash[:name]}\n"
    else
      interface_config_string = @commands_hash['default']['set_values']
      set_command = interface_config_string.to_s.gsub(%r{<address_type><address>}, if (property_hash[:addressv4] || property_hash[:addressv6]) &&
                                                                                      (property_hash[:addressv4] != 'unset' && property_hash[:addressv6] != 'unset')
                                                                                     if property_hash[:addressv4]
                                                                                       " address ipv4 #{property_hash[:addressv4]}\n"
                                                                                     else
                                                                                       " address ipv6 #{property_hash[:addressv6]}\n"
                                                                                     end
                                                                                   elsif property_hash[:addressv4] == 'unset' || property_hash[:addressv6] == 'unset'
                                                                                     " no address\n"
                                                                                   else
                                                                                     ''
                                                                                   end)
      set_command = set_command.to_s.gsub(%r{<key_format><key>}, if property_hash[:key] && property_hash[:key] != 'unset'
                                                                   if property_hash[:key_format]
                                                                     " key #{property_hash[:key_format]} #{property_hash[:key]}\n"
                                                                   else
                                                                     " key 0 #{property_hash[:key]}\n"
                                                                   end
                                                                 elsif property_hash[:key] && property_hash[:key] == 'unset'
                                                                   " no key\n"
                                                                 else
                                                                   ''
                                                                 end)

      set_command = set_command.to_s.gsub(%r{<port>}, if property_hash[:port] && property_hash[:port].to_i != 0
                                                        " port #{property_hash[:port]}\n"
                                                      elsif property_hash[:port] && property_hash[:port].to_i.zero?
                                                        " no port\n"
                                                      else
                                                        ''
                                                      end)
      set_command = set_command.to_s.gsub(%r{<timeout>}, if property_hash[:timeout] && property_hash[:timeout].to_i != 0
                                                           " timeout #{property_hash[:timeout]}\n"
                                                         elsif property_hash[:timeout] && property_hash[:timeout].to_i.zero?
                                                           " no timeout\n"
                                                         else
                                                           ''
                                                         end)
      set_command = set_command.to_s.gsub(%r{<single-connection-state>}, (property_hash[:single_connection] == true) ? '' : 'no')
    end
    set_command
  end

  def initialize
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(@commands_hash['default']['get_values'])
    return [] if output.nil?
    interface_parse_out(output)
  end

  def create(_context, name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_tacacs_mode(name, tacacs_config_command(should))
  end

  alias update create

  def delete(_context, name)
    delete_hash = { name: name, ensure: :absent }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(tacacs_config_command(delete_hash))
  end
end

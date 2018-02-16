require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# Network Interface Puppet Provider for Cisco IOS devices
class Puppet::Provider::NetworkInterface::NetworkInterface < Puppet::ResourceApi::SimpleProvider
  def interface_parse_out(output)
    new_instance_fields = []
    output.scan(%r{#{@commands_hash['default']['get_instances']}}).each do |raw_instance_fields|
      new_instance = Puppet::Utility.parse_resource(raw_instance_fields, @commands_hash)
      # Convert 10/100/1000 speed values to modelled 10m/100m/1g
      speed_value = new_instance[:speed]
      if speed_value && !speed_value.nil?
        speed = if speed_value == '10'
                  '10m'
                elsif speed_value == '100'
                  '100m'
                elsif speed_value == '1000'
                  '1g'
                else
                  speed_value
                end
      end
      new_instance[:speed] = speed

      mtu_value = new_instance[:mtu]
      mtu = if mtu_value.nil?
              mtu_value
            else
              mtu_value.to_i
            end
      new_instance[:mtu] = mtu

      new_instance[:enable] = new_instance[:shutdown].nil?
      new_instance[:ensure] = :present
      new_instance.delete(:shutdown)

      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def interface_config_command(property_hash)
    if property_hash[:ensure] == :absent
      set_command = "default interface #{property_hash[:name]}\nno interface #{property_hash[:name]}"
    else

      speed_value = property_hash[:speed]

      speed = nil
      # Convert 10m/100m/1g speed values to modelled 10/100/1000 on Cisco 6500
      # TODO: Use facts to determine model
      if speed_value && !speed_value.nil?
        speed = if speed_value == '10m'
                  '10'
                elsif speed_value == '100m'
                  '100'
                elsif speed_value == '1g'
                  '1000'
                else
                  speed_value
                end
      end

      interface_config_string = @commands_hash['default']['set_values']
      set_command = interface_config_string.to_s.gsub(%r{<description>}, (property_hash[:description]) ? " description #{property_hash[:description]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<mtu>}, (property_hash[:mtu]) ? " mtu #{property_hash[:mtu]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<speed>}, speed ? " speed #{speed}\n" : '')
      set_command = set_command.to_s.gsub(%r{<duplex>}, (property_hash[:duplex]) ? " duplex #{property_hash[:duplex]}\n" : '')
      set_command = set_command.to_s.gsub(%r{<shutdown>}, (property_hash[:enable] == true) ? " no shutdown\n" : " shutdown\n")
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
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_interface_mode(name, interface_config_command(should))
  end

  alias update create

  def delete(_context, name)
    delete_hash = { name: name, ensure: :absent }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(interface_config_command(delete_hash))
  end
end

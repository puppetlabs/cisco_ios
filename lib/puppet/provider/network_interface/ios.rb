require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet_x/puppetlabs/cisco_ios/utility'
require 'pry'

# Network Interface Puppet Provider for Cisco IOS devices
class Puppet::Provider::NetworkInterface::NetworkInterface < Puppet::ResourceApi::SimpleProvider
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      # Convert 10/100/1000 speed values to modelled 10m/100m/1g
      if new_instance[:speed] && !new_instance[:speed].nil?
        new_instance[:speed] = PuppetX::CiscoIOS::Utility.convert_speed_int_to_modelled_value(new_instance[:speed])
      end

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

  def self.command_from_instance(property_hash)
    # Convert 10m/100m/1g speed values to modelled 10/100/1000 on Cisco 6500
    if property_hash[:speed] && !property_hash[:speed].nil?
      property_hash[:speed] = PuppetX::CiscoIOS::Utility.convert_modelled_speed_value_to_int(property_hash[:speed])
    end

    parent_device = PuppetX::CiscoIOS::Utility.parent_device(commands_hash)

    commands_array = []

    if property_hash[:ensure] == :absent
      # Set interface to 'default' before deleting
      delete_default_command = commands_hash['delete_command_default'][parent_device]
      delete_default_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(delete_default_command, 'name', property_hash[:name], nil)
      commands_array.push(delete_default_command)
      # ...and delete with a 'no'
      delete_no_command = commands_hash['delete_command_no'][parent_device]
      delete_no_command = PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(delete_no_command, 'name', property_hash[:name], nil)
      commands_array.push(delete_no_command)
    else

      commands_array = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(property_hash, commands_hash)
      shutdown_command = commands_hash['attributes']['shutdown'][parent_device]['set_value']
      shutdown_command = if property_hash[:enable] == false
                           PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(shutdown_command, 'state', '', nil)
                         else
                           PuppetX::CiscoIOS::Utility.insert_attribute_into_command_line(shutdown_command, 'state', 'no ', nil)
                         end
      commands_array.push(shutdown_command)
    end

    commands_array
  end

  def commands_hash
    Puppet::Provider::NetworkInterface::NetworkInterface.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NetworkInterface::NetworkInterface.instances_from_cli(output)
  end

  def create(_context, name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_interface_mode(name, Puppet::Provider::NetworkInterface::NetworkInterface.command_from_instance(should).join("\n"))
  end

  alias update create

  def delete(_context, name)
    delete_hash = { name: name, ensure: :absent }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(Puppet::Provider::NetworkInterface::NetworkInterface.command_from_instance(delete_hash).join("\n"))
  end
end

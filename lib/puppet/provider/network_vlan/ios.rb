require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# Network Interface Puppet Provider for Cisco IOS devices
class Puppet::Provider::NetworkVlan::NetworkVlan
  def self.commands_hash
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    parent_device = Puppet::Utility.parent_device(commands_hash)
    output = output.sub(%r{(#{commands_hash['get_values'][parent_device]}\n\n)#{commands_hash['header_rows'][parent_device]}}, '')
    output.scan(%r{#{Puppet::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = Puppet::Utility.parse_resource(raw_instance_fields.first, commands_hash)
      new_instance[:ensure] = :present
      # convert cli values to puppet values

      new_instance[:shutdown] = !new_instance[:shutdown].nil?

      new_instance.delete_if { |_k, v| v.nil? }

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    array_of_commands = []
    parent_device = Puppet::Utility.parent_device(commands_hash)
    attributes_that_differ = (should.to_a - is.to_a).to_h
    attributes_that_differ.each do |key, value|
      if key.to_s == 'ensure' && value.to_s == 'absent'
        absent_cmd = commands_hash['attributes'][value.to_s][parent_device]['set_value']
        array_of_commands.push(absent_cmd.sub(%r{<name>}, (should[:name]).to_s))
      elsif key.to_s == 'vlan_name'
        set_command = commands_hash['attributes'][key.to_s][parent_device]['set_value']
        set_command = set_command.to_s.gsub(%r{<#{key.to_s}>}, value.to_s)
        set_command = if value.to_s == 'unset'
                        set_command.to_s.gsub(%r{<state>}, 'no ')
                      else
                        set_command.to_s.gsub(%r{<state>}, '')
                      end
        set_command = set_command.to_s.gsub(%r{<#{key.to_s}>}, value.to_s)
      elsif key.to_s == 'shutdown'
        set_command = commands_hash['attributes'][key.to_s][parent_device]['set_value']
        set_command = if value.to_s == 'false'
                        set_command.to_s.gsub(%r{<state>}, 'no ')
                      else
                        set_command.to_s.gsub(%r{<state>}, '')
                      end
        set_command = set_command.to_s.gsub(%r{<#{key.to_s}>}, value.to_s)
      end
      array_of_commands.push(set_command) unless set_command.nil?
    end
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::NetworkVlan::NetworkVlan.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(Puppet::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::NetworkVlan::NetworkVlan.instances_from_cli(output)
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

  def update(_context, _name, is, should)
    array_of_commands_to_run = Puppet::Provider::NetworkVlan::NetworkVlan.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_vlan_mode(should[:name], command)
    end
  end

  def create(_context, _name, _should); end

  def delete(_context, _name); end
end

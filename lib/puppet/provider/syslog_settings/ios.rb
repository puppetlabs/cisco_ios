require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet_x/puppetlabs/cisco_ios/utility'
require 'pry'

# Utility functions to parse out the Interface
class Puppet::Provider::SyslogSettings::SyslogSettings
  def self.commands_hash
    @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)
    new_instance[:name] = 'default'
    new_instance[:ensure] = :present
    # convert cli values to puppet values
    new_instance[:console] = PuppetX::CiscoIOS::Utility.convert_level_name_to_int(new_instance[:console])
    new_instance[:monitor] = PuppetX::CiscoIOS::Utility.convert_level_name_to_int(new_instance[:monitor])
    new_instance[:enable] = PuppetX::CiscoIOS::Utility.convert_no_to_boolean(new_instance[:enable])
    new_instance.delete_if { |_k, v| v.nil? }

    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    attributes_that_differ = (should.to_a - is.to_a).to_h
    array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(attributes_that_differ, commands_hash)
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::SyslogSettings::SyslogSettings.commands_hash
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    Puppet::Provider::SyslogSettings::SyslogSettings.instances_from_cli(output)
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
    array_of_commands_to_run = Puppet::Provider::SyslogSettings::SyslogSettings.commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(command)
    end
  end

  def create(_context, _name, _should); end

  def delete(_context, _name); end
end

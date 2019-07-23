require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
# Please do not do this with other Resource API based providers
Puppet::Type.type(:syslog_settings).provide(:ios) do
end

# Utility functions to parse out the Interface
class Puppet::Provider::IosAdditionalSyslogSettings::CiscoIos
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    new_instance = PuppetX::CiscoIOS::Utility.parse_resource(output, commands_hash)

    new_instance[:name] = 'default'
    new_instance.delete_if { |_k, v| v.nil? }

    # convert cli values to puppet values
    new_instance[:trap] = PuppetX::CiscoIOS::Utility.convert_level_name_to_int(new_instance[:trap]) if new_instance[:trap]
    new_instance[:origin_id] = Puppet::Provider::IosAdditionalSyslogSettings::CiscoIos.origin_id_extract(new_instance[:origin_id]) if new_instance[:origin_id]

    new_instance_fields << new_instance
    new_instance_fields
  end

  def self.commands_from_is_should(is, should)
    attributes_that_differ = (should.to_a - is.to_a).to_h
    array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(attributes_that_differ, commands_hash)
    array_of_commands
  end

  def self.origin_id_command(instance)
    if instance[:origin_id].class == Array
      instance[:origin_id] = "#{instance[:origin_id][0]} #{instance[:origin_id][1]}"
    end
    instance
  end

  def self.origin_id_extract(id)
    if id =~ %r{ }
      split_id = id.split(' ')
      id = Array[split_id[0], split_id[1]]
    end
    id
  end

  def commands_hash
    Puppet::Provider::IosAdditionalSyslogSettings::CiscoIos.commands_hash
  end

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosAdditionalSyslogSettings::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
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

  def update(context, _name, is, should)
    should_cleaned = Puppet::Provider::IosAdditionalSyslogSettings::CiscoIos.origin_id_command(should)

    array_of_commands_to_run = Puppet::Provider::IosAdditionalSyslogSettings::CiscoIos.commands_from_is_should(is, should_cleaned)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def create(context, _name, _should); end

  def delete(context, _name); end

  def canonicalize(_context, resources)
    resources
  end
end

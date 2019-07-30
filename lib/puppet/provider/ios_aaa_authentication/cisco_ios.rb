require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Configure AAA Authentication on the device
class Puppet::Provider::IosAaaAuthentication::CiscoIos

  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      if new_instance[:authentication_list_set] == 'suppress'
        if new_instance[:suppress_null_username]
          new_instance[:name] = "#{new_instance[:authentication_list_set]} null-username"
        end
      else
        new_instance[:name] = "#{new_instance[:authentication_list_set]} #{new_instance[:authentication_list]}"
      end
      new_instance[:enable_password] = if new_instance[:enable_password]
                                         true
                                       else
                                         false
                                       end
      new_instance[:local] = if new_instance[:local]
                               true
                             else
                               false
                             end
      new_instance[:switch_auth] = if new_instance[:switch_auth]
                                     true
                                   else
                                     false
                                   end
      new_instance[:suppress_null_username] = if new_instance[:suppress_null_username]
                                                true
                                              end
      # Convert any single items to expected array
      new_instance[:server_groups] = [new_instance[:server_groups]].flatten(1) unless new_instance[:server_groups].nil?
      new_instance[:ensure] = 'present'
      new_instance.delete_if { |_k, v| v.nil? }
      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.commands_from_instance(instance)

    commands = []
    instance[:enable_password] = if instance[:enable_password]
                                   ' enable'
                                 else
                                   ''
                                 end
    instance[:local] = if instance[:local]
                         ' local'
                       else
                         ''
                       end
    if instance[:suppress_null_username]
      instance[:authentication_list] = 'null-username'
    else
      if instance[:authentication_list_set].downcase == 'suppress'
        raise 'Cannot set suppress without a type of user. Is this device compatible?'
      end
    end
    instance[:server_groups] = PuppetX::CiscoIOS::Utility.generate_server_groups_command_string(instance)
    command = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
    if instance[:ensure].to_s == 'absent'
      command = 'no ' + command
    end
    commands << command
    commands
  end

  def commands_hash
    Puppet::Provider::IosAaaAuthentication::CiscoIos.commands_hash
  end

  def get(context)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::IosAaaAuthentication::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
      should = PuppetX::CiscoIOS::Utility.device_safe_instance(change[:should], commands_hash)
      if should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name, is)
        end
      else
        context.updating(name) do
          update(context, name, should)
        end
      end
    end
  end

  def update(context, _name, should)
    array_of_commands_to_run = Puppet::Provider::IosAaaAuthentication::CiscoIos.commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def delete(context, _name, is)
    is[:ensure] = 'absent'
    array_of_commands_to_run = Puppet::Provider::IosAaaAuthentication::CiscoIos.commands_from_instance(is)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end
end

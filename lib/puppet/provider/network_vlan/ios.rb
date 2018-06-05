require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:network_vlan).provide(:ios) do
  end

  # Network Vlan Puppet Provider for Cisco IOS devices
  class Puppet::Provider::NetworkVlan::NetworkVlan
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      get_values = PuppetX::CiscoIOS::Utility.get_values(commands_hash)
      header_rows = PuppetX::CiscoIOS::Utility.value_foraged_from_command_hash(commands_hash, 'header_rows')
      output = output.sub(%r{(#{get_values}\n\n)#{header_rows}}, '')
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields.first, commands_hash)
        new_instance[:ensure] = 'present'
        # convert cli values to puppet values
        new_instance[:shutdown] = !new_instance[:shutdown].nil?
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
        instance[:shutdown] = if instance[:shutdown] == false
                                'no'
                              else
                                ''
                              end
        array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      end
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::NetworkVlan::NetworkVlan.commands_hash
    end

    def set(context, changes)
      changes.each do |name, change|
        is = change[:is]
        should = change[:should]
        is = { name: name, ensure: 'absent' } if is.nil?
        should = { name: name, ensure: 'absent' } if should.nil?
        if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
          context.creating(name) do
            create(context, name, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          new_should = PuppetX::CiscoIOS::Utility.safe_update(change, commands_hash)
          next if new_should.empty?
          context.updating(name) do
            update(context, name, new_should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
          context.deleting(name) do
            delete(context, name)
          end
        end
      end
    end

    def get(context)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::NetworkVlan::NetworkVlan.instances_from_cli(output)
    end

    def update(context, name, should)
      array_of_commands_to_run = Puppet::Provider::NetworkVlan::NetworkVlan.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.device.run_command_vlan_mode(name, command)
      end
    end

    def create(context, name, should)
      create_hash = { name: name, ensure: 'create' }
      array_of_commands_to_run = Puppet::Provider::NetworkVlan::NetworkVlan.commands_from_instance(create_hash)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
      update(context, name, should)
    end

    def delete(context, name)
      clear_hash = { name: name, ensure: 'absent' }
      array_of_commands_to_run = Puppet::Provider::NetworkVlan::NetworkVlan.commands_from_instance(clear_hash)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end
  end
end

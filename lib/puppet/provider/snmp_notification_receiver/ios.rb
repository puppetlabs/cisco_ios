require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:snmp_notification_receiver).provide(:ios) do
  end

  # SNMP Notification Receiver Puppet Provider for Cisco IOS devices
  class Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      commands = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands)
        new_instance[:ensure] = 'present'
        # making a composite key
        name_field = ''
        name_field += new_instance[:name] + ' ' unless new_instance[:name].nil?
        name_field += new_instance[:username] + ' ' unless new_instance[:username].nil?
        name_field += new_instance[:vrf] + ' ' unless new_instance[:vrf].nil?
        name_field += new_instance[:port] + ' ' unless new_instance[:port].nil?
        name_field.strip!
        new_instance[:name] = name_field
        new_instance.delete_if { |_k, v| v.nil? }
        new_instance_fields << new_instance
      end
      new_instance_fields
    end

    def commands_hash
      Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.commands_hash
    end

    def self.commands_from_instance(instance)
      # extract host
      instance[:name] = instance[:name][%r{(^\S*)}, 1]
      array_of_commands = []
      command = PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)
      # flip port to be udp-port
      command = command.to_s.gsub(%r{port}, 'udp-port')
      array_of_commands.push(command)
      array_of_commands
    end

    def get(context)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.instances_from_cli(output)
    end

    def set(context, changes)
      changes.each do |name, change|
        should = change[:should]
        should = { name: name, ensure: 'absent' } if should.nil?

        if should[:ensure].to_s == 'present'
          new_should = PuppetX::CiscoIOS::Utility.safe_update(change, commands_hash)
          next if new_should.empty?
          context.updating(name) do
            update(context, name, new_should)
          end
        elsif should[:ensure].to_s == 'absent'
          context.deleting(name) do
            delete(context, name, should)
          end
        end
      end
    end

    def update(context, _name, should)
      array_of_commands_to_run = Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.commands_from_instance(should)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end

    def delete(context, name, should)
      clear_hash = { name: name,
                     ensure: 'absent',
                     username: should[:username],
                     port:   should[:port] }
      array_of_commands_to_run = Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver.commands_from_instance(clear_hash)
      array_of_commands_to_run.each do |command|
        context.device.run_command_conf_t_mode(command)
      end
    end

    alias create update
  end
end

require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:snmp_user).provide(:ios) do
  end

  # SNMP user Puppet Provider for Cisco IOS devices
  class Puppet::Provider::SnmpUser::SnmpUser
    def self.commands_hash
      @commands_hash = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      return new_instance_fields if output.nil? || output.empty?
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
        new_instance[:ensure] = 'present'
        # making a composite key
        name_field = ''
        name_field += new_instance[:name] + ' '
        name_field += new_instance[:version]
        name_field.strip!
        new_instance[:name] = name_field
        new_instance[:roles] = [].push(new_instance[:roles].strip) if new_instance[:roles].is_a?(String)
        new_instance.delete_if { |_k, v| v.nil? }

        new_instance_fields << new_instance
      end
      new_instance_fields
    end

    def self.instances_from_cli_v3(output)
      new_instance_fields = []
      return new_instance_fields if output.nil? || output.empty?
      output.split("\n\n").each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
        new_instance[:ensure] = 'present'
        new_instance[:version] = 'v3'

        next if new_instance[:v3_user].nil?
        new_instance[:name] = new_instance[:v3_user] + ' v3'
        new_instance[:roles] = new_instance[:v3_roles] unless new_instance[:v3_roles].nil?
        new_instance[:roles] = [].push(new_instance[:roles]) if new_instance[:roles].is_a?(String)
        new_instance[:auth] = new_instance[:v3_auth].downcase unless new_instance[:v3_auth].nil?
        unless new_instance[:v3_privacy].nil? || new_instance[:v3_privacy].casecmp('none').zero?
          new_instance[:privacy] = new_instance[:v3_privacy]
          new_instance[:privacy] = new_instance[:privacy].downcase
        end
        new_instance[:engine_id] = new_instance[:v3_engine_id] unless new_instance[:v3_engine_id].nil?
        # remove the v3_ keys
        new_instance.delete_if { |k, _v| k.to_s =~ %r{^v3_} }
        new_instance.delete_if { |_k, v| v.nil? }
        new_instance_fields << new_instance
      end
      new_instance_fields
    end

    def self.command_from_instance(property_hash)
      property_hash[:name] = property_hash[:name].split.first
      property_hash[:privacy] = 'priv aes 128' if property_hash[:privacy] == 'aes128'
      property_hash[:privacy] = 'priv aes 192' if property_hash[:privacy] == 'aes192'
      property_hash[:privacy] = 'priv aes 256' if property_hash[:privacy] == 'aes256'
      property_hash[:enforce_privacy] = 'encrypted' if property_hash[:enforce_privacy] == true
      property_hash[:roles] = property_hash[:roles].first
      command = PuppetX::CiscoIOS::Utility.set_values(property_hash, commands_hash)
      command
    end

    def commands_hash
      Puppet::Provider::SnmpUser::SnmpUser.commands_hash
    end

    def get(context)
      output = context.device.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      output_v3 = context.device.run_command_enable_mode(commands_hash['get_v3_values']['default'])
      (Puppet::Provider::SnmpUser::SnmpUser.instances_from_cli(output) << Puppet::Provider::SnmpUser::SnmpUser.instances_from_cli_v3(output_v3)).flatten!
    end

    def set(context, changes)
      changes.each do |name, change|
        is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:name] == name }
        should = change[:should]

        is = { name: name, ensure: 'absent' } if is.nil?
        should = { name: name, ensure: 'absent' } if should.nil?

        if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
          context.creating(name) do
            create(context, name, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          context.updating(name) do
            update(context, name, is, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
          context.deleting(name) do
            delete(context, name, should)
          end
        end
      end
    end

    def create(context, _name, should)
      context.device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(should))
    end

    def update(context, _name, is, should)
      # perform a delete on current, then add
      is[:ensure] = 'absent'
      context.device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(is))
      context.device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(should))
    end

    def delete(context, _name, should)
      context.device.run_command_conf_t_mode(Puppet::Provider::SnmpUser::SnmpUser.command_from_instance(should))
    end
  end
end

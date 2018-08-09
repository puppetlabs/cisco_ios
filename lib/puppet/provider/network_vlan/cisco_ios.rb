require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require 'puppet/resource_api/simple_provider'
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Register legacy Puppet provider instance for compatibility with other netdev_stdlib providers
  # Please do not do this with other Resource API based providers
  Puppet::Type.type(:network_vlan).provide(:ios) do
  end

  # Network Vlan Puppet Provider for Cisco IOS devices
  class Puppet::Provider::NetworkVlan::CiscoIos < Puppet::ResourceApi::SimpleProvider
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
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

    def self.validate_vlan(id, action_verb)
      return unless ['1', '1002', '1003', '1004', '1005'].include?(id)
      raise "VLAN #{id} is a Cisco default VLAN and may not be #{action_verb}."
    end

    def validate_vlan(id, action_verb)
      self.class.validate_vlan(id, action_verb)
    end

    def self.create_commands_from_instance(instance)
      [PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)]
    end

    def self.update_commands_from_instance(instance)
      array_of_commands = []
      # if we create / delete only send a single command
      if instance[:ensure] == 'absent'
        array_of_commands.push(PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash))
      else
        instance[:shutdown] = if !instance[:shutdown]
                                'no'
                              else
                                ''
                              end
        array_of_commands = PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(instance, commands_hash)
      end
      array_of_commands
    end

    def commands_hash
      Puppet::Provider::NetworkVlan::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      return_value = self.class.instances_from_cli(output)
      PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
    end

    def create(context, name, should)
      validate_vlan(name, 'created')
      create_hash = { id: name, ensure: 'present' }
      self.class.create_commands_from_instance(create_hash).each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
      update(context, name, should)
    end

    def update(context, name, should)
      validate_vlan(name, 'updated')
      self.class.update_commands_from_instance(should).each do |command|
        context.transport.run_command_vlan_mode(name, command)
      end
    end

    def delete(context, name)
      validate_vlan(name, 'deleted')
      delete_hash = { id: name, ensure: 'absent' }
      self.class.update_commands_from_instance(delete_hash).each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    def canonicalize(_context, resources)
      resources
    end
  end
end


require 'puppet/resource_api/simple_provider'
require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# NTP Server Puppet Provider for Cisco IOS devices
class Puppet::Provider::Vrf::CiscoIos
  def self.commands_hash
    @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def self.instances_from_cli(output)
    new_instance_fields = []
    output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
      new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, commands_hash)
      new_instance[:ensure] = 'present'
      new_instance.delete_if { |_k, v| v.nil? }
      if new_instance[:route_targets]
        target = []
        if new_instance[:route_targets].is_a? Array
          new_instance[:route_targets].each do |rt|
            target << rt.split("\s")
          end
        else
          target << new_instance[:route_targets].split("\s")
        end
        new_instance[:route_targets] = target
      end

      new_instance_fields << new_instance
    end
    new_instance_fields
  end

  def self.create_commands_from_instance(instance)
    [PuppetX::CiscoIOS::Utility.set_values(instance, commands_hash)]
  end

  def self.update_commands_from_is_should(is, should)
    array_of_commands = []

    # The old route_distinguisher must be explicitly removed before a new one can be set.
    #   It will also be removed if should[:route_distinguisher] is set to 'unset'
    if is[:route_distinguisher] && (should[:route_distinguisher] && is[:route_distinguisher] != should[:route_distinguisher] || should[:route_distinguisher] == 'unset')
      array_of_commands << "no #{PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ route_distinguisher: is[:route_distinguisher] }, commands_hash)[0]}"
    end

    attributes_to_remove = (is.to_a - should.to_a).to_h
    if attributes_to_remove[:route_targets]
      attributes_to_remove[:route_targets].each do |rtarget|
        array_of_commands << "no #{PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ route_targets: "#{rtarget[0]} #{rtarget[1]}" }, commands_hash)[0]}"
      end
    end
    attributes_that_differ = (should.to_a - is.to_a).to_h
    if attributes_that_differ[:route_targets]
      attributes_that_differ[:route_targets].each do |rtarget|
        array_of_commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values({ route_targets: "#{rtarget[0]} #{rtarget[1]}" }, commands_hash)
      end
    end
    attributes_that_differ.delete(:route_targets)

    array_of_commands += PuppetX::CiscoIOS::Utility.build_commmands_from_attribute_set_values(attributes_that_differ, commands_hash)
    array_of_commands
  end

  def commands_hash
    Puppet::Provider::Vrf::CiscoIos.commands_hash
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      is = change[:is]
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

  def get(context, _names = nil)
    output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
    return [] if output.nil?
    return_value = Puppet::Provider::Vrf::CiscoIos.instances_from_cli(output)
    PuppetX::CiscoIOS::Utility.enforce_simple_types(context, return_value)
  end

  def delete(context, name, _should)
    clear_hash = { name: name, ensure: 'absent' }
    array_of_commands_to_run = Puppet::Provider::Vrf::CiscoIos.create_commands_from_instance(clear_hash)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
  end

  def update(context, name, is, should)
    array_of_commands_to_run = Puppet::Provider::Vrf::CiscoIos.update_commands_from_is_should(is, should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_vrf_mode(name, command)
    end
  end

  def create(context, name, should)
    array_of_commands_to_run = Puppet::Provider::Vrf::CiscoIos.create_commands_from_instance(should)
    array_of_commands_to_run.each do |command|
      context.transport.run_command_conf_t_mode(command)
    end
    is = { name: name, ensure: 'present' }
    update(context, name, is, should)
  end

  def canonicalize(_context, resources)
    resources
  end
end

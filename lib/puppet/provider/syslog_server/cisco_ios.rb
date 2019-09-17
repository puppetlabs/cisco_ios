require_relative '../../../puppet_x/puppetlabs/cisco_ios/check'
unless PuppetX::CiscoIOS::Check.use_old_netdev_type
  require 'puppet/resource_api/simple_provider'
  require_relative '../../util/network_device/cisco_ios/device'
  require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

  # Utility functions to parse out the Interface
  class Puppet::Provider::SyslogServer::CiscoIos < Puppet::ResourceApi::SimpleProvider
    def self.commands_hash
      @commands_hash ||= PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
    end

    def self.instances_from_cli(output)
      new_instance_fields = []
      output.scan(%r{#{PuppetX::CiscoIOS::Utility.get_instances(commands_hash)}}).each do |raw_instance_fields|
        new_instance = PuppetX::CiscoIOS::Utility.parse_resource(raw_instance_fields, @commands_hash)
        new_instance[:ensure] = 'present'
        new_instance[:severity_level] = PuppetX::CiscoIOS::Utility.convert_level_name_to_int(new_instance[:severity_level]) unless new_instance[:severity_level].nil?
        new_instance.delete_if { |_k, v| v.nil? }
        new_instance_fields << new_instance
      end
      new_instance_fields
    end

    def self.commands_from_instance(hash_should, hash_current)
      commands_array = []
      if hash_current[:vrf] != hash_should[:vrf] && hash_should[:ensure] != 'absent'
        commands_array << if hash_current[:vrf]
                            PuppetX::CiscoIOS::Utility.set_values({ name: hash_should[:name], vrf: "vrf #{hash_current[:vrf]}", ensure: 'absent' }, commands_hash)
                          else
                            PuppetX::CiscoIOS::Utility.set_values({ name: hash_should[:name], ensure: 'absent' }, commands_hash)
                          end
      end

      hash_should[:vrf] = "vrf #{hash_should[:vrf]}" if hash_should[:vrf]
      hash_should[:vrf] = "vrf #{hash_current[:vrf]}" if hash_current[:vrf] != hash_should[:vrf] && hash_current[:vrf] && hash_should[:ensure] != 'present'
      command = PuppetX::CiscoIOS::Utility.set_values(hash_should, commands_hash)
      command = command.to_s.gsub(%r{name }, '')
      commands_array.push(command)
      commands_array
    end

    def commands_hash
      Puppet::Provider::SyslogServer::CiscoIos.commands_hash
    end

    def get(context, _names = nil)
      output = context.transport.run_command_enable_mode(PuppetX::CiscoIOS::Utility.get_values(commands_hash))
      return [] if output.nil?
      Puppet::Provider::SyslogServer::CiscoIos.instances_from_cli(output)
    end

    def set(context, changes)
      changes.each do |name, change|
        should = change[:should]
        is = change[:is]
        context.updating(name) do
          update(context, name, should, is)
        end
      end
    end

    def update(context, _name, should, is)
      array_of_commands_to_run = Puppet::Provider::SyslogServer::CiscoIos.commands_from_instance(should, is)
      array_of_commands_to_run.each do |command|
        context.transport.run_command_conf_t_mode(command)
      end
    end

    alias create update

    def canonicalize(_context, resources)
      resources
    end
  end
end

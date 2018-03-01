require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'
require 'pry'

# Tacacs Provider for Cisco IOS devices
class Puppet::Provider::Tacacs::Tacacs < Puppet::ResourceApi::SimpleProvider
  def parse(output)
    new_instance_fields = []
    new_instance = Puppet::Utility.parse_resource(output, @commands_hash)
    new_instance[:name] = 'default'
    new_instance[:ensure] = (new_instance[:key] || new_instance[:source_interface] || new_instance[:timeout]) ? :present : :absent
    new_instance.delete_if { |_k, v| v.nil? }

    new_instance_fields << new_instance
    new_instance_fields
  end

  def config_command(should)
    set_command = ''

    set_command_key = ''

    if should[:ensure] == :absent || should[:key] == 'unset'
      set_command_key = @commands_hash['attributes']['key']['default']['set_value']
      set_command_key = set_command_key.gsub(%r{<state>}, 'no ')
      set_command_key = set_command_key.gsub(%r{<key_format>}, '')
      set_command_key = set_command_key.gsub(%r{<key_value>}, '')
    end
    if should[:key] && should[:key] != 'unset'
      set_command_key = @commands_hash['attributes']['key']['default']['set_value']
      set_command_key = set_command_key.gsub(%r{<state>}, '')
      set_command_key = set_command_key.gsub(%r{<key_format>}, "#{should[:key_format]} ")
      set_command_key = set_command_key.gsub(%r{<key_value>}, should[:key])
    end

    set_command << set_command_key

    set_command_source = ''

    if should[:ensure] == :absent || should[:source_interface] == 'unset'
      set_command_source = @commands_hash['attributes']['source_interface']['default']['set_value']
      set_command_source = set_command_source.gsub(%r{<state>}, 'no ')
      set_command_source = set_command_source.gsub(%r{<source_interface>}, '')
    end
    if should[:source_interface] && should[:source_interface] != 'unset'
      set_command_source = @commands_hash['attributes']['source_interface']['default']['set_value']
      set_command_source = set_command_source.gsub(%r{<state>}, '')
      set_command_source = set_command_source.gsub(%r{<source_interface>}, should[:source_interface])
    end

    set_command << set_command_source

    set_command_timeout = ''

    if should[:ensure] == :absent || (should[:timeout] && should[:timeout].to_i.zero?)
      set_command_timeout = @commands_hash['attributes']['timeout']['default']['set_value']
      set_command_timeout = set_command_timeout.gsub(%r{<state>}, 'no ')
      set_command_timeout = set_command_timeout.gsub(%r{<timeout>}, '')
    end
    if should[:timeout] && should[:timeout].to_i != 0
      set_command_timeout = @commands_hash['attributes']['timeout']['default']['set_value']
      set_command_timeout = set_command_timeout.gsub(%r{<state>}, '')
      set_command_timeout = set_command_timeout.gsub(%r{<timeout>}, should[:timeout].to_s)
    end

    set_command << set_command_timeout
  end

  def initialize
    @commands_hash = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/command.yaml')
  end

  def get(_context)
    output = Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_enable_mode(Puppet::Utility.get_values(@commands_hash))
    return [] if output.nil?
    parse(output)
  end

  def create(_context, _name, should)
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(should))
  end

  alias update create

  def delete(_context, name)
    clear_hash = { name: name, ensure: :absent }
    Puppet::Util::NetworkDevice::Cisco_ios::Device.run_command_conf_t_mode(config_command(clear_hash))
  end
end

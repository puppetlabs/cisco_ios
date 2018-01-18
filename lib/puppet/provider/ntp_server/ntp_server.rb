require 'puppet/resource_api'
require 'puppet/provider/cisco_ios_common'
require 'puppet/provider/ntp_server/ntp_server_parse_utils'
require 'pry'

# NTP Server Puppet Provider for Cisco IOS devices
class Puppet::Provider::NtpServer::NtpServer
  def initialize; end

  def get(_context)
    command = 'show running-config | section ntp server'
    output = Puppet::Provider::CiscoIosCommon.run_command_enable_mode(command)
    return [] if output.nil?
    NTPServerParseUtils.parse(output)
  end

  def set(context, changes)
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:id] == name }
      should = change[:should]

      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name) do
          create(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name)
        end
      end
    end
  end

  def create(_context, _name, should)
    Puppet::Provider::CiscoIosCommon.run_command_conf_t_mode(NTPServerParseUtils.config_command(should))
  end

  def update(_context, _name, should)
    Puppet::Provider::CiscoIosCommon.run_command_conf_t_mode(NTPServerParseUtils.config_command(should))
  end

  def delete(_context, name)
    clear_hash = { name: name, ensure: :absent }
    Puppet::Provider::CiscoIosCommon.run_command_conf_t_mode(NTPServerParseUtils.config_command(clear_hash))
  end
end

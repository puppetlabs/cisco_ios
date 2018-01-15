class Puppet::Util::NetworkDevice::Cisco_ios::Facts
  attr_reader :transport

  def initialize(transport)
    @transport = transport
  end

  def retrieve
    facts = {}
    facts.merge(parse_device_facts)
  end

  def parse_device_facts
    facts = { operatingsystem: 'cisco_ios' }
    # https://www.cisco.com/c/en/us/support/docs/switches/catalyst-6500-series-switches/41361-serial-41361.html
    begin
      version_info = @transport.connection.cmd('show version')
      if version_info
        facts[:operatingsystemrelease] = %r{Version\s+([^,]*)}.match(version_info)[1]
        if %r{WS-C65}.match(version_info)
          backplane_info = @transport.connection.cmd('show idprom backplane')
          facts[:hardwaremodel] = %r{Product Number\s+=\s+\'([^']+)}.match(backplane_info)[1]
          facts[:serialnumber] = %r{Serial Number\s+=\s+\'([^']+)}.match(backplane_info)[1]
        else
          facts[:hardwaremodel] = %r{Model number\s+:\s+(\S+)}.match(version_info)[1]
          facts[:serialnumber] = %r{System serial number\s+:\s+(\S+)}.match(version_info)[1]
        end
      else
        raise Puppet::Error, 'Could not retrieve facts'
      end
    end

    facts
  end
end

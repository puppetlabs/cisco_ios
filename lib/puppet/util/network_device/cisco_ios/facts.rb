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
    facts = { :operatingsystem => 'cisco_ios'}

    begin
      if version_info = @transport.connection.cmd('sh ver')
        facts[:operatingsystemrelease] = /Version\s+([^,]*)/.match(version_info)[1]
      else
        raise Puppet::Error, "Could not retrieve facts"
      end
    end

    return facts
  end
end
require 'puppet/util/network_device'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'

class Puppet::Util::NetworkDevice::Transport::Cisco_ios < Puppet::Util::NetworkDevice::Transport::Base
  attr_reader :connection

  def initialize(url, _options = {})
    require 'uri'
    require 'net/ssh/telnet'

    @url = URI.parse(url)

    Puppet.debug "Trying to connect to #{@url.host} as #{@url.user}"
    @connection = Net::SSH::Telnet.new(
            'Host' => @url.host,
            'Username' => @url.user,
            'Password' => @url.password,
            'Prompt' => %r{[#>]\s?\z}
    )
    # IOS will page large results which breaks prompt search
    @connection.cmd('terminal length 0')
    @connection
  end
end

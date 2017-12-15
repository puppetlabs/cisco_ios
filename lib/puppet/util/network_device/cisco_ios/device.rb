require 'puppet/util/network_device/base'
require 'puppet/util/network_device/cisco_ios'
require 'puppet/util/network_device/cisco_ios/facts'
require 'puppet/util/network_device/transport/cisco_ios'

class Puppet::Util::NetworkDevice::Cisco_ios::Device
  attr_reader :connection
  attr_accessor :url, :transport

  def initialize(url, options = {})
    @autoloader = Puppet::Util::Autoload.new(
        self,
        "puppet/util/network_device/transport"
    )
    if @autoloader.load("cisco_ios")
      @transport = Puppet::Util::NetworkDevice::Transport::Cisco_ios.new(url,options[:debug])
    end
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Cisco_ios::Facts.new(@transport)

    return @facts.retrieve
  end

end
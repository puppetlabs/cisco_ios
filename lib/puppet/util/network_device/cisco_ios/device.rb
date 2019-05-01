begin
  require 'puppet/resource_api/transport/wrapper'
rescue LoadError
  require 'puppet_x/puppetlabs/cisco_ios/transport_shim'
end

class Puppet::Util::NetworkDevice; end

module Puppet::Util::NetworkDevice::Cisco_ios # rubocop:disable Style/ClassAndModuleCamelCase
  # The main class for handling the connection and command parsing to the IOS Catalyst device
  class Device < Puppet::ResourceApi::Transport::Wrapper
    def initialize(url_or_config, _options = {})
      super('cisco_ios', url_or_config)
    end
  end
end

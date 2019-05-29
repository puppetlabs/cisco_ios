begin
  require 'puppet/resource_api/transport/wrapper'
rescue LoadError
  require 'puppet_x/puppetlabs/cisco_ios/transport_shim'
end

class Puppet::Util::NetworkDevice; end

module Puppet::Util::NetworkDevice::Cisco_ios # rubocop:disable Style/ClassAndModuleCamelCase
  # The main class for handling the connection and command parsing to the IOS Catalyst device
  class Device < Puppet::ResourceApi::Transport::Wrapper
    def backwards_compatible_schema_load(url_or_config)
      if url_or_config.is_a? String
        url = URI.parse(url_or_config)
        raise "Unexpected url '#{url_or_config}' found. Only file:/// URLs for configuration supported at the moment." unless url.scheme == 'file'
        raise "Trying to load config from '#{url.path}, but file does not exist." if url && !File.exist?(url.path)
        url_or_config = self.class.deep_symbolize(Hocon.load(url.path, syntax: Hocon::ConfigSyntax::HOCON) || {})
      end

      # Allow for backwards compatibility with the fields
      # - address  (map to host)
      # - username (map to user)
      if url_or_config[:address]
        unless url_or_config[:host]
          url_or_config[:host] = url_or_config[:address]
        end
        url_or_config.delete(:address)
      end

      if url_or_config[:username]
        unless url_or_config[:user]
          url_or_config[:user] = url_or_config[:username]
        end
        url_or_config.delete(:username)
      end
      url_or_config
    end

    def initialize(url_or_config, _options = {})
      super('cisco_ios', backwards_compatible_schema_load(url_or_config))
    end
  end
end

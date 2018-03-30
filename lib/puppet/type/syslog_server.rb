require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_resource_api
  require_relative '../../puppet_x/puppetlabs/netdev_stdlib/property/port_range'

  Puppet::Type.newtype(:syslog_server) do
    @doc = 'Configure a remote syslog server for logging'

    apply_to_all
    ensurable

    newparam(:name, namevar: true) do
      desc 'The hostname or address of the remote syslog server'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:port, parent: PuppetX::PuppetLabs::NetdevStdlib::Property::PortRange) do
      desc 'Port number of remote syslog server'

      munge { |v| Integer(v) }
    end

    newproperty(:severity_level) do
      desc 'Syslog severity level to log'
      munge { |v| Integer(v) }
    end

    newproperty(:vrf) do
      desc 'Interface to send syslog data from, e.g. "management"'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:source_interface) do
      desc 'Source interface to send syslog data from, e.g. "ethernet 2/1"'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end
  end
else
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'syslog_server',
    docs: 'Configure a remote syslog server for logging',
    features: ['remote_resource'],
    attributes: {
      ensure:      {
        type:    'Enum[present, absent]',
        desc:    'Whether this network interface should be present or absent on the target system.',
        default: 'present',
      },
      name:     {
        type:   'String',
        desc:   'Hostname or address of the server',
        behaviour: :namevar,
      },
      severity_level:    {
        type:   'Integer',
        desc:   'Syslog severity level to log',
      },
      source_interface:      {
        type:    'String',
        desc:    'Source interface to send syslog data from, e.g. "ethernet 2/1"',
        default: 'false',
      },
      vrf:    {
        type:   'Optional[String]',
        desc:   'vrf',
      },
    },
  )
end

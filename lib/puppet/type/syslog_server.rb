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

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'syslog_settings',
  docs: 'Configure a remote syslog server for logging',
  features: ['remote_resource'],
  attributes: {
    name:     {
      type:   'String',
      desc:   'Hostname or address of the server',
      behaviour: :namevar,
    },
    enable:    {
      type:   'Boolean',
      desc:   'Enable or disable syslog logging [true|false]',
    },
    console:    {
      type:   'Integer',
      desc:   "Console logging severity level [0-7] or 'unset'",
    },
    monitor:    {
      type:   'Integer',
      desc:   "Monitor (terminal) logging severity level [0-7] or 'unset'",
    },
    source_interface:      {
      type:    'String',
      desc:    'Source interface to send syslog data from, e.g. "ethernet 2/1"',
    },
    time_stamp_units:      {
      type:    'String',
      desc:    'The unit to log time values in',
    },
    vrf:    {
      type:   'Optional[String]',
      desc:   'vrf',
    },
  },
)
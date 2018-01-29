require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ntp_server',
  docs: 'Specify an NTP server',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether this ntp server should be present or absent on the target system.',
      default:    'present',
    },
    name:         {
      type:      'String',
      desc:      'The hostname or address of the NTP server',
      behaviour: :namevar,
    },
    key:          {
      type:      'Integer',
      desc:      'Authentication key ID',
    },
    maxpoll:      {
      type:      'Integer',
      desc:      'The maximum poll interval',
    },
    minpoll:      {
      type:      'Integer',
      desc:      'The minimum poll interval',
    },
    prefer:       {
      type:      'Boolean',
      desc:      'Prefer this NTP server [true|false]',
      default:   false,
    },
    source_interface:     {
      type:      'Optional[String]',
      desc:      'The source interface used to reach the NTP server',
    },
    vrf:          {
      type:      'Optional[String]',
      desc:      'The VRF instance this server is bound to.',
    },
  },
)

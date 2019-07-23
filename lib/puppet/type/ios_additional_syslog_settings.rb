require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_additional_syslog_settings',
  docs: 'Configure global syslog settings',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'Name, generally "default", not used to manage the resource',
      behaviour: :namevar,
      default:   'default',
    },
    trap:    {
      type:    'Optional[Variant[Integer[0,7], Enum["unset"]]]', # <0-7, 'unset'>
      desc:    "Set the syslog server logging level, severity level [0-7] or 'unset'",
    },
    origin_id:    {
      type:    "Optional[Variant[Enum['hostname', 'ip', 'ipv6', unset], Tuple[Enum['string'], String]]]", # <'hostname', 'ip', 'ipv6', 'string WORD', 'unset'
      desc:    'Sets an origin-id to be added to all syslog messages.',
    },
  },
)

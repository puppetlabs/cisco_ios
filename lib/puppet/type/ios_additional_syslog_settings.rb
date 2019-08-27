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
      desc:    <<DESC,
Set the syslog server logging level, can be set to a severity level of [0-7] or 'unset'.

Examples:

```Puppet
  trap => 3,
```

```Puppet
  trap => 'unset',
```
DESC
    },
    origin_id:    {
      type:    "Optional[Variant[Enum['hostname', 'ip', 'ipv6', unset], Tuple[Enum['string'], String]]]", # <'hostname', 'ip', 'ipv6', 'string WORD', 'unset'
      desc:    <<DESC
Sets an origin-id to be added to all syslog messages, can be set to a default value taken from the switch itself or a designated one word string.

Examples:

```Puppet
  origin_id => 'ipv6',
```

```Puppet
  origin_id => ['string', 'Main'],
```

```Puppet
  origin_id => 'unset',
```
DESC
    },
  },
)

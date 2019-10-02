require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_interface',
  docs: 'Manage layer 3 configuration on a per Instance basis.',
  features: ['remote_resource', 'canonicalize'],
  attributes: {
    name: {
      type:      'String',
      desc:      'The switch interface name, e.g. "Ethernet1"',
      behaviour: :namevar,
    },
    mac_notification_added: {
      type:    'Optional[Boolean]',
      desc:    'Whether to enable Mac Address added notification for this port.',
    },
    mac_notification_removed: {
      type:    'Optional[Boolean]',
      desc:    'Whether to enable Mac Address removed notification for this port.',
    },
    link_status_duplicates: {
      type:    'Optional[Boolean]',
      desc:    'Whether to permit duplicate SNMP LINKUP and LINKDOWN traps.',
    },
    logging_event: {
      type:   'Optional[Variant[Enum["unset"], Array[Enum["bundle-status","nfas-status","spanning-tree","status","subif-link-status","trunk-status","power-inline-status"]]]]',
      desc:   <<DESC,
Whether or not to log certain event messages. Any event log not specifically indicated will be disabled.

Example:
```puppet
  logging_event => ['spanning-tree','subif-link-status'],
```
```puppet
  logging_event => 'unset',
```
DESC
    },
    logging_event_link_status: {
      type:   'Optional[Boolean]',
      desc:   'Whether to log UPDOWN and CHANGE event messages.',
    },
    ip_dhcp_snooping_trust: {
      type:   'Optional[Boolean]',
      desc:   'DHCP Snooping trust config.',
    },
    ip_dhcp_snooping_limit: {
      type:    'Optional[Variant[Boolean[false], Integer[1, 2048]]]',
      desc:   <<DESC,
DHCP snooping rate limit.

Example:
```puppet
  ip_dhcp_snooping_limit => 1500,
```
```puppet
  ip_dhcp_snooping_limit => false,
```
DESC
    },
    flowcontrol_receive: {
      type:   'Optional[Enum["desired","on","off"]]',
      desc:   <<DESC,
Flow control (receive) [desired|on|off]

Example:
```puppet
  flowcontrol_receive => 'desired',
```
DESC
    },
    vrf: {
      type:   'Optional[String]',
      desc:   'VRF config',
    },
  },
  autorequire: {
    vrf:    '$vrf', # will evaluate to the value of the `vrf` attribute
  },
)

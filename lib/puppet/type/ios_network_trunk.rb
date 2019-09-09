require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_network_trunk',
  docs: 'Ethernet logical (switch-port) interface.  Configures VLAN trunking.',
  features: ['canonicalize', 'simple_get_filter', 'remote_resource'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether the network_trunk should be present or absent on the target system.',
      default: 'present',
    },
    name: {
      type:   'String',
      desc:   'The switch interface name, e.g. "Ethernet1"',
      behaviour: :namevar,
    },
    encapsulation: {
      type:   'Optional[Enum["dot1q","isl","negotiate","none"]]',
      desc:   'The vlan-tagging encapsulation protocol, usually dot1q',
    },
    mode: {
      type:   'Optional[Enum["access","trunk","dynamic_auto","dynamic_desirable"]]',
      desc:   'The L2 interface mode, enables or disables trunking',
    },
    untagged_vlan: {
      type:    'Optional[Integer[0, 4095]]',
      desc:    'VLAN used for untagged VLAN traffic. a.k.a Native VLAN',
    },
    tagged_vlans: {
      type:    'Optional[Array[String]]',
      desc:    'Array of VLAN names used for tagged packets',
    },
    pruned_vlans: {
      type:    'Optional[Array[String]]',
      desc:    'Array of VLAN ID numbers used for VLAN pruning',
    },
    access_vlan: {
      type:    'Optional[Variant[Integer[0, 4095], Boolean[false]]]',
      desc:    <<DESC,
The VLAN to set when the interface is in access mode. Setting it to false will revert it to the default value.

Examples:

```Puppet
access_vlan => 405
```

```Puppet
access_vlan => false
```
DESC
    },
    voice_vlan: {
      type:    'Optional[Variant[Integer[0, 4095], Enum["dot1p", "none", "untagged"], Boolean[false]]]',
      desc:    <<DESC,
Sets how voice traffic should be treated by the access port. Setting it to false will revert it to the default value.

Examples:

```Puppet
access_vlan => 221
```

```Puppet
access_vlan => 'dot1p'
```

```Puppet
access_vlan => 'false'
```
DESC
    },
    switchport_nonegotiate: {
      type:    'Optional[Boolean]',
      desc:    <<DESC,
When set, prevents the port from sending DTP (Dynamic Trunk Port) messages. Set automatically to true while in 'access mode' and cannot be set in 'dynamic_*' mode.

Examples:

```Puppet
access_vlan => true
```

See `network_trunk` for other availible fields.
DESC
    },
    allowed_vlans: {
      type:    'Optional[Variant[Enum["all", "none"], Tuple[Enum["add", "remove", "except"], String], String, Boolean[false]]]',
      desc:    <<DESC,
Sets which VLANs the access port will use when trunking is enabled. Setting it to false will revert it to the default value.

Examples:

```Puppet
access_vlan => '101-202'
```

```Puppet
access_vlan => 'none'
```

```Puppet
access_vlan => ['except', '204-301']
```
DESC
    },
  },
)

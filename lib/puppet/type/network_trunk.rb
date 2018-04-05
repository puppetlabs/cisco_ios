require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'network_trunk',
  docs: 'Ethernet logical (switch-port) interface.  Configures VLAN trunking.',
  # features: ['remote_resource'],
  attributes: {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether switchport trunking should be present or absent on the target interface.',
      default: 'present',
    },
    name:     {
      type:   'String',
      desc:   'The switch interface name, e.g. "Ethernet1"',
      behaviour: :namevar,
    },
    encapsulation:    {
      type:   'Optional[String]',
      desc:   'The vlan-tagging encapsulation protocol, usually dot1q [dot1q|isl|negotiate|none]',
    },
    mode:    {
      type:   'Optional[String]',
      desc:   'The L2 interface mode, enables or disables trunking[access|trunk|dynamic_auto|dynamic_desirable]',
    },
    untagged_vlan:      {
      type:    'Optional[String]',
      desc:    'VLAN used for untagged VLAN traffic. a.k.a Native VLAN',
    },
    tagged_vlans:      {
      type:    'Optional[String]',
      desc:    'Comma separated string of VLAN names used for tagged packets',
    },
    pruned_vlans:      {
      type:    'Optional[String]',
      desc:    'Comma separated string of VLAN ID numbers used for VLAN pruning',
    },
  },
)

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_network_trunk',
  docs: 'Ethernet logical (switch-port) interface.  Configures VLAN trunking.',
  features: ['canonicalize', 'simple_get_filter'] + (Puppet::Util::NetworkDevice.current.nil? ? [] : ['remote_resource']),
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
      desc:    'The VLAN to set when the interface is in access mode.',
    },
    voice_vlan: {
      type:    'Optional[Variant[Integer[0, 4095], Enum["dot1p", "none", "untagged"], Boolean[false]]]',
      desc:    'Sets how voice traffic should be treated by the access port.',
    },
    switchport_nonegotiate: {
      type:    'Optional[Boolean]',
      desc:    'When set, prevents the port from sending DTP (Dynamic Trunk Port) messages. Set automatically to true while in `access mode` and cannot be set in `dynamic_*` mode.',
    },
    allowed_vlans: {
      type:    'Optional[Variant[Enum["all", "none"], Tuple[Enum["add", "remove", "except"], String], String, Boolean[false]]]',
      desc:    'Sets which VLANs the access port will use when trunking is enabled.',
    },
  },
)

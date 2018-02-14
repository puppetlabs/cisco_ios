require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'network_vlan',
  docs: 'Manage VLANs',
  features: ['remote_resource'],
  attributes: {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this VLAN should be present or absent on the target system.',
      default: 'present',
    },
    name:     {
      type:   'String',
      desc:   'The VLAN ID',
      behaviour: :namevar,
    },
    vlan_name:    {
      type:   'String',
      desc:   'The VLAN name',
    },
    shutdown:    {
      type:      'Boolean',
      desc:      'VLAN shutdown if true, not shutdown if false [true|false]',
      default:   true,
    },
  },
)

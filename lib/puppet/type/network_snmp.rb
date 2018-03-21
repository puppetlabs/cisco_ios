require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'network_snmp',
  docs: 'Manage snmp location, contact and enable SNMP on the device',
  features: ['remote_resource'],
  attributes: {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether the SNMP location and contact should be present or absent on the target system.',
      default: 'present',
    },
    name:     {
      type:   'String',
      desc:   'This defaults to default',
      behaviour: :namevar,
    },
    enable:    {
      type:   'Boolean',
      desc:   'Enable or disable SNMP functionality [true|false]',
    },
    contact:    {
      type:   'String',
      desc:   'The contact name for this device',
    },
    location:    {
      type:   'String',
      desc:   'The location of this device',
    },
  },
)

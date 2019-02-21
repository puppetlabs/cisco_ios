require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_access_list',
  docs: 'Configure access list on device',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'Access list name or number.',
      behaviour: :namevar,
    },
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this access list should be present or absent on the target system.',
      default: 'present',
    },
    access_list_type:      {
      type:    'Enum["Standard","Extended","Reflexive","none"]',
      desc:    'Type of access list - standard, extended, reflexive or no type',
    },
  },
)

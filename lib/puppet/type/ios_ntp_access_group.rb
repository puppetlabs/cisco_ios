require 'puppet/resource_api'
Puppet::ResourceApi.register_type(
  name: 'ios_ntp_access_group',
  docs: 'Specify NTP access group config',
  features: ['canonicalize', 'simple_get_filter', 'remote_resource'],
  attributes: {
    name: {
      type:      'String',
      desc:      'Configuration name, ip access list name',
      behaviour: :namevar,
    },
    access_group_type: {
      type: 'Enum["peer", "serve", "query-only", "serve-only"]',
      desc: 'Defines the access group type',
    },
    ipv6_access_group: {
      type: 'Optional[Boolean]',
      desc: 'Whether this access group makes use of ipv6',
    },
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this access group entry should be present or absent on the target system.',
      default: 'present',
    },
  },
)

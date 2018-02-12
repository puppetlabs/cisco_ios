require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'snmp_community',
  docs: 'Manage the SNMP community',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether the SNMP Community should be present or absent on the target system.',
      default:    'present',
    },
    name:           {
      type:       'String',
      desc:       'The name of the community, e.g. "public" or "private"',
      behaviour:  :namevar,
    },
    group:           {
      type:       'Optional[String]',
      desc:       'The SNMP group for this community',
    },
    acl:           {
      type:       'Optional[String]',
      desc:       'The ACL name to associate with this community string',
    },
  },
)

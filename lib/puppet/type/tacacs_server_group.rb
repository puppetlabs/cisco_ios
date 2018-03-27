require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'tacacs_server_group',
  docs: 'Configure a tacacs server group',
  features: ['remote_resource'],
  attributes: {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this network interface should be present or absent on the target system.',
      default: 'present',
    },
    name:         {
      type:      'String',
      desc:      'The name of the tacacs server group',
      behaviour: :namevar,
    },
    # Comma separated string of servers associated with this group
    servers: {
      type:      'Optional[String]',
      desc:      'String of servers associated with this group',
    },
  },
)

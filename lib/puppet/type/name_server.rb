require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'name_server',
  docs: 'Configure the resolver to use the specified DNS server',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether the name server should be present or absent on the target system.',
      default:    'present',
    },
    name:         {
      type:      'String',
      desc:      'The hostname or address of the DNS server',
      behaviour: :namevar,
    },
  },
)

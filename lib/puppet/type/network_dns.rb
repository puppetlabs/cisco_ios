require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'network_dns',
  docs: 'Configure DNS settings for network devices',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether the network dns should be present or absent on the target system.',
      default:    'present',
    },
    name:         {
      type:      'String',
      desc:      'Configure DNS settings for network devices',
      behaviour: :namevar,
      default:    'default',
    },
    domain:         {
      type:      'Optional[String]',
      desc:      'Array of DNS suffixes to search for FQDN entries',
    },
    search:         {
      type:      'Optional[Array[String]]',
      desc:      'Array of DNS suffixes to search for FQDN entries',
    },
    servers:         {
      type:      'Optional[Array[String]]',
      desc:      'Array of DNS servers to use for name resolution',
    },
  },
)

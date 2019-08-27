require 'puppet/resource_api'
Puppet::ResourceApi.register_type(
  name: 'ios_network_dns',
  docs: 'Configure DNS settings for network devices',
  features: ['canonicalize', 'simple_get_filter', 'remote_resource'],
  attributes: {
    ensure: {
      type:       'Enum[present, absent]',
      desc:       'Whether the network dns should be present or absent on the target system.',
      default:    'present',
    },
    name: {
      type:      'String',
      desc:      'Name, generally "settings", not used to manage the resource',
      behaviour: :namevar,
      default:    'settings',
    },
    domain: {
      type:      'Optional[String]',
      desc:      'The default domain name to append to the device hostname',
    },
    hostname: {
      type:      'Optional[String]',
      desc:      'The host name of the device',
    },
    search: {
      type:      'Optional[Array[String]]',
      desc:      'Array of DNS suffixes to search for FQDN entries',
    },
    servers: {
      type:      'Optional[Array[String]]',
      desc:      'Array of DNS servers to use for name resolution',
    },
    ip_domain_lookup: {
      type:    'Optional[Boolean]',
      desc:    'Sets whether the Domain Name Server (DNS) lookup feature should be enabled',
    },
  },
)

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_radius_server_group',
  docs: 'Configure a RADIUS server group',
  features: ['canonicalize', 'remote_resource'],
  attributes: {
    ensure: {
      type:       'Enum[present, absent]',
      desc:       'Whether radius_server_group should be present or absent on the target system.',
      default:    'present',
    },
    name: {
      type:      'String',
      desc:      'The name of the RADIUS server group',
      behaviour: :namevar,
    },
    servers: {
      type:      'Optional[Array[String]]',
      desc:      'Array of DNS suffixes to search for FQDN entries',
    },
    private_servers: {
      type:      'Optional[Array[String]]',
      desc:      'Array of private DNS suffixes to search for FQDN entries',
    },
  },
)

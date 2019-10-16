require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_cef',
  docs: 'Implementation and Management of CEF settings',
  features: ['remote_resource', 'canonicalize'],
  attributes: {
    name: {
      type:       'String',
      desc:       'Resource name, not used to manage the device',
      behaviour:  :namevar,
      default:    'default',
    },
    distributed: {
      type:    'Optional[Boolean]',
      desc:    'Distributed Cisco Express Forwarding',
    },
    optimize_resolution: {
      type:    'Optional[Boolean]',
      desc:    'Trigger layer 2 address resolution directly from CEF',
    },
    load_sharing: {
      type:    "Optional[Variant[Enum['original', 'tunnel', 'universal'], Tuple[Enum['tunnel', 'universal'], String], Tuple[Enum['include-ports'], Enum['destination', 'source']], Tuple[Enum['include-ports'], Enum['destination', 'source'], String]]]", # rubocop:disable Metrics/LineLength
      desc:    'Per-destination load sharing algorithm selection',
    },
  },
)

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_ip',
  docs: 'Manages settings related to the IP',
  features: ['remote_resource', 'canonicalize'],
  attributes: {
    name: {
      type:       'String',
      desc:       'Resource name, not used to manage the device',
      behaviour:  :namevar,
      default:    'default',
    },
    routing: {
      type:    'Optional[Boolean]',
      desc:    'Whether to Enable IP routing',
    },
  },
)

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'banner',
  docs: 'Set various banners on a device',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'Banner resource. The name stays as "default"',
      behaviour: :namevar,
      default: 'default',
    },
    motd:      {
      type:    'String',
      desc:    'The MOTD banner',
    },
  },
)

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_aaa_new_model',
  docs: 'Enable aaa new model on device',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'The name stays as "default"',
      behaviour: :namevar,
      default:   'default',
    },
    enable:      {
      type:    'Boolean',
      desc:    'Enable or disable aaa new model',
    },
  },
)

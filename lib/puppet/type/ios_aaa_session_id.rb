require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_aaa_session_id',
  docs: 'Configure aaa session id on device',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'The name stays as "default"',
      behaviour: :namevar,
      default:   'default',
    },
    session_id_type:      {
      type:    'Enum["common","unique"]',
      desc:    'Type of aaa session id - common or unique',
    },
  },
)

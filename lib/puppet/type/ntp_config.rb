require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ntp_config',
  docs: 'Specify NTP config',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'Config name, default to "default" as the NTP config is global rather than instance based',
      behaviour: :namevar,
      default:   'default',
    },
    authenticate:  {
      type:      'Boolean',
      desc:      'NTP authentication enabled [true|false]',
    },
    source_interface:  {
      type:      'String',
      desc:      'The source interface for the NTP system',
    },
    # Comma separated string of trusted keys
    # eg. "42,64,128"
    trusted_key: {
      type:      'String',
      desc:      'The encryption type',
    },
  },
)

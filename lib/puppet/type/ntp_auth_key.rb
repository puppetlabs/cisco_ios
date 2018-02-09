require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ntp_auth_key',
  docs: 'Specify an NTP auth key',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether this ntp server should be present or absent on the target system.',
      default:    'present',
    },
    name:         {
      type:      'String',
      desc:      'The keyname',
      behaviour: :namevar,
    },
    algorithm:    {
      type:      'String',
      desc:      'Algorithm eg. md5',
    },
    key:          {
      type:      'String',
      desc:      'The key',
    },
    encryption_type: {
      type:      'Integer',
      desc:      'The encryption type',
    },
  },
)

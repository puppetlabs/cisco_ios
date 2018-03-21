require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'domain_name',
  docs: 'Configure the domain name of the device',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether the name server should be present or absent on the target system.',
      default:    'present',
    },
    name:         {
      type:      'String',
      desc:      'Config name, default to "default" as the NTP config is global rather than instance based',
      behaviour: :namevar,
    },
  },
)

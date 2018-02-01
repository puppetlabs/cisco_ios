require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'network_interface',
  docs: 'Manage physical network interfaces, e.g. Ethernet1',
  #  features: ['remote_resource'],
  attributes: {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this network interface should be present or absent on the target system.',
      default: 'present',
    },
    enable:      {
      type:    'Boolean',
      desc:    'Whether this network interface should be enabled on the target system.',
      default: 'false',
    },
    name:     {
      type:   'String',
      desc:   'Interface Name, e.g. Ethernet1',
      behaviour: :namevar,
    },
    description:    {
      type:   'Optional[String]',
      desc:   'Interface physical port description',
    },
    mtu:    {
      type:   'Integer',
      desc:   'Interface Maximum Transmission Unit in bytes',
    },
    # TODO: expand resource API to allow an extended enum for speed and duplex
    speed:      {
      type:    'Optional[String]',
      desc:    'Link speed [auto*|10m|100m|1g|10g|40g|56g|100g]',
    },
    duplex:      {
      type:    'Optional[String]',
      desc:    'Duplex mode [auto*|full|half]',
    },
  },
)

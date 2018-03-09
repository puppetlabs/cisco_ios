require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'tacacs_server',
  docs: 'Configure a tacacs server',
  features: ['remote_resource'],
  attributes: {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this tacacs server should be present or absent on the target system.',
      default: 'present',
    },
    name:     {
      type:   'String',
      desc:   'Name of the tacacs server',
      behaviour: :namevar,
    },
    hostname:    {
      type:   'Optional[String]',
      desc:   'ipv4 address of the tacacs server',
    },
    single_connection:    {
      type:   'Boolean',
      desc:   'Enable or disable session multiplexing [true|false]',
    },
    port:      {
      type:    'Integer',
      desc:    'The port of the tacacs server',
    },
    key:      {
      type:    'Optional[String]',
      desc:    'Encryption key (plaintext or in hash form depending on key_format)',
    },
    key_format:      {
      type:    'Integer',
      desc:    'Encryption key format [0|7]',
    },
    timeout:      {
      type:    'Integer',
      desc:    'Number of seconds before the timeout period ends',
    },
  },
)

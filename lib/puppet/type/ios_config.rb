require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_config',
  docs: 'Execute an arbitary configuration against the cisco_ios device with or without a check for idempotency',
  features: ['canonicalize', 'remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'The friendly name for this ios command',
      behaviour: :namevar,
    },
    command:      {
      type:    'String',
      desc:    'The ios command to run',
    },
    command_mode:      {
      type:    'Optional[Enum["CONF_T"]]',
      desc:    'The command line mode to be in, when executing the command',
      default: 'CONF_T',
      behaviour: :parameter,
    },
    idempotent_regex:      {
      type:    'Optional[String]',
      desc:    "Expected string, when running a regex against the 'show running-config'",
      behaviour: :parameter,
    },
    idempotent_regex_options:      {
      type:    'Optional[Array[Enum["ignorecase","extended","multiline","fixedencoding","noencoding"]]]',
      desc:    'Array of one or more options which control how the pattern can match.',
      behaviour: :parameter,
    },
    negate_idempotent_regex:      {
      type:    'Optional[Boolean]',
      desc:    'Negate the regex used with idempotent_regex',
      default: false,
      behaviour: :parameter,
    },
  },
)

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_snmp_global',
  docs: 'Configures Global snmp settings.',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'ID of the snmp global config. Valid values are default.',
      default:   'default',
      behaviour: :namevar,
    },
    trap_source:  {
      type:    "Optional[Variant[String, Enum['unset']]]",
      desc:    'Assigns an interface for the source address of all traps.',
    },
    system_shutdown:  {
      type:    'Optional[Boolean]',
      desc:    'Enables use of the SNMP reload command.',
    },
    contact:  {
      type:    "Optional[Variant[String, Enum['unset']]]",
      desc:    'Text for mib object sysContact.',
    },
    manager:  {
      type:    'Optional[Boolean]',
      desc:    'Enables the SNMP manager.',
    },
    manager_session_timeout:  {
      type:    "Optional[Variant[Integer, Enum['unset']]]",
      desc:    'Modifies the SNMP manager timeout parameter.',
    },
    ifmib_ifindex_persist:  {
      type:    'Optional[Boolean]',
      desc:    'Enables IF-MIB ifindex persistence.',
    },
  },
)

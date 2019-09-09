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
      desc:    <<DESC,
Assigns an interface for the source address of all traps. Setting it to 'unset' will revert it to the default value.

Examples:
```
trap_source => 'GigabitEthernet0/3'
```
```
trap_source => 'unset'
```
DESC
    },
    system_shutdown:  {
      type:    'Optional[Boolean]',
      desc:    'Enables use of the SNMP reload command.',
    },
    contact:  {
      type:    "Optional[Variant[String, Enum['unset']]]",
      desc:    <<DESC,
Sets text for the mib object sysContact. Setting it to 'unset' will revert it to the default value.

Examples:
```
contact => 'SNMP_TEST'
```
```
contact => 'unset'
```
DESC
    },
    manager:  {
      type:    'Optional[Boolean]',
      desc:    'When set this value enables the SNMP manager.',
    },
    manager_session_timeout:  {
      type:    "Optional[Variant[Integer, Enum['unset']]]",
      desc:    <<DESC,
Modifies the SNMP manager timeout parameter.

Examples:
```
manager_session_timeout => 20
```
```
manager_session_timeout => unset
```
DESC

    },
    ifmib_ifindex_persist:  {
      type:    'Optional[Boolean]',
      desc:    'Enables IF-MIB ifindex persistence.',
    },
  },
)

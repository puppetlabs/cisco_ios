require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'snmp_notification_receiver',
  docs: 'Manage an SNMP notification receiver',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether the SNMP notification receiver should be present or absent on the target system.',
      default:    'present',
    },
    name:           {
      type:       'String',
      desc:       'Composite ID of name / username / port (if applicable)',
      behaviour:  :namevar,
    },
    host:         {
      type:      'String',
      desc:      'Hostname or IP address of the receiver',
    },
    port:          {
      type:      'Integer',
      desc:      'SNMP UDP port number',
    },
    username:      {
      type:      'String',
      desc:      'Username to use for SNMPv3 privacy and authentication.  This is the'\
                     'community string for SNMPv1 and v2',
    },
    version:      {
      type:      'Optional[String]',
      desc:      'SNMP version [1|2c|3]',
    },
    type:       {
      type:      'Optional[String]',
      desc:      'The type of receiver [traps|informs]',
    },
    security:     {
      type:      'Optional[String]',
      desc:      'SNMPv3 security mode [auth|noauth|priv]',
    },
    vrf:          {
      type:      'Optional[String]',
      desc:      'Interface to send SNMP data from, e.g. "management"',
    },
  },
)

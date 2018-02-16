require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'snmp_user',
  docs: 'Set the SNMP contact name',
  features: ['remote_resource'],
  attributes: {
    ensure:       {
      type:       'Enum[present, absent]',
      desc:       'Whether the SNMP User should be present or absent on the target system.',
      default:    'present',
    },
    name:         {
      type:       'String',
      desc:       'Composite ID of username / version (if applicable)',
      behaviour:  :namevar,
    },
    username:     {
      type:       'String',
      desc:       'The name of the SNMP user',
    },
    version:      {
      type:      'Optional[String]',
      desc:      'SNMP version [v1|v2|v2c|v3]',
    },
    roles:        {
      type:       'String',
      desc:       'A list of roles associated with this SNMP user',
    },
    auth:         {
      type:      'Optional[String]',
      desc:      'Authentication mode [md5|sha]',
    },
    password:     {
      type:      'Optional[String]',
      desc:      'Cleartext password for the user',
    },
    privacy:      {
      type:      'Optional[String]',
      desc:      'Privacy encryption method [aes128|des]',
    },
    private_key:  {
      type:      'Optional[String]',
      desc:      'Private key in hexadecimal string',
    },
    localized_key:  {
      type:      'Boolean',
      desc:      'If true, password needs to be a hexadecimal value [true|false]',
    },
    enforce_privacy:  {
      type:      'Boolean',
      desc:      'If true, message encryption is enforced [true|false]',
    },
    engine_id:    {
      type:      'Optional[String]',
      desc:      'Necessary if the SNMP engine is encrypting data',
    },
  },
)

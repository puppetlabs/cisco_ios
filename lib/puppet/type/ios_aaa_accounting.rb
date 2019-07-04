require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_aaa_accounting',
  docs: 'Configure aaa accounting on device',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'Name. On resource this is a composite of the authorization_service (and enable level if "commands") and authorization_list name eg. "commands 15 default" or "exec authlist1"',
      behaviour: :namevar,
      default:   'default',
    },
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this aaa accounting should be present or absent on the target system.',
      default: 'present',
    },
    accounting_service:    {
      type:    'Enum["auth-proxy","commands","connection","dot1x","exec","identity","network","onep","resource"]',
      desc:    'AAA Accounting service to use',
    },
    commands_enable_level:   {
      type:    'Optional[Integer]',
      desc:    'Enable level - needed for "commands" accounting_service',
    },
    accounting_list:    {
      type:    'String',
      desc:    'The accounting list - named or default',
      default: 'default',
    },
    accounting_status:    {
      type:    'Enum["none","start-stop","stop-only"]',
      desc:    'The status of the accounting',
    },
    server_groups:    {
      type:    'Optional[Array[String]]',
      desc:    "Array of the server groups eg. ['tacacs+'], ['test1', 'test2']",
    },
  },
)

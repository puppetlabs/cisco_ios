require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_aaa_accounting',
  docs: 'Configure aaa accounting on device',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      <<-pp,
Name. On resource this is a composite of the authorization_service (and enable level if "commands")
 and authorization_list name eg. "commands 15 default" or "exec authlist1" - or "update" type eg. "update newinfo"
pp
      behaviour: :namevar,
      default:   'default',
    },
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this aaa accounting should be present or absent on the target system.',
      default: 'present',
    },
    accounting_service:    {
      type:    'Enum["auth-proxy","commands","connection","dot1x","exec","identity","network","onep","resource","system","update"]',
      desc:    'AAA Accounting service to use',
    },
    commands_enable_level:   {
      type:    'Optional[Integer]',
      desc:    'Enable level - needed for "commands" accounting_service',
    },
    accounting_list:    {
      type:    'Optional[String]',
      desc:    'The accounting list - named or default',
    },
    accounting_status:    {
      type:    'Optional[Enum["none","start-stop","stop-only"]]',
      desc:    'The status of the accounting',
    },
    server_groups:    {
      type:    'Optional[Array[String]]',
      desc:    "Array of the server groups eg. `['tacacs+'], ['test1', 'test2']`",
    },
    update_newinfo:   {
      type:    'Optional[Boolean]',
      desc:    'Only send accounting update records when we have new acct info. (For periodic use "update_newinfo_periodic") - use with "update" accounting_service.',
    },
    update_newinfo_periodic:   {
      type:    'Optional[Integer[1, 2147483647]]',
      desc:    'Periodic intervals to send accounting update records(in minutes) when we have new acct info. (For non-periodic use "update_newinfo")  - use with "update" accounting_service.',
    },
    update_periodic:   {
      type:    'Optional[Integer[1, 2147483647]]',
      desc:    'Periodic intervals to send accounting update records(in minutes) (For new acct info only use "update_newinfo_periodic") - use with "update" accounting_service.',
    },
  },
)

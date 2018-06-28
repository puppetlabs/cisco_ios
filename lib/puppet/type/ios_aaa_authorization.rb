require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_aaa_authorization',
  docs: 'Configure aaa authorization on device',
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
      desc:    'Whether this aaa authorization should be present or absent on the target system.',
      default: 'present',
    },
    authorization_service:    {
      type:    'Enum["auth-proxy","commands","configuration","exec","network","reverse_access"]',
      desc:    'AAA Authorization service to use',
    },
    commands_enable_level:   {
      type:    'Optional[Integer]',
      desc:    'Enable level - needed for "commands" authorization_service',
    },
    authorization_list:    {
      type:    'String',
      desc:    'The authorization list - named or default',
      default: 'default',
    },
    server_groups:    {
      type:    'Optional[Array[String]]',
      desc:    "Array of the server groups eg. ['tacacs+'], ['test1', 'test2']",
    },
    local:    {
      type:   'Optional[Boolean]',
      desc:   'Use local database.',
      default: false,
    },
    if_authenticated: {
      type:   'Optional[Boolean]',
      desc:   'Succeed if user has authenticated.',
      default: false,
    },
  },
)

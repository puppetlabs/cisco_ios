require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_aaa_authentication',
  docs: 'Configure aaa authentication on device',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'Name. On resource this is a composite of the authentication_list_set and authentication_list name eg. "login default"',
      behaviour: :namevar,
      default:   'default',
    },
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this aaa authentication should be present or absent on the target system.',
      default: 'present',
    },
    authentication_list_set:    {
      type:    'Enum["arap","login","enable","dot1x","eou","ppp","sgbp"]',
      desc:    'Set authentication lists for - Login, Enable or dot1x',
    },
    authentication_list:    {
      type:    'String',
      desc:    'The authentication list - named or default',
      default: 'default',
    },
    server_groups:    {
      type:    'Optional[Array[String]]',
      desc:    "Array of the server groups eg. ['tacacs+'], ['test1', 'test2']",
    },
    enable_password:    {
      type:    'Optional[Boolean]',
      desc:    'Use enable password for authentication.',
      default: false,
    },
    local:    {
      type:   'Optional[Boolean]',
      desc:   'Use local username authentication.',
      default: false,
    },
    switch_auth: {
      type:   'Optional[Boolean]',
      desc:   'Switch authentication.',
      default: false,
    },
  },
)

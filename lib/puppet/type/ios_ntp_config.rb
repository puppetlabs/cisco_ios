require 'puppet/resource_api'
Puppet::ResourceApi.register_type(
  name: 'ios_ntp_config',
  docs: 'Specify NTP config',
  features: ['canonicalize', 'simple_get_filter', 'remote_resource'],
  attributes: {
    name: {
      type:      'String',
      desc:      'Config name, default to "default" as the NTP config is global rather than instance based',
      behaviour: :namevar,
      default:   'default',
    },
    authenticate: {
      type:      'Optional[Boolean]',
      desc:      'NTP authentication enabled [true|false]',
    },
    source_interface: {
      type:      'Optional[String]',
      desc:      'The source interface for the NTP system',
    },
    trusted_key: {
      type:      'Optional[Array[Variant[Integer, String]]]',
      desc:      'Array of global trusted-keys. Contents can be a String or Integers',
    },
    update_calendar: {
      type: 'Optional[Boolean]',
      desc: 'Whether the update calendar option is enabled on the system',
    },
    logging: {
      type: 'Optional[Boolean]',
      desc: 'Whether to enable NTP message logging',
    },
  },
)

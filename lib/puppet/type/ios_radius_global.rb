require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_radius_global',
  docs: 'Configure IOS global RADIUS settings',
  features: ['canonicalize', 'simple_get_filter'] + (Puppet::Util::NetworkDevice.current.nil? ? [] : ['remote_resource']),
  attributes: {
    name: {
      type:       'String',
      desc:       'Resource name, not used to manage the device',
      behaviour:  :namevar,
      default:    'default',
    },
    enable: {
      type:      'Optional[Boolean]',
      desc:      'Enable or disable RADIUS functionality [true|false]',
    },
    attributes: {
      type:      'Optional[Array[Tuple[Integer, String]]]',
      desc:      'An array of [attribute number, attribute options] pairs',
    },
    key: {
      type:      'Optional[String]',
      desc:      'Encryption key (plaintext or in hash form depending on key_format)',
    },
    key_format: {
      type:      'Optional[Integer]',
      desc:      'Encryption key format [0-7]',
    },
    retransmit_count: {
      type:      'Optional[Variant[Integer, Enum["unset"]]]',
      desc:      "How many times to retransmit or 'unset' (Cisco Nexus only)",
    },
    source_interface: {
      type:      'Optional[Array[String]]',
      desc:      'The source interface used for RADIUS packets (array of strings for multiple).',
    },
    timeout: {
      type:      'Optional[Variant[Integer, Enum["unset"]]]',
      desc:      "Number of seconds before the timeout period ends or 'unset' (Cisco Nexus only)",
    },
    vrf: {
      type:      'Optional[Array[String]]',
      desc:      'The VRF associated with source_interface (array of strings for multiple).',
    },
  },
)

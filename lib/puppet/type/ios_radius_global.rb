require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_radius_global',
  docs: 'Configure IOS global RADIUS settings',
  features: ['canonicalize', 'simple_get_filter', 'remote_resource'],
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
      desc:      <<DESC,
An array of [attribute number, attribute options] pairs,

> NOTE: There are a huge number of attributes available across devices with varying configuration options. Some of these pose issues for idempotency.
>
> This modules does not attempt to solve these issues and you should take care to review your settings.
>
> Example:
>
> `[11, 'default direction inbound']` will set correctly, however the device will return `[11, 'default direction in']`. You should prefer setting `[11, 'default direction in']`
>
> Example:
>
> `[11, 'default direction outbound']` will set correctly, however the device will remove the setting from the config as this is a default. You should instead prefer not setting this option.

DESC
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
      desc:      "How many times to retransmit or 'unset'",
    },
    source_interface: {
      type:      'Optional[Array[String]]',
      desc:      'The source interface used for RADIUS packets (array of strings for multiple).',
    },
    timeout: {
      type:      'Optional[Variant[Integer, Enum["unset"]]]',
      desc:      "Number of seconds before the timeout period ends or 'unset'",
    },
    vrf: {
      type:      'Optional[Array[String]]',
      desc:      'The VRF associated with source_interface (array of strings for multiple).',
    },
  },
)

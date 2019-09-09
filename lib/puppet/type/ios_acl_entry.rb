require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ios_acl_entry',
  docs: 'Configure access lists entries. Deprecated, due to unreconcilable implementation issues. Use the ios_acl type instead.',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'Name. Made up of access_list and the entry with a space seperator. eg. "list42 10" is from access_list list42 and entry 10.',
      behaviour: :namevar,
    },
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this access list entry should be present or absent on the target system.',
      default: 'present',
    },
    access_list:   {
      type:    'String',
      desc:    'Name of parent access list',
    },
    entry:    {
      type:    'Integer',
      desc:    'Name. Used as sequence number <1-2147483647>',
    },
    dynamic:         {
      type:    'Optional[String]',
      desc:    'Name of a Dynamic list',
    },
    permission:      {
      type:    'Enum["permit", "deny", "evaluate"]',
      desc:    'Specify packets to forward/reject, or evaluate an access list',
    },
    evaluation_name:     {
      type:    'Optional[String]',
      desc:    'Evaluate an access list',
    },
    protocol:    {
      type:    'Optional[Variant[Enum["ahp","eigrp","esp","gre","icmp","igmp","ip","ipinip","nos","ospf","pcp","pim","tcp","udp"],Pattern[/\d+/]]]',
      desc:     <<DESC,
The ACL Entry Protocol

Example:
```puppet
protocol => 'tcp'
```
```puppet
protocol => '8'
```
DESC
    },
    source_address:   {
      type:    'Optional[String]',
      desc:    'Source Address. Either Source Address, address object-group, any or source host are required.',
    },
    source_address_group:   {
      type:    'Optional[String]',
      desc:    'Source Address object-group. Either Source Address, address object-group, any or source host are required.',
    },
    source_address_any:   {
      type:    'Optional[Boolean]',
      desc:    'Source Address. Either Source Address, address object-group, any or source host are required.',
    },
    source_address_host:   {
      type:    'Optional[String]',
      desc:    'Source Address. Either Source Address, address object-group, any or source host are required.',
    },
    source_address_wildcard_mask:   {
      type:    'Optional[String]',
      desc:    'Source Address wildcard mask. Must be used with, and only used with, Source Address.',
    },
    source_eq:   {
      type:    'Optional[Array[String]]',
      desc:    'Match only packets on a given port number.',
    },
    source_gt:   {
      type:    'Optional[String]',
      desc:    'Match only packets with a greater port number.',
    },
    source_lt:   {
      type:    'Optional[String]',
      desc:    'Match only packets with a lower port number.',
    },
    source_neq:   {
      type:    'Optional[String]',
      desc:    'Match only packets not on a given port number.',
    },
    source_portgroup:   {
      type:    'Optional[String]',
      desc:    'Destination port object-group.',
    },
    source_range:   {
      type:    'Optional[Array[String]]',
      desc:    'Match only packets in the range of port numbers.',
    },
    destination_address:   {
      type:    'Optional[String]',
      desc:    'Destination Address. Either Destination Address, address object-group, any or destination host are required.',
    },
    destination_address_group:   {
      type:    'Optional[String]',
      desc:    'Destination Address object-group. Either Destination Address, address object-group, any or destination host are required.',
    },
    destination_address_any:   {
      type:    'Optional[Boolean]',
      desc:    'Destination Address. Either Destination Address, address object-group, any or destination host are required.',
    },
    destination_address_host:   {
      type:    'Optional[String]',
      desc:    'Destination Address. Either Destination Address, address object-group, any or destination host are required.',
    },
    destination_address_wildcard_mask:   {
      type:    'Optional[String]',
      desc:    'Destination Address wildcard mask. Must be used with, and only used with, Destination Address.',
    },
    destination_eq:   {
      type:    'Optional[Array[String]]',
      desc:    'Match only packets on a given port number.',
    },
    destination_gt:   {
      type:    'Optional[String]',
      desc:    'Match only packets with a greater port number.',
    },
    destination_lt:   {
      type:    'Optional[String]',
      desc:    'Match only packets with a lower port number.',
    },
    destination_neq:   {
      type:    'Optional[String]',
      desc:    'Match only packets not on a given port number.',
    },
    destination_portgroup:   {
      type:    'Optional[String]',
      desc:    'Destination port object-group.',
    },
    destination_range:   {
      type:    'Optional[Array[String]]',
      desc:    'Match only packets in the range of port numbers.',
    },
    ack:   {
      type:    'Optional[Boolean]',
      desc:    'Match on the ACK bit.',
    },
    dscp:   {
      type:    'Optional[String]',
      desc:    'Match packets with given dscp value.',
    },
    fin:   {
      type:    'Optional[Boolean]',
      desc:    'Match on the FIN bit.',
    },
    fragments:   {
      type:    'Optional[Boolean]',
      desc:    'Check non-initial fragments.',
    },
    icmp_message_code:  {
      type:    'Optional[Integer]',
      desc:    'ICMP message code.',
    },
    icmp_message_type:  {
      type:    'Optional[Variant[String, Integer]]',
      desc:    'ICMP message type.',
    },
    igmp_message_type:  {
      type:    'Optional[Variant[String, Integer]]',
      desc:    'IGMP message type.',
    },
    log:   {
      type:    'Optional[Boolean]',
      desc:    'Log matches against this entry. Either log or log_input can be used, but not both.',
    },
    log_input:   {
      type:    'Optional[Boolean]',
      desc:    'Log matches against this entry, including input interface. Either log or log_input can be used, but not both.',
    },
    match_all:   {
      type:    'Optional[Array[String]]',
      desc:    'Match if all specified flags are present.',
    },
    match_any:   {
      type:    'Optional[Array[String]]',
      desc:    'Match if any specified flags are present.',
    },
    option:   {
      type:    'Optional[String]',
      desc:    'Match packets with given IP Options value.',
    },
    precedence:   {
      type:    'Optional[String]',
      desc:    'Match packets with given precedence value.',
    },
    psh:   {
      type:    'Optional[Boolean]',
      desc:    'Match on the PSH bit.',
    },
    reflect:   {
      type:    'Optional[String]',
      desc:    'Create reflexive access list entry.',
    },
    reflect_timeout:   {
      type:    'Optional[Integer]',
      desc:    'Maximum time to live in seconds. Only to be used with reflect.',
    },
    rst:   {
      type:    'Optional[Boolean]',
      desc:    'Match on the RST bit.',
    },
    syn:   {
      type:    'Optional[Boolean]',
      desc:    'Match on the SYN bit.',
    },
    time_range:   {
      type:    'Optional[String]',
      desc:    'Specify a time-range.',
    },
    tos:   {
      type:    'Optional[String]',
      desc:    'Match packets with given TOS value.',
    },
    urg:   {
      type:    'Optional[Boolean]',
      desc:    'Match on the URG bit.',
    },
  },
  autorequire: {
    ios_access_list:    '$access_list', # will evaluate to the value of the `access_list` attribute
  },
)

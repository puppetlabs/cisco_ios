require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'stp_global',
  docs: 'Manages the Cisco Spanning-tree Global configuration resource.',
  features: ['remote_resource'],
  attributes: {
    name:         {
      type:      'String',
      desc:      'ID of the stp global config. Valid values are default.',
      default:   'default',
      behaviour: :namevar,
    },
    enable:  {
      type:    'Optional[Boolean]',
      desc:    'Enable or disable STP functionality [true|false]',
    },
    bridge_assurance:      {
      type:    'Optional[Boolean]',
      desc:    'Bridge Assurance on all network ports',
    },
    loopguard:      {
      type:    'Optional[Boolean]',
      desc:    'Bridge Assurance on all network ports',
    },
    mode:      {
      type:    'Optional[Enum["mst","pvst","rapid-pvst"]]',
      desc:    'Operating Mode',
    },
    mst_forward_time:      {
      type:    'Optional[Integer]',
      desc:    'Forward delay for the spanning tree',
    },
    mst_hello_time:       {
      type:    'Optional[Integer]',
      desc:    'Hello interval for the spanning tree',
    },
    mst_inst_vlan_map:       {
      type:    'Optional[Array[Tuple[Integer,String]]]',
      desc:    'An array of [mst_inst, vlan_range] pairs.',
    },
    mst_max_age:       {
      type:    'Optional[Integer[6,40]]',
      desc:    'Max age interval for the spanning tree',
    },
    mst_max_hops:       {
      type:    'Optional[Integer[1,255]]',
      desc:    'Max hops value for the spanning tree',
    },
    mst_name:         {
      type:      'Optional[String]',
      desc:      'Configuration name.',
    },
    mst_priority:         {
      type:    'Optional[Array[Tuple[String,Integer]]]',
      desc:      'An array of [mst_inst_list, priority] pairs.',
    },
    mst_revision:         {
      type:      'Optional[Integer]',
      desc:      'Configuration revision number.',
    },
    pathcost:      {
      type:    'Optional[Enum["long","short"]]',
      desc:    'Method to calculate default port path cost',
    },
    vlan_forward_time:         {
      type:    'Optional[Array[Tuple[String,Integer]]]',
      desc:      'An array of [vlan_inst_list, forward_time] pairs.',
    },
    vlan_hello_time:         {
      type:    'Optional[Array[Tuple[String,Integer]]]',
      desc:      'An array of [vlan_inst_list, hello_time] pairs.',
    },
    vlan_max_age:         {
      type:    'Optional[Array[Tuple[String,Integer]]]',
      desc:      'An array of [vlan_inst_list, max_age] pairs.',
    },
    vlan_priority:         {
      type:    'Optional[Array[Tuple[String,Integer]]]',
      desc:      'An array of [vlan_inst_list, priority] pairs.',
    },
  },
)

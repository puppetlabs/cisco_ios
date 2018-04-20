network_trunk { 'Port-channel1':
  ensure => 'present',
  encapsulation => 'dot1q',
  mode => 'dynamic_desirable',
  untagged_vlan => '1',
}

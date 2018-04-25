network_vlan { '43':
  ensure    => 'present',
  vlan_name => 'testvlan',
  shutdown  => false,
}

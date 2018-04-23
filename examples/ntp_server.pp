ntp_server { '1.2.3.4':
  ensure           => 'present',
  key              => 94,
  prefer           => true,
  minpoll          => 4,
  maxpoll          => 14,
  source_interface => 'Vlan 42',
}

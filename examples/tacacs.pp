tacacs { 'default':
  ensure           => 'present',
  key              => 'testkey',
  key_format       => 0,
  source_interface => 'Vlan32',
  timeout          => 42,
}

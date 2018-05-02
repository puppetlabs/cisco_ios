port_channel { 'Port-channel42':
  ensure              => 'present',
  description         => 'This is a test port channel',
  speed               => '10m',
  duplex              => 'half',
  flowcontrol_receive => 'on',
  flowcontrol_send    => 'on',
  mode                => 'passive',
  interfaces          => ['GigabitEthernet1/0/4', 'GigabitEthernet1/0/5'],
}

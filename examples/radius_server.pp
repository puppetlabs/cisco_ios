radius_server { '2.2.2.2':
  ensure           => 'present',
  hostname         => '1.2.3.4',
  auth_port        => 1642,
  acct_port        => 1643,
  key              => 'bill',
  key_format       => 1,
  retransmit_count => 7,
  timeout          => 42,
}

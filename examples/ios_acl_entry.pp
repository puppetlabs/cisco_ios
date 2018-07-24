ios_acl_entry { 'test43_30':
  ensure                            => 'present',
  entry                             => 30,
  permission                        => 'deny',
  access_list                       => 'test43',
  protocol                          => 'tcp',
  source_address                    => '1.0.1.4',
  source_address_wildcard_mask      => '4.3.2.1',
  destination_address               => '0.2.4.2',
  destination_address_wildcard_mask => '1.1.1.1',
  match_all                         => ['+ack', '-fin'],
  log                               => true,
}
ios_aaa_accounting { 'network default':
  ensure             => 'present',
  accounting_service => 'network',
  accounting_list    => 'default',
  accounting_status  => 'start-stop',
  server_groups      => ['radius'],
}
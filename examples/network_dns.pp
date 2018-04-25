network_dns { 'default':
  ensure  => 'present',
  servers => ['1.1.1.1', '1.1.1.3'],
  search  => ['jim.com'],
}

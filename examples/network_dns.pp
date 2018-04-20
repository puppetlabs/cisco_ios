network_dns { "default":
  servers => ['1.1.1.1', '1.1.1.3'],
  search => ['jim.com'],
  ensure => 'present',
}

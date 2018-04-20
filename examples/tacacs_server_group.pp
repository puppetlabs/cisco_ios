tacacs_server_group { "test1":
  ensure => 'present',
  servers => ['1.2.3.5','1.2.3.6'],
}

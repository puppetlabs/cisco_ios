snmp_notification_receiver { '9.9.9.9 public 1234':
  username => 'public',
  port => 1234,
  type => 'traps',
  ensure => 'present',
}

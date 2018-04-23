snmp_community { 'ACCEPTANCE':
  ensure => 'present',
  group  => 'RW',
  acl    => 'GREEN',
}

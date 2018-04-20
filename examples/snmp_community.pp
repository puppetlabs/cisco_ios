snmp_community { 'ACCEPTANCE':
  group => 'RW',
  acl => 'GREEN',
  ensure => 'present'
}

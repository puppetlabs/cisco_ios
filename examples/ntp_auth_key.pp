ntp_auth_key { '42':
  ensure => present,
  algorithm => "md5",
  password => "135445415F59",
  mode => 7,
}

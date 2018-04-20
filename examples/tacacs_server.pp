tacacs_server { 'test_tacacs_1':
  ensure => 'present',
  port => '7001',
  key => '32324222424243',
  key_format => '7',
  timeout => '420',
  hostname => '2001:0000:4136:e378:8000:63bf:3fff:fdd2',
  single_connection => true,
}

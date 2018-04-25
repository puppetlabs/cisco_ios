snmp_user { 'bill v3':
  ensure          => 'present',
  version         => 'v3',
  roles           => ['public'],
  auth            => 'md5',
  password        => 'b7:d1:92:a4:4e:0d:a1:6c:d1:80:eb:e8:5e:fb:7c:8f',
  privacy         => 'aes128',
  private_key     => 'b7:d1:92:a4:4e:0d:a1:6c:d1:80:eb:e8:5e:fb:7c:8f',
  enforce_privacy => true,
}

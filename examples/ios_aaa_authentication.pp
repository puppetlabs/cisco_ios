ios_aaa_authentication { 'login default':
  ensure                  => 'present',
  authentication_list_set => 'login',
  authentication_list     => 'default',
  server_groups           => ['test1'],
  enable_password         => false,
  local                   => true,
  switch_auth             => false,
}
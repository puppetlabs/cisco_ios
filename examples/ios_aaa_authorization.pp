ios_aaa_authorization { 'auth-proxy default':
  ensure                => 'present',
  authorization_service => 'auth-proxy',
  authorization_list    => 'default',
  server_groups         => ['tacacs+'],
  local                 => false,
  if_authenticated      => false,
}
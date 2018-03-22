# Private class
class cisco_ios::install {
  include resource_api::agent
  package { 'net-ssh-telnet':
    ensure   => present,
    provider => 'puppet_gem',
  }
}

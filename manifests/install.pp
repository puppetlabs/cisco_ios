# Private class
class cisco_ios::install {
  include resource_api::agent
  package { 'net-ssh-telnet':
    ensure   => present,
    provider => 'puppet_gem',
  }
  if versioncmp($facts['rubyversion'], '2.3.0') < 0 {
    package { 'backport_dig':
      ensure   => present,
      provider => 'puppet_gem',
    }
  }
}

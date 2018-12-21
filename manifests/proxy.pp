# @summary This class install dependencies of this module into puppet agent
#
# @example Declaring the class
#   include cisco_ios::proxy
#
# @note Deprecated, use cisco_ios::install::agent
class cisco_ios::proxy {

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

# Install device module dependencies on a puppet agent.

# @summary Install dependencies into the puppet agent
#
# @example
#   include cisco_ios::install::agent

class cisco_ios::install::agent {
  include resource_api::install

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


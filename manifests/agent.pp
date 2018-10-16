# Install dependencies onto the proxy agent. All your proxy agents
# need to be classified with this class before you can use them to
# manage Palo Alto firewalls.
#
# @summary Install dependencies onto the proxy agent
#
# @example
#   include cisco_ios::agent
class cisco_ios::agent {
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

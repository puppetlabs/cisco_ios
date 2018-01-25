# Private class
class cisco_ios::install inherits cisco_ios {
  if $::puppetversion and $::puppetversion =~ /Puppet Enterprise/ {
    $provider = 'pe_gem'
  } elsif $::puppetversion and versioncmp($::puppetversion, '4.0.0') >= 0 {
    $provider = 'puppet_gem'
  } else {
    $provider = 'gem'
  }

  package { 'facter':
    ensure => absent,
  }
  package { 'puppet-resource_api':
    ensure   => installed,
    provider => $provider,
  }
  package { 'hocon':
    ensure   => installed,
    provider => $provider,
  }
}
# @summary This class installs dependencies of this module
#          into the puppet agent, and/or the puppetserver service.
#
# @example Declaring the class
#   include cisco_ios::install
class cisco_ios::install {

  include cisco_ios::install::agent

  if $facts['puppetserver_installed'] {
    include cisco_ios::install::master
  }
}

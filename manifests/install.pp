# Install device module dependencies on a puppet agent or master.
#
# A proxy agent needs to be classified with this class
# before it can manage devices with this module.
#
# Every master: master of masters, and if present, compile masters and replica
# needs to be classified with this class
# before it can compile catalogs for devices with this module.
#
# @summary Install dependencies into the puppet agent and puppetserver service
#
# @example
#   include cisco_ios::install

class cisco_ios::install {

  include cisco_ios::install::agent

  if $facts['puppetserver_installed'] {
    include cisco_ios::install::master
  }

}

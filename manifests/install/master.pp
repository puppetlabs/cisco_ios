# @summary This class installs dependencies of this module into puppetserver,
#          and restarts the puppetserver service to activate.
#
# @example Declaring the class
#   include cisco_ios::install::master
class cisco_ios::install::master {
  include resource_api::install::master
}

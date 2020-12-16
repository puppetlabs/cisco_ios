# @summary This class installs dependencies of this module into puppetserver,
#          and restarts the puppetserver service to activate.
#
# @example Declaring the class
#   include cisco_ios::install::server
class cisco_ios::install::server {
  include resource_api::install::server
}

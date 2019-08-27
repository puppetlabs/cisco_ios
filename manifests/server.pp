# @summary This class installs dependencies of this module into puppetserver,
#          and restarts the puppetserver service to activate.
#
# @example Declaring the class
#   include cisco_ios::server
#
# @note Deprecated, use cisco_ios::install::master
class cisco_ios::server {
  include resource_api::server
}

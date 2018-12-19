# This class will install all necessary dependencies onto the server
# and restart the puppetserver process. Every compile master and the
# master of masters needs to be classified with this class.
#
# @summary Install dependencies onto the puppetserver
#
# @example
#   include cisco_ios::server
#
# Deprecated by cisco_ios::install::master

class cisco_ios::server {
  include resource_api::server
}

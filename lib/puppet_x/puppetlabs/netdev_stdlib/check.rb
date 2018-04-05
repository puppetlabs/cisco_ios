require 'puppet_x'
module PuppetX::NetdevStdlib
  # Helper function to check if we should load the resource_api
  class Check
    def self.use_old_netdev_type
      false
    end
  end
end

require 'puppet_x'
module PuppetX::NetdevStdlib
  # Helper function to check if we should load the resource_api
  class Check
    def self.use_resource_api
      false
    end
  end
end

# module PuppetX
#  module PuppetLabs
#    module NetdevStdlib
#      class Check
#        def self.use_resource_api
#          false
#        end
#      end
#    end
#  end
# end

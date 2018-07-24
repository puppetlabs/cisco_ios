require 'spec_helper'

module Puppet::Provider::IosAccessList; end
require 'puppet/provider/ios_access_list/ios'

RSpec.describe Puppet::Provider::IosAccessList::IosAccessList do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'
end

require 'spec_helper'

module Puppet::Provider::IosAaaAuthentication; end
require 'puppet/provider/ios_aaa_authentication/cisco_ios'

RSpec.describe Puppet::Provider::IosAaaAuthentication::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'
  it_behaves_like 'device safe instance'
end

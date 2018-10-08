require 'spec_helper'

module Puppet::Provider::RadiusServer; end
require 'puppet/provider/radius_server/ios'

RSpec.describe Puppet::Provider::RadiusServer::RadiusServer do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  it_behaves_like 'a noop canonicalizer'
end

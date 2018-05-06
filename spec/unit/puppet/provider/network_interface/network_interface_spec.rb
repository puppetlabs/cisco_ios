require 'spec_helper'
require 'pry'

module Puppet::Provider::NetworkInterface; end
require 'puppet/provider/network_interface/ios'
require 'puppet_x/puppetlabs/cisco_ios/utility'

RSpec.describe Puppet::Provider::NetworkInterface::NetworkInterface do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end
  it_behaves_like 'resources parsed from cli'

  it_behaves_like 'commands created from instance'
end

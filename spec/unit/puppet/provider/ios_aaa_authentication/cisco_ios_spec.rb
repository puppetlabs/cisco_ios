require 'spec_helper'

module Puppet::Provider::IosAaaAuthentication; end
require 'puppet/provider/ios_aaa_authentication/cisco_ios'

RSpec.describe Puppet::Provider::IosAaaAuthentication::CiscoIos do
  let(:provider) { described_class.new }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'
  it_behaves_like 'device safe instance'

  describe '#canonicalize' do
    it { expect(provider.canonicalize(anything, [{ name: 'onep default', server_groups: ['USAA-AAA', 'AAA-USAA'], cache_groups: ['test2', 'test1'] }])).to eq [{ name: 'onep default', server_groups: ['AAA-USAA', 'USAA-AAA'], cache_groups: ['test1', 'test2'] }] }
  end
end

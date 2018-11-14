require 'spec_helper'

module Puppet::Provider::NetworkVlan; end
require 'puppet/provider/network_vlan/cisco_ios'

RSpec.describe Puppet::Provider::NetworkVlan::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  context 'Edit tests:' do
    load_test_data['default']['edit_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_instance(test['should'])).to eq test['cli']
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end

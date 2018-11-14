require 'spec_helper'

module Puppet::Provider::NetworkTrunk; end
require 'puppet/provider/network_trunk/cisco_ios'

RSpec.describe Puppet::Provider::NetworkTrunk::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        expect(described_class.instance_from_cli(test['cli'], test['expectations'].first[:name])).to eq test['expectations'].first
      end
    end
  end
  it_behaves_like 'commands created from instance'

  it_behaves_like 'a noop canonicalizer'
end

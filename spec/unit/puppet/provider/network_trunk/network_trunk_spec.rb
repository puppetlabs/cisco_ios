require 'spec_helper'

module Puppet::Provider::NetworkTrunk; end
require 'puppet/provider/network_trunk/ios'

RSpec.describe Puppet::Provider::NetworkTrunk::NetworkTrunk do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.instance_from_cli(test['cli'], test['expectations'].first[:name])).to eq test['expectations'].first
      end
    end
  end

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_instance(test['expectations'].first)).to eq test['commands']
      end
    end
  end
end

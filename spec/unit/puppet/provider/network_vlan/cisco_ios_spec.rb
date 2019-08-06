require 'spec_helper'

module Puppet::Provider::NetworkVlan; end
require 'puppet/provider/network_vlan/cisco_ios'

RSpec.describe Puppet::Provider::NetworkVlan::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'a noop canonicalizer'

  context 'Create tests:' do
    load_test_data['default']['create_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.create_commands_from_instance(test['should'])).to eq test['cli']
      end
    end
  end

  context 'Edit tests:' do
    load_test_data['default']['edit_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.update_commands_from_instance(test['should'])).to eq test['cli']
      end
    end
  end

  context 'Vlan defaults throw error tests:' do
    ['1', '1002', '1003', '1004', '1005'].each do |vlan_name|
      ['created', 'updated', 'deleted'].each do |action_verb|
        it "VLAN #{vlan_name} raises exception on #{action_verb}" do
          expect { described_class.validate_vlan(vlan_name, action_verb) }.to raise_error(RuntimeError, "VLAN #{vlan_name} is a Cisco default VLAN and may not be #{action_verb}.")
        end
      end
    end
  end

  context 'Vlan non-defaults do not throw error tests:' do
    ['2', '1001', '1006'].each do |vlan_name|
      it "VLAN #{vlan_name} returns" do
        expect { described_class.validate_vlan(vlan_name, 'absent') }.not_to raise_error
      end
    end
  end
end

require 'spec_helper'

module Puppet::Provider::IosSnmpGlobal; end
require 'puppet/provider/ios_snmp_global/cisco_ios'

RSpec.describe Puppet::Provider::IosSnmpGlobal::CiscoIos do
  let(:utility) { described_class }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'
  it_behaves_like 'a noop canonicalizer'

  describe 'convert_to_boolean' do
    it 'given value' do
      input = 'cake'
      output = true
      expect(utility.convert_to_boolean(input)).to eq output
    end
    it 'given nil' do
      input = nil
      output = false
      expect(utility.convert_to_boolean(input)).to eq output
    end
  end

  describe 'false_to_unset' do
    it 'given string' do
      input = 'cake'
      output = 'cake'
      expect(utility.false_to_unset(input)).to eq output
    end
    it 'given true' do
      input = true
      output = true
      expect(utility.false_to_unset(input)).to eq output
    end
    it 'given false' do
      input = false
      output = 'unset'
      expect(utility.false_to_unset(input)).to eq output
    end
  end
end

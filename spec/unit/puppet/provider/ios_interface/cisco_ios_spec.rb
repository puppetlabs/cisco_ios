require 'spec_helper'

module Puppet::Provider::IosInterface; end
require 'puppet/provider/ios_interface/cisco_ios'

RSpec.describe Puppet::Provider::IosInterface::CiscoIos do
  let(:utility) { described_class }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'], test['family'])
        if test['commands'].size.zero?
          expect { described_class.commands_from_instance(test['instance'], test['current_instance']) }.to raise_error(%r{.*})
        else
          expect(described_class.commands_from_instance(test['instance'], test['current_instance'])).to eq test['commands']
        end
      end
    end
  end

  describe 'false_to_unset' do
    it 'given string' do
      expect(utility.false_to_unset('cake')).to eq 'cake'
    end
    it 'given true' do
      expect(utility.false_to_unset(true)).to eq true
    end
    it 'given false' do
      expect(utility.false_to_unset(false)).to eq 'unset'
    end
  end

  describe 'clean_logging_event' do
    it 'given string' do
      given = { logging_event: 'trunk-status' }
      expected = { logging_event: ['trunk-status'] }
      expect(utility.clean_logging_event(given)).to eq expected
    end
    it 'given string with link_status' do
      given = { logging_event: 'link-status' }
      expected = { logging_event: 'unset' }
      expect(utility.clean_logging_event(given)).to eq expected
    end
    it 'given nil value' do
      given = {}
      expected = { logging_event: 'unset' }
      expect(utility.clean_logging_event(given)).to eq expected
    end
    it 'given array' do
      given = { logging_event: ['trunk-status'] }
      expected = { logging_event: ['trunk-status'] }
      expect(utility.clean_logging_event(given)).to eq expected
    end
    it 'given array with link_status' do
      expect(utility.false_to_unset(true)).to eq true
      given = { logging_event: ['link-status', 'trunk-status'] }
      expected = { logging_event: ['trunk-status'] }
      expect(utility.clean_logging_event(given)).to eq expected
    end
  end
end

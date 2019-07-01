require 'spec_helper'

module Puppet::Provider::IosAdditionalSyslogSettings; end
require 'puppet/provider/ios_additional_syslog_settings/cisco_ios'

RSpec.describe Puppet::Provider::IosAdditionalSyslogSettings::CiscoIos do
  let(:utility) { described_class }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_is_should(test['is'], test['should'])).to eq test['cli']
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'

  describe 'origin_id_command' do
    it 'given array' do
      result = utility.origin_id_command(Hash[:origin_id, ['string', 'thecakeisalie']])
      expect(result[:origin_id]).to eq 'string thecakeisalie'
    end
    it 'given string' do
      result = utility.origin_id_command(Hash[:origin_id, 'ipv6'])
      expect(result[:origin_id]).to eq 'ipv6'
    end
  end

  describe 'origin_id_extract' do
    it 'given array' do
      result = utility.origin_id_extract('string thecakeisalie')
      expect(result).to eq ['string', 'thecakeisalie']
    end
    it 'given string' do
      result = utility.origin_id_extract('ipv6')
      expect(result).to eq 'ipv6'
    end
  end
end

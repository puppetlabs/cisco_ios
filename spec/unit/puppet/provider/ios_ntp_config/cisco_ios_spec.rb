require 'spec_helper'

module Puppet::Provider::IosNtpConfig; end
require_relative '../../../../../lib/puppet/provider/ios_ntp_config/cisco_ios'

RSpec.describe Puppet::Provider::IosNtpConfig::CiscoIos do
  let(:provider) { described_class.new }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  describe '#canonicalize' do
    it { expect(provider.canonicalize(anything, [{ name: 'foo', trusted_keys: ['12', '48', '24', '96'] }])).to eq [{ name: 'foo', trusted_keys: ['12', '24', '48', '96'] }] }
  end

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_is_should(test['is'], test['should'])).to eq test['cli']
      end
    end
  end
end

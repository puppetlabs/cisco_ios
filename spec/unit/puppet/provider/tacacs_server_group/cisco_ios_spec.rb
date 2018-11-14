require 'spec_helper'

module Puppet::Provider::TacacsServerGroup; end
require 'puppet/provider/tacacs_server_group/cisco_ios'

RSpec.describe Puppet::Provider::TacacsServerGroup::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  context 'Tacacs update tests:' do
    load_test_data['default']['update_tacacs_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_instance(test['instance'])).to eq test['cli']
      end
    end
  end

  context 'Server update tests:' do
    load_test_data['default']['update_server_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_is_should(test['is'], test['should'])).to eq test['cli']
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end

require 'spec_helper'

module Puppet::Provider::SearchDomain; end
require 'puppet/provider/search_domain/ios'

RSpec.describe Puppet::Provider::SearchDomain::SearchDomain do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it "Read: #{test_name}" do
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
      end
    end
  end

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.command_from_instance(test['instance'])).to eq test['cli']
      end
    end
  end
end

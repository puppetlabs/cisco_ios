require 'spec_helper'

module Puppet::Provider::NetworkSnmp; end
require 'puppet/provider/network_snmp/ios'

RSpec.describe Puppet::Provider::NetworkSnmp::NetworkSnmp do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
      end
    end
  end

  context 'Read and Create tests:' do
    load_test_data['default']['read_and_create_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['commands']
      end
    end
  end

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['commands']
      end
    end
  end
end

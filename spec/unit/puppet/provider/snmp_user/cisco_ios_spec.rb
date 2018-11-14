require 'spec_helper'

module Puppet::Provider::SnmpUser; end
require 'puppet/provider/snmp_user/cisco_ios'

RSpec.describe Puppet::Provider::SnmpUser::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read and Create tests:' do
    load_test_data['default']['read_and_create_tests'].each do |test_name, test|
      it test_name.to_s do
        if test['version'] == 'v1'
          expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
        else
          expect(described_class.instances_from_cli_v3(test['cli'])).to eq test['v3_read_expectations']
        end
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['commands']
      end
    end
  end
  context 'Create tests:' do
    load_test_data['default']['create_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['commands']
      end
    end
  end
  context 'Delete tests:' do
    load_test_data['default']['delete_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['commands']
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end

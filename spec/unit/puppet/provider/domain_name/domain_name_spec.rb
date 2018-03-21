require 'spec_helper'

module Puppet::Provider::DomainName; end
require 'puppet/provider/domain_name/ios'

RSpec.describe Puppet::Provider::DomainName::DomainName do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read & Update tests:' do
    load_test_data['default']['read_update_tests'].each do |test_name, test|
      it "Read: #{test_name}" do
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
      end
      it "Update: #{test_name}" do
        cli = ''
        test['expectations'].each do |instance|
          cli = cli + described_class.command_from_instance(instance) + "\n"
        end
        expect(cli).to eq test['cli']
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

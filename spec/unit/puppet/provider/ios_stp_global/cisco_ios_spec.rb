require 'spec_helper'

module Puppet::Provider::IosStpGlobal; end
require 'puppet/provider/ios_stp_global/cisco_ios'

RSpec.describe Puppet::Provider::IosStpGlobal::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  context 'Read Bridge Assurance tests:' do
    load_test_data['default']['bridge_assurance_read_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        expect(described_class.bridge_assurance_from_output(test['cli']).to_s).to eq test['expectations'].first[:bridge_assurance].to_s
      end
    end
  end

  context 'Update MST mode tests:' do
    load_test_data['default']['mst_mode_update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        if test['commands'].size.zero?
          expect { described_class.mst_commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          expect(described_class.mst_commands_from_instance(test['instance'])).to eq test['commands']
        end
      end
    end
  end

  context 'Update portfast tests:' do
    load_test_data['default']['portfast_update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        if test['commands'].size.zero?
          expect { described_class.portfast_commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          expect(described_class.portfast_commands_from_instance(test['instance'])).to eq test['commands']
        end
      end
    end
  end
end

require 'spec_helper'

module Puppet::Provider::PortChannel; end
require 'puppet/provider/port_channel/ios'

RSpec.describe Puppet::Provider::PortChannel::PortChannel do
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

  context 'Read Interface tests:' do
    load_test_data['default']['read_interface_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.portchannel_interface_names_from_cli(test['cli'])).to eq test['expectations']
      end
    end
  end

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_instance(test['instance'])).to eq test['commands']
      end
    end
  end

  context 'Update Interface tests:' do
    load_test_data['default']['update_interface_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.interface_commands_from_instance(test['instance'])).to eq test['commands']
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end

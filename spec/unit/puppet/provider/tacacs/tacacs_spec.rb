require 'spec_helper'

module Puppet::Provider::Tacacs; end
require 'puppet/provider/tacacs/ios'

RSpec.describe Puppet::Provider::Tacacs::Tacacs do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read and Create tests:' do
    load_test_data['default']['read_and_create_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['cli']
      end
    end
  end

  context 'Create tests:' do
    load_test_data['default']['create_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['cli']
      end
    end
  end

  context 'Create 2960 tests:' do
    load_test_data[2960]['create_tests'].each do |test_name, test|
      it test_name.to_s do
        # rubocop:disable RSpec/MessageChain
        allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive_message_chain(:transport, :facts)
          .and_return('operatingsystem' => 'cisco_ios',
                      'operatingsystemrelease' => '12.2(58)SE2',
                      'hardwaremodel' => 'WS-C2960S-48FPS-L',
                      'serialnumber' => 'FOC1609Y2LY')
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['cli']
        # rubocop:enable RSpec/MessageChain
      end
    end
  end
end

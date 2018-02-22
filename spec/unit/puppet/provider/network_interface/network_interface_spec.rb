require 'spec_helper'

module Puppet::Provider::NetworkInterface; end
require 'puppet/provider/network_interface/ios'

RSpec.describe Puppet::Provider::NetworkInterface::NetworkInterface do
  def self.load_test_data
    Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  load_test_data['default']['tests'].each do |test_name, test|
    context test_name do
      it 'parses the output to the data' do
        expect(described_class.interface_parse_out(test['device_output'])).to eq test['previous_set'] || test['expectations']
      end

      test['commands'].zip(test['expectations']).each do |command, expectation|
        it "generates the command for #{expectation.inspect}" do
          expect(described_class.interface_config_command(expectation)).to eq command
        end
      end
    end
  end

  describe '#get' do
    before(:each) do
      allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_enable_mode).with('show running-config | section ^interface').and_return(output)
    end
    context 'with no output' do
      let(:output) { nil }

      it { expect(provider.get(context)).to eq [] }
    end

    context 'with some interfaces' do
      let(:output) do
        <<EOS
interface Vlan4
 description this is a test
 mtu 126
 no ip address
 ip mtu 125
 shutdown
interface Vlan5
 description this is also a test
 no ip address
 ip mtu 125
EOS
      end

      it {
        expect(provider.get(context)).to eq [
          { name: 'Vlan4', enable: false, ensure: :present, description: 'this is a test', mtu: 126 },
          { name: 'Vlan5', enable: true, ensure: :present, description: 'this is also a test' },
        ]
      }
    end
  end

  describe '#create' do
    it 'runs run_command_interface_mode' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_interface_mode).with('Vlan4', " description this is a test\n mtu 128\n shutdown\n")
      provider.create(context, 'Vlan4', name: 'Vlan4', enable: false, ensure: :present, description: 'this is a test', mtu: 128)
    end
  end

  describe '#update' do
    it 'runs run_command_interface_mode' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_interface_mode).with('Vlan4', " description this is a test\n mtu 128\n shutdown\n")
      provider.update(context, 'Vlan4', name: 'Vlan4', enable: false, ensure: :present, description: 'this is a test', mtu: 128)
    end
  end

  describe '#delete' do
    it 'runs run_command_interface_mode' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with("default interface Vlan4\nno interface Vlan4")
      provider.delete(context, 'Vlan4')
    end
  end
end

require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::SnmpNotificationReceiver; end
require 'puppet/provider/snmp_notification_receiver/snmp_notification_receiver'
require 'net/ssh/telnet'

test_data = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)

describe Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver do
  let(:provider) { described_class.new }
  let(:device) { instance_double(Puppet::Util::NetworkDevice::Cisco_ios::Device, 'device') }
  let(:transport) { instance_double(Puppet::Util::NetworkDevice::Transport::Cisco_ios, 'transport') }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:connection) { instance_double(Net::SSH::Telnet, 'connection') }

  before(:each) do
    allow(Puppet::Util::NetworkDevice).to receive(:current).and_return(device)
    allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:transport).and_return(transport)
    allow(transport).to receive(:connection).and_return(connection)
    allow(connection).to receive(:cmd).with("\n").and_return('cisco-c6503e#')
    allow(connection).to receive(:cmd).with('String' => 'enable', 'Match' => %r{^Password:.*$|#})
                                      .and_return('Password:')
    allow(transport).to receive(:enable_password).and_return('test_pass')
    allow(connection).to receive(:cmd).with('test_pass').and_return('cisco-c6503e#')
    allow(connection).to receive(:cmd).with('show running-config | section snmp-server host').and_return(device_output)
  end

  test_data['default']['tests'].each do |test|
    describe test['name'] do
      let(:device_output) { test['device_output'] }
      let(:expectations) do
        expectations = []
        test['expectations'].each do |x|
          expectations.push eval(x) # rubocop:disable Security/Eval
        end
        expectations
      end

      it':device_output parses to a puppet hash' do
        expect(provider.get(context)).to eq expectations
      end
    end
  end

  describe 'snmp_notification_receiver will set' do
    let(:device_output) { '' }

    before(:each) do
      allow(context).to receive(:creating).with(snmp_nr_name).and_yield
      allow(context).to receive(:updating).with(snmp_nr_name).and_yield
      allow(context).to receive(:deleting).with(snmp_nr_name).and_yield
      allow(connection).to receive(:cmd).with('String' => 'conf t', 'Match' => %r{^.*\(config\).*$}).and_return('cisco-c6503e(config-if)#')
    end

    context 'basic data' do
      let(:snmp_nr_name) { '1.1.1.1 public' }
      let(:changes) { { snmp_nr_name => { is: nil, should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present } } } }
      let(:device_commands) { 'snmp-server host 1.1.1.1 public' }

      it 'sends basic data' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'basic remove' do
      let(:snmp_nr_name) { '1.1.1.1 public' }
      let(:changes) do
        { snmp_nr_name => { is: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present },
                            should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :absent } } }
      end
      let(:device_commands) { 'no snmp-server host 1.1.1.1 public' }

      it 'sends no' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'port' do
      let(:snmp_nr_name) { '1.1.1.1 public 808' }
      let(:changes) { { snmp_nr_name => { is: nil, should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, port: 808 } } } }
      let(:device_commands) { 'snmp-server host 1.1.1.1 public udp-port 808' }

      it 'sends port data' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'update port' do
      let(:snmp_nr_name) { '1.1.1.1 public 999' }
      let(:changes) do
        { snmp_nr_name => { is: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, port: 999 },
                            should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, port: 991 } } }
      end
      let(:remove_command) { 'no snmp-server host 1.1.1.1 public udp-port 999' }
      let(:add_command) { 'snmp-server host 1.1.1.1 public udp-port 991' }

      it 'removes then adds' do
        expect(connection).to receive(:cmd).with(remove_command).and_return('cisco-c6503e(config)#')
        expect(connection).to receive(:cmd).with(add_command).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'vrf' do
      let(:snmp_nr_name) { '1.1.1.1 public purple' }
      let(:changes) { { snmp_nr_name => { is: nil, should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, vrf: 'purple' } } } }
      let(:device_commands) { 'snmp-server host 1.1.1.1 vrf purple public' }

      it 'sends vrf data' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'update vrf' do
      let(:snmp_nr_name) { '1.1.1.1 public purple' }
      let(:changes) do
        { snmp_nr_name => { is: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, vrf: 'purple' },
                            should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, vrf: 'phantom' } } }
      end
      let(:remove_command) { 'no snmp-server host 1.1.1.1 vrf purple public' }
      let(:add_command) { 'snmp-server host 1.1.1.1 vrf phantom public' }

      it 'removes then adds' do
        expect(connection).to receive(:cmd).with(remove_command).and_return('cisco-c6503e(config)#')
        expect(connection).to receive(:cmd).with(add_command).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'version 3 with auth security' do
      let(:snmp_nr_name) { '1.1.1.1 public' }
      let(:changes) { { snmp_nr_name => { is: nil, should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, version: '3', security: 'auth' } } } }
      let(:device_commands) { 'snmp-server host 1.1.1.1 version 3 auth public' }

      it 'sends auth' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'version 3 with noauth security' do
      let(:snmp_nr_name) { '1.1.1.1 public' }
      let(:changes) { { snmp_nr_name => { is: nil, should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, version: '3', security: 'noauth' } } } }
      let(:device_commands) { 'snmp-server host 1.1.1.1 version 3 noauth public' }

      it 'sends noauth' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'version 3 with priv security' do
      let(:snmp_nr_name) { '1.1.1.1 public' }
      let(:changes) { { snmp_nr_name => { is: nil, should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, version: '3', security: 'priv' } } } }
      let(:device_commands) { 'snmp-server host 1.1.1.1 version 3 priv public' }

      it 'sends priv' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'informs' do
      let(:snmp_nr_name) { '1.1.1.1 public' }
      let(:changes) { { snmp_nr_name => { is: nil, should: { name: snmp_nr_name, host: '1.1.1.1', username: 'public', ensure: :present, type: 'informs' } } } }
      let(:device_commands) { 'snmp-server host 1.1.1.1 informs public' }

      it 'sends informs' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end
  end
end

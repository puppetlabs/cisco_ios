require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'
# require 'puppet/resource_api/simple_provider'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::NtpServer; end
require 'puppet/provider/ntp_server/ntp_server'
require 'net/ssh/telnet'

test_data = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)

describe Puppet::Provider::NtpServer::NtpServer do
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
    allow(connection).to receive(:cmd).with('show running-config | section ntp server').and_return(device_output)
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

  describe 'ntp_server set' do
    let(:device_output) { '' }

    before(:each) do
      allow(context).to receive(:creating).with(ntp_server_name).and_yield
      allow(context).to receive(:updating).with(ntp_server_name).and_yield
      allow(context).to receive(:deleting).with(ntp_server_name).and_yield
      allow(connection).to receive(:cmd).with('String' => 'conf t', 'Match' => %r{^.*\(config\).*$}).and_return('cisco-c6503e(config-if)#')
    end

    context 'ntp server ip' do
      let(:ntp_server_name) { '12.34.56.78' }
      let(:changes) { { ntp_server_name => { is: nil, should: { name: ntp_server_name, provider: :rest, ensure: :present, prefer: false, loglevel: :notice } } } }
      let(:device_commands) { 'ntp server 12.34.56.78' }

      it 'sends server name' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end

    context 'ntp server ip key maxpoll minpoll prefer source_interface' do
      let(:ntp_server_name) { '12.34.56.78' }
      let(:changes) do
        { ntp_server_name => { is: { name: ntp_server_name,
                                     provider: :rest,
                                     ensure: :present,
                                     prefer: false,
                                     loglevel: :notice },
                               should: { name: ntp_server_name,
                                         provider: :rest,
                                         ensure: :present,
                                         key: 94,
                                         maxpoll: 14,
                                         minpoll: 4,
                                         prefer: :true,
                                         source_interface: 'Vlan1',
                                         loglevel: :notice } } }
      end
      let(:device_commands) { 'ntp server 12.34.56.78 key 94 minpoll 4 maxpoll 14 source Vlan1 prefer' }

      it 'sends server name key maxpoll minpoll prefer source_interface' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')
        provider.set(context, changes)
      end
    end

    context 'ntp server remove' do
      let(:ntp_server_name) { '12.34.56.78' }
      let(:changes) do
        { ntp_server_name => { is: { name: ntp_server_name,
                                     provider: :rest,
                                     ensure: :present,
                                     key: 94,
                                     maxpoll: 14,
                                     minpoll: 4,
                                     prefer: :true,
                                     source_interface: 'Vlan1',
                                     loglevel: :notice },
                               should: { name: ntp_server_name,
                                         provider: :rest,
                                         ensure: :absent,
                                         prefer: false,
                                         loglevel: :notice } } }
      end
      let(:device_commands) { 'no ntp server 12.34.56.78' }

      it 'sends no' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config)#')

        provider.set(context, changes)
      end
    end
  end
end

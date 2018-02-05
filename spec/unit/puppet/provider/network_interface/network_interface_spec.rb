require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::NetworkInterface; end
require 'puppet/provider/network_interface/network_interface'
require 'net/ssh/telnet'

describe Puppet::Provider::NetworkInterface::NetworkInterface do
  subject(:resource) { interface_test_resource(described_class, device_output) }

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
    allow(connection).to receive(:cmd).with('show running-config | section ^interface').and_return(device_output)
    allow(connection).to receive(:cmd).with('String' => 'conf t', 'Match' => %r{^.*\(config\).*$}).and_return('cisco-c6503e(config)#')
  end

  describe 'net_interface_parse single interface' do
    let(:device_output) { "interface Vlan4\n no ip address\n shutdown\n" }

    it('parses') do expect(provider.get(context)).to eq [{ name: 'Vlan4', enable: false, ensure: :present }] end
  end

  describe 'net_interface_parse multiple interface' do
    let(:device_output) { "interface Vlan4\n no ip address\n shutdown\ninterface Vlan5\n no ip address\n shutdown\ncisco-c6503e#" }

    it 'parses' do
      expect(provider.get(context)).to eq [{ name: 'Vlan4', enable: false, ensure: :present },
                                           { name: 'Vlan5', enable: false, ensure: :present }]
    end
  end

  describe 'net_interface_parse single interface description mtu' do
    let(:device_output) { "interface Vlan4\n description this is a test\n mtu 128\n no ip address\n shutdown\ncisco-c6503e#" }

    it 'parses' do
      expect(provider.get(context)).to eq [{ name: 'Vlan4',
                                             enable: false,
                                             ensure: :present,
                                             description: 'this is a test',
                                             mtu: 128 }]
    end
  end

  describe 'net_interface_parse single interface description speed duplex no shutdown' do
    let(:device_output) { "interface GigabitEthernet3/42\n description this is a test\n no ip address\n speed 100\n duplex half\ncisco-c6503e#" }

    it 'parses' do
      expect(provider.get(context)).to eq [{ name: 'GigabitEthernet3/42',
                                             enable: true,
                                             ensure: :present,
                                             description: 'this is a test',
                                             speed: '100m',
                                             duplex: 'half' }]
    end
  end

  describe 'net_interface_parse multiple interface description mtu does not parse ip mtu' do
    let(:device_output) do
      "interface Vlan4\n description this is a test\n mtu 126\n no ip address\n ip mtu 125\n shutdown\ninterface "\
           "Vlan5\n description this is also a test\n no ip address\n ip mtu 125\ncisco-c6503e#"
    end

    it 'parses' do
      expect(provider.get(context)).to eq [{ name: 'Vlan4',
                                             enable: false,
                                             ensure: :present,
                                             description: 'this is a test',
                                             mtu: 126 },
                                           { name: 'Vlan5',
                                             enable: true,
                                             ensure: :present,
                                             description: 'this is also a test' }]
    end
  end

  describe 'net_interface set' do
    let(:device_output) { '' }

    before(:each) do
      allow(context).to receive(:creating).with(interface_name).and_yield
      allow(context).to receive(:updating).with(interface_name).and_yield
      allow(context).to receive(:deleting).with(interface_name).and_yield

      allow(connection).to receive(:cmd).with('String' => "interface #{interface_name}", 'Match' => %r{^.*\(config-if\).*$}).and_return('cisco-c6503e(config-if)#')
    end

    context 'net_interface generates correct shutdown' do
      let(:interface_name) { 'Vlan42' }
      let(:changes) { { interface_name => { is: nil, should: { name: interface_name, provider: :rest, enable: false, loglevel: :notice, ensure: :present } } } }
      let(:device_commands) { " shutdown\n" }

      it 'sends shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface description mtu generates correct command' do
      let(:interface_name) { 'Vlan42' }
      let(:changes) do
        { interface_name =>
                            { is: nil,
                              should: {
                                name: interface_name,
                                provider: :rest,
                                enable: false,
                                description: 'This is a test interface',
                                mtu: 128,
                                loglevel: :notice,
                                ensure: :present,
                              } } }
      end
      let(:device_commands) { " description This is a test interface\n mtu 128\n shutdown\n" }

      it 'sends description mtu shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface description change generates correct command' do
      let(:interface_name) { 'Vlan42' }
      let(:changes) do
        { interface_name =>
                            { is:
                                  { name: interface_name,
                                    provider: :rest,
                                    enable: false,
                                    description: 'This is a test interface',
                                    mtu: 128,
                                    loglevel: :notice,
                                    ensure: :present },
                              should:
                                  { name: interface_name,
                                    provider: :rest,
                                    enable: false,
                                    description: 'This is still a test interface',
                                    mtu: 128,
                                    loglevel: :notice,
                                    ensure: :present } } }
      end
      let(:device_commands) { " description This is still a test interface\n mtu 128\n shutdown\n" }

      it 'sends description mtu shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface description speed duplex generates correct command' do
      let(:interface_name) { 'GigabitEthernet3/42' }
      let(:changes) do
        { interface_name =>
                            { is: nil,
                              should:
                                  { name: interface_name,
                                    provider: :rest,
                                    enable: true,
                                    description: 'This is a test interface',
                                    speed: :'10m',
                                    duplex: :full,
                                    loglevel: :notice,
                                    ensure: :present } } }
      end
      let(:device_commands) { " description This is a test interface\n speed 10\n duplex full\n no shutdown\n" }

      it 'sends description mtu shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface description speed 10 generates correct command' do
      let(:interface_name) { 'GigabitEthernet3/42' }
      let(:changes) do
        { interface_name =>
                            { is: nil,
                              should:
                                  { name: interface_name,
                                    provider: :rest,
                                    enable: true,
                                    description: 'This is a test interface',
                                    speed: :'10m',
                                    duplex: :full,
                                    loglevel: :notice,
                                    ensure: :present } } }
      end
      let(:device_commands) { " description This is a test interface\n speed 10\n duplex full\n no shutdown\n" }

      it 'sends description speed duplex no shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface description speed 100 generates correct command' do
      let(:interface_name) { 'GigabitEthernet3/42' }
      let(:changes) do
        { interface_name =>
                            { is: nil,
                              should:
                                  { name: interface_name,
                                    provider: :rest,
                                    enable: false,
                                    description: 'This is a test interface',
                                    speed: :'100m',
                                    duplex: :half,
                                    loglevel: :notice,
                                    ensure: :present } } }
      end
      let(:device_commands) { " description This is a test interface\n speed 100\n duplex half\n shutdown\n" }

      it 'sends description speed duplex shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface description speed 1g generates correct command' do
      let(:interface_name) { 'GigabitEthernet3/42' }
      let(:changes) do
        { interface_name =>
                            { is: nil,
                              should: {
                                name: interface_name,
                                provider: :rest,
                                enable: false,
                                description: 'This is a test interface',
                                speed: :'1g',
                                duplex: :full,
                                loglevel: :notice,
                                ensure: :present,
                              } } }
      end
      let(:device_commands) { " description This is a test interface\n speed 1000\n duplex full\n shutdown\n" }

      it 'sends description speed duplex shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface description speed other does not translate speed generates correct command' do
      let(:interface_name) { 'GigabitEthernet3/42' }
      let(:changes) do
        { interface_name =>
                            { is: nil,
                              should:
                                  { name: interface_name,
                                    provider: :rest,
                                    enable: true,
                                    description: 'This is a test interface',
                                    speed: :'16g',
                                    duplex: :full,
                                    loglevel: :notice,
                                    ensure: :present } } }
      end
      let(:device_commands) { " description This is a test interface\n speed 16g\n duplex full\n no shutdown\n" }

      it 'sends description speed duplex no shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end

    context 'net_interface not enabled generates correct command' do
      let(:interface_name) { 'Vlan42' }
      let(:changes) do
        { interface_name =>
                            { is:
                                  { name: interface_name,
                                    provider: :rest,
                                    enable: false,
                                    description: 'This is a test interface',
                                    mtu: 128,
                                    loglevel: :notice,
                                    ensure: :present },
                              should: {
                                name: interface_name,
                                provider: :rest,
                                ensure: :absent,
                                description: 'This is a test interface',
                                loglevel: :notice,
                              } } }
      end
      let(:device_commands) { "default interface Vlan42\nno interface Vlan42" }

      it 'sends description speed duplex no shutdown' do
        expect(connection).to receive(:cmd).with(device_commands).and_return('cisco-c6503e(config-if)#')

        provider.set(context, changes)
      end
    end
  end
end

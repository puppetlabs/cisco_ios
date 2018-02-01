require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'

include RSpec::Mocks::ExampleMethods

# def interface_test_resource(net_interface_class, device_output)
#   raw_instances = InterfaceParseUtils.interface_parse_out(device_output)
#   new_instances = []
#   raw_instances.each do |raw_instance|
#     new_instance = {}
#     raw_instance.each do |key, value|
#       unless value.nil?
#         new_instance[key] = value
#       end
#     end
#     new_instances << net_interface_class.new(new_instance)
#   end
#   new_instances
# end

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

  describe 'net_interface_config_command' do
    let(:device_output) { '' }

    # TODO: - SET TESTS TO NOT WORK
    # it 'net_interface generates correct command' do
    #   expect(provider.set(context, [{'Vlan42'=>{ is: nil, should: { name: 'Vlan42', provider: :rest, enable: false, loglevel: :notice } }}])).to eq " shutdown\n"
    # end
    #
    #
    #  TODO - THESE ARE THE OLD WAY...
    #   it 'net_interface_config_command description mtu generates correct command' do
    #     property_hash = { name: 'Vlan42', provider: :rest, enable: false, description: 'This is a test interface', mtu: 128, loglevel: :notice }
    #     expect(InterfaceParseUtils.interface_config_command(property_hash)).to eql " description This is a test interface\n mtu 128\n shutdown\n"
    #   end
    #   it 'net_interface_config_command description speed duplex generates correct command' do
    #     # Speed 10m is translated to 10
    #     property_hash = { name: 'GigabitEthernet3/42', provider: :rest, enable: true, description: 'This is a test interface', speed: :'10m', duplex: :full, loglevel: :notice }
    #     expect(InterfaceParseUtils.interface_config_command(property_hash)).to eql " description This is a test interface\n speed 10\n duplex full\n no shutdown\n"
    #   end
    #   it 'net_interface_config_command description speed correctly translated' do
    #     # Speed 100m is translated to 100
    #     property_hash = { name: 'GigabitEthernet3/42', provider: :rest, enable: true, speed: :'100m', loglevel: :notice }
    #     expect(InterfaceParseUtils.interface_config_command(property_hash)).to eql " speed 100\n no shutdown\n"
    #     # Speed 1g is translated to 1000
    #     property_hash = { name: 'GigabitEthernet3/42', provider: :rest, speed: :'1g', loglevel: :notice }
    #     expect(InterfaceParseUtils.interface_config_command(property_hash)).to eql " speed 1000\n shutdown\n"
    #     # Other speeds not translated
    #     property_hash = { name: 'GigabitEthernet3/42', provider: :rest, enable: false, speed: :'10g', loglevel: :notice }
    #     expect(InterfaceParseUtils.interface_config_command(property_hash)).to eql " speed 10g\n shutdown\n"
    #   end
    #   it 'net_interface_config_command not enabled generates correct command' do
    #     property_hash = { name: 'Vlan42', provider: :rest, ensure: :absent, description: 'This is a test interface', loglevel: :notice }
    #     expect(InterfaceParseUtils.interface_config_command(property_hash)).to eql "default interface Vlan42\nno interface Vlan42"
    #   end
  end
end

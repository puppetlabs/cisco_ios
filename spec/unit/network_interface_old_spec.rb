require 'spec_helper'

include RSpec::Mocks::ExampleMethods

net_interface = Puppet::Type.type(:network_interface_old)

def interface_test_resource(net_interface_class, output)
  raw_instances = InterfaceOldParseUtils.interface_old_parse_out(output)
  new_instances = []
  raw_instances.each do |raw_instance|
    new_instance = {}
    raw_instance.each do |key, value|
      unless value.nil?
        new_instance[key] = value
      end
    end
    new_instances << net_interface_class.new(new_instance)
  end
  new_instances
end

describe net_interface do
  describe 'net_interface_old_parse single interface' do
    let(:provider) { instance_double('rest') }
    let(:net_interface_class) { net_interface }
    let(:resource) { interface_test_resource(net_interface_class, "interface Vlan4\n no ip address\n shutdown") }

    it 'parses' do
      expect(resource[0][:name]).to(eq('Vlan4'))
    end
  end

  describe 'net_interface_old_parse multiple interface' do
    let(:provider) { instance_double('rest') }
    let(:net_interface_class) { net_interface }
    let(:resource) { interface_test_resource(net_interface_class, "interface Vlan4\n no ip address\n shutdown\ninterface Vlan5\n no ip address\n shutdown\ncisco-c6503e#") }

    it 'parses' do
      expect(resource[0][:name]).to(eq('Vlan4'))
      expect(resource[1][:name]).to(eq('Vlan5'))
    end
  end

  describe 'net_interface_old_parse single interface description mtu' do
    let(:provider) { instance_double('rest') }
    let(:net_interface_class) { net_interface }
    let(:resource) { interface_test_resource(net_interface_class, "interface Vlan4\n description this is a test\n mtu 128\n no ip address\n shutdown\ncisco-c6503e#") }

    it 'parses' do
      expect(resource[0][:name]).to(eq('Vlan4'))
      expect(resource[0][:description]).to(eq('this is a test'))
      expect(resource[0][:mtu]).to(eq(128))
    end
  end

  describe 'net_interface_old_parse single interface description speed duplex' do
    let(:provider) { instance_double('rest') }
    let(:net_interface_class) { net_interface }
    let(:resource) { interface_test_resource(net_interface_class, "interface GigabitEthernet3/42\n description this is a test\n no ip address\n shutdown\n speed 100\n duplex half\ncisco-c6503e#") }

    it 'parses' do
      expect(resource[0][:name]).to(eq('GigabitEthernet3/42'))
      expect(resource[0][:description]).to(eq('this is a test'))
      expect(resource[0][:speed]).to(eq(:'100m'))
      expect(resource[0][:duplex]).to(eq(:half))
    end
  end

  describe 'net_interface_old_parse single interface description mtu does not parse ip mtu' do
    let(:provider) { instance_double('rest') }
    let(:net_interface_class) { net_interface }
    let(:resource) do
      interface_test_resource(
        net_interface_class,
        "interface Vlan4\n description this is a test\n mtu 126\n no ip address\n ip mtu 125\n shutdown\ninterface "\
               "Vlan5\n description this is also a test\n no ip address\n ip mtu 125\n shutdown\ncisco-c6503e#",
      )
    end

    it 'parses' do
      expect(resource[0][:name]).to(eq('Vlan4'))
      expect(resource[0][:mtu]).to(eq(126))
      expect(resource[1][:name]).to(eq('Vlan5'))
      expect(resource[1][:mtu]).to(eq(nil))
    end
  end

  describe 'net_interface_old_parse multiple interface description' do
    let(:provider) { instance_double('rest') }
    let(:net_interface_class) { net_interface }
    let(:resource) { interface_test_resource(net_interface_class, "interface Vlan4\n description this is a test\n no ip address\n shutdown\ninterface Vlan5\n description this is also a test\n no ip address\n shutdown\ncisco-c6503e#") } # rubocop:disable LineLength

    it 'parses' do
      expect(resource[0][:name]).to(eq('Vlan4'))
      expect(resource[0][:description]).to(eq('this is a test'))
      expect(resource[1][:name]).to(eq('Vlan5'))
      expect(resource[1][:description]).to(eq('this is also a test'))
    end
  end

  describe 'net_interface_old_config_command' do
    it 'net_interface generates correct command' do
      property_hash = { name: 'Vlan42', provider: :rest, enable: :true, loglevel: :notice }
      expect(InterfaceOldParseUtils.interface_old_config_command(property_hash)).to eql ''
    end

    it 'net_interface_old_config_command description mtu generates correct command' do
      property_hash = { name: 'Vlan42', provider: :rest, enable: :true, description: 'This is a test interface', mtu: 128, loglevel: :notice }
      expect(InterfaceOldParseUtils.interface_old_config_command(property_hash)).to eql " description This is a test interface\n mtu 128\n"
    end
    it 'net_interface_old_config_command description speed duplex generates correct command' do
      # Speed 10m is translated to 10
      property_hash = { name: 'GigabitEthernet3/42', provider: :rest, enable: :true, description: 'This is a test interface', speed: :'10m', duplex: :full, loglevel: :notice }
      expect(InterfaceOldParseUtils.interface_old_config_command(property_hash)).to eql " description This is a test interface\n speed 10\n duplex full\n"
    end
    it 'net_interface_old_config_command description speed correctly translated' do
      # Speed 100m is translated to 100
      property_hash = { name: 'GigabitEthernet3/42', provider: :rest, enable: :true, speed: :'100m', loglevel: :notice }
      expect(InterfaceOldParseUtils.interface_old_config_command(property_hash)).to eql " speed 100\n"
      # Speed 1g is translated to 1000
      property_hash = { name: 'GigabitEthernet3/42', provider: :rest, enable: :true, speed: :'1g', loglevel: :notice }
      expect(InterfaceOldParseUtils.interface_old_config_command(property_hash)).to eql " speed 1000\n"
      # Other speeds not translated
      property_hash = { name: 'GigabitEthernet3/42', provider: :rest, enable: :true, speed: :'10g', loglevel: :notice }
      expect(InterfaceOldParseUtils.interface_old_config_command(property_hash)).to eql " speed 10g\n"
    end
    it 'net_interface_old_config_command not enabled generates correct command' do
      property_hash = { name: 'Vlan42', provider: :rest, enable: :false, description: 'This is a test interface', loglevel: :notice }
      expect(InterfaceOldParseUtils.interface_old_config_command(property_hash)).to eql "default interface Vlan42\nno interface Vlan42"
    end
  end
end

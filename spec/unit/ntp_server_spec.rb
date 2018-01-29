require 'spec_helper'

include RSpec::Mocks::ExampleMethods

ntp_server = Puppet::Type.type(:ntp_server)

def ntp_server_test_resource(ntp_server_class, output)
  raw_instances = NTPServerParseUtils.parse(output)
  new_instances = []
  raw_instances.each do |raw_instance|
    new_instance = {}
    raw_instance.each do |key, value|
      unless value.nil?
        new_instance[key] = value
      end
    end
    new_instances << ntp_server_class.new(new_instance)
  end
  new_instances
end

describe ntp_server do
  describe 'ntp_server_parse single ntp server ip' do
    let(:provider) { instance_double('rest') }
    let(:ntp_server_class) { ntp_server }
    let(:resource) { ntp_server_test_resource(ntp_server_class, "ntp server 1.2.3.4\n") }

    it 'parses' do
      expect(resource[0][:name]).to(eq('1.2.3.4'))
      expect(resource[0][:prefer]).to(eq(false))
    end
  end

  describe 'ntp_server_parse multiple ntp server ip' do
    let(:provider) { instance_double('rest') }
    let(:ntp_server_class) { ntp_server }
    let(:resource) { ntp_server_test_resource(ntp_server_class, "ntp server 1.2.3.4\nntp server 5.6.7.8\n") }

    it 'parses' do
      expect(resource[0][:name]).to(eq('1.2.3.4'))
      expect(resource[0][:prefer]).to(eq(false))
      expect(resource[1][:name]).to(eq('5.6.7.8'))
      expect(resource[1][:prefer]).to(eq(false))
    end
  end

  describe 'ntp_server_parse single ntp server ip key maxpoll minpoll prefer source' do
    let(:provider) { instance_double('rest') }
    let(:ntp_server_class) { ntp_server }
    let(:resource) { ntp_server_test_resource(ntp_server_class, "ntp server 1.2.3.4 key 94 maxpoll 14 minpoll 4 prefer source Vlan1\n") }

    it 'parses' do
      expect(resource[0][:name]).to(eq('1.2.3.4'))
      expect(resource[0][:key]).to(eq(94))
      expect(resource[0][:maxpoll]).to(eq(14))
      expect(resource[0][:minpoll]).to(eq(4))
      expect(resource[0][:prefer]).to(eq(true))
      expect(resource[0][:source_interface]).to(eq('Vlan1'))
    end
  end

  describe 'ntp_server_parse multiple ntp server ip key maxpoll minpoll prefer source' do
    let(:provider) { instance_double('rest') }
    let(:ntp_server_class) { ntp_server }
    let(:resource) { ntp_server_test_resource(ntp_server_class, "ntp server 1.2.3.4 key 94 maxpoll 14 minpoll 4 prefer source Vlan1\nntp server 9.8.7.6 key 42 maxpoll 16 minpoll 6 prefer source Vlan0\n") } # rubocop:disable LineLength

    it 'parses' do
      expect(resource[0][:name]).to(eq('1.2.3.4'))
      expect(resource[0][:key]).to(eq(94))
      expect(resource[0][:maxpoll]).to(eq(14))
      expect(resource[0][:minpoll]).to(eq(4))
      expect(resource[0][:prefer]).to(eq(true))
      expect(resource[0][:source_interface]).to(eq('Vlan1'))
      expect(resource[1][:name]).to(eq('9.8.7.6'))
      expect(resource[1][:key]).to(eq(42))
      expect(resource[1][:maxpoll]).to(eq(16))
      expect(resource[1][:minpoll]).to(eq(6))
      expect(resource[1][:prefer]).to(eq(true))
      expect(resource[1][:source_interface]).to(eq('Vlan0'))
    end
  end

  describe 'ntp_server_config_command' do
    it 'ntp server ip generates correct command' do
      property_hash = { name: '12.34.56.78', provider: :rest, ensure: :present, prefer: false, loglevel: :notice }
      expect(NTPServerParseUtils.config_command(property_hash)).to eql 'ntp server 12.34.56.78'
    end
    it 'ntp server ip key maxpoll minpoll prefer source_interface generates correct command' do
      property_hash = { name: '87.65.43.21',
                        provider: :rest,
                        ensure: :present,
                        key: 94,
                        maxpoll: 14,
                        minpoll: 4,
                        prefer: :true,
                        source_interface: 'Vlan1',
                        loglevel: :notice }
      expect(NTPServerParseUtils.config_command(property_hash)).to eql 'ntp server 87.65.43.21 key 94 minpoll 4 maxpoll 14 source Vlan1 prefer'
    end
  end
end

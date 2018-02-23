require 'spec_helper'

module Puppet::Provider::SnmpUser; end
require 'puppet/provider/snmp_user/ios'

RSpec.describe Puppet::Provider::SnmpUser::SnmpUser do
  def self.load_test_data
    Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  load_test_data['default']['tests'].each do |test_name, test|
    context test_name do
      it 'parses the output to the data' do
        if test['version'] == 'v1'
          expect(described_class.parse(test['device_output'])).to eq test['previous_set'] || test['get_expectations']
        else
          expect(described_class.parse_v3(test['device_output'])).to eq test['previous_set'] || test['set_expectations']
        end
      end

      test['commands'].zip(test['get_expectations']).each do |command, expectation|
        it "generates the command for #{expectation.inspect}" do
          expect(described_class.config_command(expectation)).to eq command
        end
      end
    end
  end

  describe '#get' do
    before(:each) do
      allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_enable_mode).with('show running-config | section snmp-server user').and_return(output)
      allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_enable_mode).with('show snmp user').and_return(output_v3)
    end

    context 'with no output' do
      let(:output) { nil }
      let(:output_v3) { nil }

      it { expect(provider.get(context)).to eq [] }
    end

    context 'with some v1 users' do
      let(:output) { 'snmp-server user alpha public v1\n' }
      let(:output_v3) { nil }

      it {
        expect(provider.get(context)).to eq [{ name: 'alpha v1', ensure: :present, roles: 'public', version: 'v1' }]
      }
    end

    context 'with some v3 users' do
      let(:output) { nil }
      let(:output_v3) do
        <<-EOS
User name: bravo
Engine ID: 800000090300001EBE6E712C
storage-type: nonvolatile	 active
Authentication Protocol: MD5
Privacy Protocol: AES128
Group-name: private

User name: charlie
Engine ID: 800000090300001EBE6E712C
storage-type: nonvolatile	 active
Authentication Protocol: MD5
Privacy Protocol: AES192
Group-name: public
        EOS
      end

      it {
        expect(provider.get(context)).to eq [
          { name: 'bravo v3', ensure: :present, roles: 'private', version: 'v3', auth: 'md5', engine_id: '800000090300001EBE6E712C', privacy: 'AES128' },
          { name: 'charlie v3', ensure: :present, roles: 'public', version: 'v3', auth: 'md5', engine_id: '800000090300001EBE6E712C', privacy: 'AES192' },
        ]
      }
    end
  end

  describe '#create' do
    it 'runs run_command_conf_t_mode for a v1 user' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('snmp-server user delta private v1')
      provider.create(context, 'delta v1', name: 'delta v1', ensure: :present, version: 'v1', roles: 'private')
    end
    it 'runs run_command_conf_t_mode for a v3 user' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('snmp-server user echo private v3 auth md5 auth_pass priv aes 128 priv_pass')
      should = { name: 'echo v3', ensure: :present, version: 'v3', roles: 'private', auth: 'md5', password: 'auth_pass', privacy: 'aes 128', private_key: 'priv_pass' }
      provider.create(context, 'echo v3', should)
    end
  end

  describe '#update' do
    it 'runs run_command_conf_t_mode for a v1 user' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('no snmp-server user foxtrot private v1')
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('snmp-server user foxtrot private v2')

      is = { name: 'foxtrot v1', ensure: :present, roles: 'private', version: 'v1' }
      should = { name: 'foxtrot v2', ensure: :present, roles: 'private', version: 'v2' }
      provider.update(context, 'foxtrot v1', is, should)
    end
    it 'runs run_command_conf_t_mode for a v3 user' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('no snmp-server user golf private v3 auth md5 auth_pass priv aes 128 priv_pass')
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('snmp-server user golf public v3 auth md5 auth_pass priv aes 128 priv_pass')

      is = { name: 'golf v3', ensure: :present, roles: 'private', version: 'v3', auth: 'md5', password: 'auth_pass', privacy: 'aes 128', private_key: 'priv_pass' }
      should = { name: 'golf v3', ensure: :present, roles: 'public', version: 'v3', auth: 'md5', password: 'auth_pass', privacy: 'aes 128', private_key: 'priv_pass' }
      provider.update(context, 'golf v3', is, should)
    end
  end
  describe '#delete' do
    it 'runs run_command_conf_t_mode for v1 user' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('no snmp-server user hotel private v1')
      provider.delete(context, 'hotel v1', name: 'hotel v1', ensure: :absent, version: 'v1', roles: 'private')
    end
    it 'runs run_command_conf_t_mode for a v3 user' do
      expect(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:run_command_conf_t_mode).with('no snmp-server user indigo private v3 auth md5 auth_pass priv aes 128 priv_pass')
      should = { name: 'indigo v3', ensure: :absent, version: 'v3', roles: 'private', auth: 'md5', password: 'auth_pass', privacy: 'aes 128', private_key: 'priv_pass' }
      provider.create(context, 'indigo v3', should)
    end
  end
end

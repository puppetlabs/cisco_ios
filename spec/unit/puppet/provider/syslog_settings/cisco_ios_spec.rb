require 'spec_helper'

module Puppet::Provider::SyslogSettings; end
require 'puppet/provider/syslog_settings/cisco_ios'

RSpec.describe Puppet::Provider::SyslogSettings::CiscoIos do
  let(:utility) { described_class }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_is_should(test['is'], test['should'])).to eq test['cli']
      end
    end
  end

  describe 'buffered_split' do
    it 'retrieve buffered_size' do
      input = Hash[buffered_size: '5000', buffered_severity_level: '5000']
      output = Hash[buffered_size: '5000']
      expect(utility.buffered_split(input)).to eq output
    end
    it 'retrieve buffered_severity_level' do
      input = Hash[buffered_size: 'warnings', buffered_severity_level: 'warnings']
      output = Hash[buffered_severity_level: 4]
      expect(utility.buffered_split(input)).to eq output
    end
    it 'retrieve both' do
      input = Hash[buffered_size: '5000 warnings', buffered_severity_level: '5000 warnings']
      output = Hash[buffered_size: '5000', buffered_severity_level: 4]
      expect(utility.buffered_split(input)).to eq output
    end
  end

  describe 'buffer_command' do
    it 'buffered_size set' do
      input = Hash[buffered_size: '5000']
      output = Hash[buffered_size: '5000']
      expect(utility.buffer_command(input)).to eq output
    end
    it 'buffered_severity_level set' do
      input = Hash[buffered_severity_level: 4]
      output = Hash[buffered_severity_level: 4]
      expect(utility.buffer_command(input)).to eq output
    end
    it 'buffered_size and buffered_severity_level set' do
      input = Hash[buffered_size: '5000', buffered_severity_level: 4]
      output = Hash[buffered_size: '5000 4']
      expect(utility.buffer_command(input)).to eq output
    end
    it 'buffered_size set and buffered_severity_level unset' do
      input = Hash[buffered_size: '5000', buffered_severity_level: 'unset']
      output = Hash[buffered_size: '5000']
      expect(utility.buffer_command(input)).to eq output
    end
    it 'buffered_size unset and buffered_severity_level set' do
      input = Hash[buffered_size: 'unset', buffered_severity_level: 4]
      output = Hash[buffered_severity_level: 4]
      expect(utility.buffer_command(input)).to eq output
    end
    it 'buffered_size and buffered_severity_level unset' do
      input = Hash[buffered_size: 'unset', buffered_severity_level: 'unset']
      output = Hash[buffered_size: 'unset']
      expect(utility.buffer_command(input)).to eq output
    end
  end

  context 'canonicalize is called' do
    let(:resources) { [{ enable: true, monitor: 'unset', console: 'unset', source_interface: ['Loopback24'], buffered_size: 5000, buffered_severity_level: 4 }] }
    let(:provider) { described_class.new }

    it 'returns the same resource' do
      expect(provider.canonicalize(anything, resources)[0][:enable].object_id).to eq(resources[0][:enable].object_id)
      expect(provider.canonicalize(anything, resources)[0][:monitor].object_id).to eq(resources[0][:monitor].object_id)
      expect(provider.canonicalize(anything, resources)[0][:console].object_id).to eq(resources[0][:console].object_id)
      expect(provider.canonicalize(anything, resources)[0][:source_interface].object_id).to eq(resources[0][:source_interface].object_id)
      expect(provider.canonicalize(anything, resources)[0][:buffered_size].object_id).to eq(resources[0][:buffered_size].object_id)
      expect(provider.canonicalize(anything, resources)[0][:buffered_severity_level].object_id).to eq(resources[0][:buffered_severity_level].object_id)
    end

    it 'returns the correct value' do
      expect(provider.canonicalize(anything, resources)[0][:enable]).to eq(true)
      expect(provider.canonicalize(anything, resources)[0][:monitor]).to eq(6)
      expect(provider.canonicalize(anything, resources)[0][:console]).to eq(6)
      expect(provider.canonicalize(anything, resources)[0][:source_interface]).to eq(['Loopback24'])
      expect(provider.canonicalize(anything, resources)[0][:buffered_size]).to eq(5000)
      expect(provider.canonicalize(anything, resources)[0][:buffered_severity_level]).to eq(4)
    end
  end
end

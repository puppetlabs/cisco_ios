require 'spec_helper'

module Puppet::Provider::IosRadiusServerGroup; end
require 'puppet/provider/ios_radius_server_group/cisco_ios'

RSpec.describe Puppet::Provider::IosRadiusServerGroup::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  context 'Radius update tests:' do
    load_test_data['default']['update_radius_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_instance(test['instance'])).to eq test['cli']
      end
    end
  end

  context 'Server update tests:' do
    load_test_data['default']['update_server_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_is_should(test['is'], test['should'])).to eq test['cli']
      end
    end
  end

  context 'canonicalize is called' do
    let(:resources) do
      [{ name: 'foo', ensure: 'present', servers: ['6.6.6.6', '4.4.4.4'], private_servers: ['6.6.6.6', '4.4.4.4'] }]
    end
    let(:provider) { described_class.new }

    it 'returns the same resource' do
      expect(provider.canonicalize(anything, resources)[0][:name].object_id).to eq(resources[0][:name].object_id)
      expect(provider.canonicalize(anything, resources)[0][:ensure].object_id).to eq(resources[0][:ensure].object_id)
      expect(provider.canonicalize(anything, resources)[0][:servers].object_id).to eq(resources[0][:servers].object_id)
      expect(provider.canonicalize(anything, resources)[0][:private_servers].object_id).to eq(resources[0][:private_servers].object_id)
    end

    it 'returns the correct value' do
      expect(provider.canonicalize(anything, resources)[0][:name]).to eq('foo')
      expect(provider.canonicalize(anything, resources)[0][:ensure]).to eq('present')
      expect(provider.canonicalize(anything, resources)[0][:servers]).to eq(['4.4.4.4', '6.6.6.6'])
      expect(provider.canonicalize(anything, resources)[0][:private_servers]).to eq(['4.4.4.4', '6.6.6.6'])
    end
  end
end

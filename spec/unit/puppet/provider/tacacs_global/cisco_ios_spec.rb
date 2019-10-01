require 'spec_helper'

module Puppet::Provider::TacacsGlobal; end
require 'puppet/provider/tacacs_global/cisco_ios'

RSpec.describe Puppet::Provider::TacacsGlobal::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  context 'Error tests:' do
    load_test_data['default']['error_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'], test['family'])
        if test['commands'].size.zero?
          expect { described_class.commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          expect { described_class.commands_from_instance(test['instance']) }.to raise_error(%r{cisco_ios does not support the use of the vrf attribute with tacacs_global})
        end
      end
    end
  end

  context 'canonicalize is called' do
    let(:resources) { [{ key: 'XYZ', key_format: 1, source_interface: ['Vlan600', 'Vlan2'] }] }
    let(:provider) { described_class.new }

    it 'returns the same resource' do
      expect(provider.canonicalize(anything, resources)[0][:key].object_id).to eq(resources[0][:key].object_id)
      expect(provider.canonicalize(anything, resources)[0][:key_format].object_id).to eq(resources[0][:key_format].object_id)
      expect(provider.canonicalize(anything, resources)[0][:source_interface].object_id).to eq(resources[0][:source_interface].object_id)
    end

    it 'returns the correct value' do
      expect(provider.canonicalize(anything, resources)[0][:key]).to eq('XYZ')
      expect(provider.canonicalize(anything, resources)[0][:key_format]).to eq(1)
      expect(provider.canonicalize(anything, resources)[0][:source_interface]).to eq(['Vlan2', 'Vlan600'])
    end
  end
end

require 'spec_helper'

module Puppet::Provider::IosNetworkTrunk; end
require 'puppet/provider/ios_network_trunk/cisco_ios'

RSpec.describe Puppet::Provider::IosNetworkTrunk::CiscoIos do
  let(:provider) { described_class.new }
  let(:context) { instance_double(Puppet::ResourceApi::PuppetContext, 'context') }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        type_name = described_class.instance_method(:get).source_location.first.match(%r{provider\/(.*)\/})[1]
        new_type = Puppet::Type.type(type_name)
        dummy_context = Puppet::ResourceApi::PuppetContext
        dummy_context = dummy_context.new(new_type.type_definition.definition)
        return_non_enforced = [described_class.instance_from_cli(test['cli'])]
        return_enforced = PuppetX::CiscoIOS::Utility.enforce_simple_types(dummy_context, return_non_enforced)
        expect(return_enforced).to eq test['expectations']
      end
    end
  end
  it_behaves_like 'commands created from instance'

  describe '#create_cli_range_from_array' do
    context 'multiple ranges' do
      it { expect(described_class.create_cli_range_from_array([1, 100, 101, 102, 12, 2, 3, 4, 5])).to eq('1-5,12,100-102') }
    end
    context 'single range' do
      it { expect(described_class.create_cli_range_from_array([1, 100, 12, 2, 3, 4, 5])).to eq('1-5,12,100') }
    end
    context 'no ranges' do
      it { expect(described_class.create_cli_range_from_array([1, 100, 12])).to eq('1,12,100') }
    end
    context 'singular value' do
      it { expect(described_class.create_cli_range_from_array([1])).to eq('1') }
    end
    context 'no values' do
      it { expect(described_class.create_cli_range_from_array([])).to eq('') }
    end
  end

  describe '#create_array_from_string' do
    context 'multiple ranges' do
      it { expect(described_class.create_array_from_string('1-5,12,100-102')).to eq([1, 100, 101, 102, 12, 2, 3, 4, 5]) }
    end
    context 'single range' do
      it { expect(described_class.create_array_from_string('1-5,12,100')).to eq([1, 100, 12, 2, 3, 4, 5]) }
    end
    context 'no ranges' do
      it { expect(described_class.create_array_from_string('1,12,100')).to eq([1, 100, 12]) }
    end
    context 'singular value' do
      it { expect(described_class.create_array_from_string('1')).to eq([1]) }
    end
    context 'no values' do
      it { expect(described_class.create_array_from_string('')).to eq([]) }
    end
  end

  canonicalize_data = [
    {
      desc: '`resources` contains no `allowed_vlans`',
      resources: [{
        name: 'default',
      }],
      results:   [{
        name: 'default',
      }],
    },
    {
      desc: '`resources` contains string of `allowed_vlans`',
      resources: [{
        name: 'default',
        allowed_vlans: '1-10,20-2000',
      }],
      results:   [{
        name: 'default',
        allowed_vlans: '1-10,20-2000',
      }],
    },
    {
      desc: '`resources` contains array of add `allowed_vlans`',
      resources: [{
        name: 'default',
        allowed_vlans: ['add', '10-12'],
      }],
      get_call_results: [{
        name: 'default',
        allowed_vlans: '1-9,300-2000',
      }],
      results:   [{
        name: 'default',
        allowed_vlans: '1-12,300-2000',
      }],
    },
    {
      desc: '`resources` contains array of remove `allowed_vlans`',
      resources: [{
        name: 'default',
        allowed_vlans: ['remove', '2-6'],
      }],
      get_call_results: [{
        name: 'default',
        allowed_vlans: '1-9,300-2000',
      }],
      results:   [{
        name: 'default',
        allowed_vlans: '1,7-9,300-2000',
      }],
    },
    {
      desc: '`resources` contains array of except `allowed_vlans`',
      resources: [{
        name: 'default',
        allowed_vlans: ['except', '2-6'],
      }],
      results:   [{
        name: 'default',
        allowed_vlans: '1,7-4094',
      }],
    },
    {
      desc: '`resources` contains array of add `allowed_vlans` while current is ALL',
      resources: [{
        name: 'default',
        allowed_vlans: ['add', '2-6'],
      }],
      get_call_results: [{
        name: 'default',
        allowed_vlans: 'ALL',
      }],
      results:   [{
        name: 'default',
        allowed_vlans: 'ALL',
      }],
    },
    {
      desc: '`resources` contains array of add `allowed_vlans` while current is NONE',
      resources: [{
        name: 'default',
        allowed_vlans: ['add', '2-6'],
      }],
      get_call_results: [{
        name: 'default',
        allowed_vlans: 'NONE',
      }],
      results:   [{
        name: 'default',
        allowed_vlans: '2-6',
      }],
    },
    {
      desc: '`resources` contains array of remove `allowed_vlans` while current is ALL',
      resources: [{
        name: 'default',
        allowed_vlans: ['remove', '2-6'],
      }],
      get_call_results: [{
        name: 'default',
        allowed_vlans: 'ALL',
      }],
      results:   [{
        name: 'default',
        allowed_vlans: '1,7-4094',
      }],
    },
    {
      desc: '`resources` contains array of remove `allowed_vlans` while current is NONE',
      resources: [{
        name: 'default',
        allowed_vlans: ['remove', '2-6'],
      }],
      get_call_results: [{
        name: 'default',
        allowed_vlans: 'NONE',
      }],
      results:   [{
        name: 'default',
        allowed_vlans: 'NONE',
      }],
    },
  ]

  describe '#canonicalize' do
    context 'when cache is not set' do
      before(:each) do
        provider.instance_variable_set(:@cache, nil)
      end

      it 'calls get' do
        expect(provider).to receive(:get)
        provider.canonicalize(context, {})
      end
    end

    context 'when cache has been set' do
      canonicalize_data.each do |test|
        context test[:desc].to_s do
          before(:each) do
            provider.instance_variable_set(:@cache, test[:get_call_results] || [{ name: 'default' }])
          end

          it 'returns canonicalized value' do
            expect(provider).not_to receive(:get)
            expect(provider.canonicalize(context, test[:resources])).to eq(test[:results])
          end
        end
      end
    end
  end
end

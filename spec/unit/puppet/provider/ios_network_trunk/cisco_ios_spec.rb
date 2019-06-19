require 'spec_helper'

module Puppet::Provider::IosNetworkTrunk; end
require 'puppet/provider/ios_network_trunk/cisco_ios'

RSpec.describe Puppet::Provider::IosNetworkTrunk::CiscoIos do
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

  it_behaves_like 'a noop canonicalizer'
end

require 'spec_helper'

module Puppet::Provider::Vrf; end
require 'puppet/provider/vrf/cisco_ios'

RSpec.describe Puppet::Provider::Vrf::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'

  context 'Create/Delete tests:' do
    load_test_data['default']['create_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'], test['family'])
        if test['commands'].size.zero?
          expect { described_class.create_commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          result = []
          described_class.create_commands_from_instance(test['instance']).each { |x| result << x.squeeze(' ') }
          expect(result).to eq test['commands']
        end
      end
    end
  end

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'], test['family'])
        if test['commands'].size.zero?
          expect { described_class.update_commands_from_is_should(test['is'], test['should']) }.to raise_error(%r{.*})
        else
          result = []
          described_class.update_commands_from_is_should(test['is'], test['should']).each { |x| result << x.squeeze(' ') }
          expect(result).to eq test['commands']
        end
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end

require 'spec_helper'

module Puppet::Provider::RadiusServer; end
require 'puppet/provider/radius_server/ios'

RSpec.describe Puppet::Provider::RadiusServer::RadiusServer do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
      end
    end
  end

  context 'Edit tests:' do
    load_test_data['default']['edit_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.commands_from_instance(test['expectations'].first)).to eq test['cli']
      end
    end
  end
end

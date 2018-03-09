require 'spec_helper'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::SnmpNotificationReceiver; end
require 'puppet/provider/snmp_notification_receiver/ios'

describe Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  context 'Read tests:' do
    load_test_data['default']['read_and_update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
      end
    end
  end

  context 'Update tests:' do
    load_test_data['default']['read_and_update_tests'].each do |test_name, test|
      it test_name.to_s do
        expect(described_class.command_from_instance(test['expectations'].first)).to eq test['cli']
      end
    end
  end
end

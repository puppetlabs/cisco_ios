require 'spec_helper'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::SnmpNotificationReceiver; end
require 'puppet/provider/snmp_notification_receiver/ios'

describe Puppet::Provider::SnmpNotificationReceiver::SnmpNotificationReceiver do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'
end

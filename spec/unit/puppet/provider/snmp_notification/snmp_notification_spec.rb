require 'spec_helper'

module Puppet::Provider::SnmpNotification; end
require 'puppet/provider/snmp_notification/ios'

RSpec.describe Puppet::Provider::SnmpNotification::SnmpNotification do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  it_behaves_like 'a noop canonicalizer'
end

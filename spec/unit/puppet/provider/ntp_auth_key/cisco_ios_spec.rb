require 'spec_helper'

module Puppet::Provider::NtpAuthKey; end
require 'puppet/provider/ntp_auth_key/cisco_ios'

RSpec.describe Puppet::Provider::NtpAuthKey::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'
  it_behaves_like 'a noop canonicalizer'
end

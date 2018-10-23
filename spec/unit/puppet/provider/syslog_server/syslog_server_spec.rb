require 'spec_helper'

module Puppet::Provider::SyslogServer; end
require 'puppet/provider/syslog_server/ios'

RSpec.describe Puppet::Provider::SyslogServer::SyslogServer do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  it_behaves_like 'a noop canonicalizer'
end

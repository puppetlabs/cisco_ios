require 'spec_helper'

module Puppet::Provider::IosRadiusGlobal; end
require 'puppet/provider/ios_radius_global/cisco_ios'

RSpec.describe Puppet::Provider::IosRadiusGlobal::CiscoIos do
  def self.load_test_data
    radius_yaml = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/../radius_global/test_data.yaml', false)
    local_yaml = PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
    # this is a workaround for the ios_radius spec tests to include the []
    # expectation as one of the tests comes from the base radius_global
    # class which wouldn't know about the attributes
    radius_yaml['default']['read_tests']['radius_global']['expectations'][0][:attributes] = []
    combined_tests = radius_yaml
    combined_tests['default']['read_tests'] = radius_yaml['default']['read_tests'].merge(local_yaml['default']['read_tests'])
    combined_tests['default']['update_tests'] = radius_yaml['default']['update_tests'].merge(local_yaml['default']['update_tests'])
    combined_tests
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'
  it_behaves_like 'a noop canonicalizer'
end

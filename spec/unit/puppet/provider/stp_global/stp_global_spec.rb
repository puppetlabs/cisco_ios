require 'spec_helper'

module Puppet::Provider::StpGlobal; end
require 'puppet/provider/stp_global/ios'

RSpec.describe Puppet::Provider::StpGlobal::StpGlobal do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  context 'Update MST mode tests:' do
    load_test_data['default']['mst_mode_update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        if test['commands'].size.zero?
          expect { described_class.mst_commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          expect(described_class.mst_commands_from_instance(test['instance'])).to eq test['commands']
        end
      end
    end
  end
end

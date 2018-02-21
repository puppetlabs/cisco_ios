require 'spec_helper'

module Puppet::Provider::SyslogSettings; end
require 'puppet/provider/syslog_settings/ios'

RSpec.describe Puppet::Provider::SyslogSettings::SyslogSettings do
  def self.load_test_data
    Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  load_test_data['default']['tests'].each do |test_name, test|
    context "#{test['test_type']} #{test_name}" do
      if test['test_type'] == :read
        it 'creates instance from command line input' do
          expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
        end
      elsif test['test_type'] == :update
        it 'creates command lines output from is and should' do
          expect(described_class.commands_from_is_should(test['is'], test['should'])).to eq test['cli']
        end
      end
    end
  end
end

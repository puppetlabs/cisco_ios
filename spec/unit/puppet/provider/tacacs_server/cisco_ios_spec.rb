require 'spec_helper'

module Puppet::Provider::TacacsServer; end
require 'puppet/provider/tacacs_server/cisco_ios'

RSpec.describe Puppet::Provider::TacacsServer::CiscoIos do
  let(:provider) { described_class.new }
  let(:context) { instance_double(Puppet::ResourceApi::PuppetContext, 'context') }

  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  context 'Read old CLI tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it "Read: #{test_name}" do
        fake_device(test['device'])
        type_name = described_class.instance_method(:get).source_location.first.match(%r{provider\/(.*)\/})[1]
        new_type = Puppet::Type.type(type_name)
        dummy_context = Puppet::ResourceApi::PuppetContext
        dummy_context = dummy_context.new(new_type.type_definition.definition)
        return_non_enforced = described_class.instances_from_old_cli(test['old_cli'])
        return_enforced = PuppetX::CiscoIOS::Utility.enforce_simple_types(dummy_context, return_non_enforced)
        expect(return_enforced).to eq test['expectations_old_cli']
      end
    end
  end

  context 'Update old CLI tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        if test['commands_old_cli'].size.zero?
          expect { described_class.commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          expect(described_class.old_cli_commands_from_instance(test['instance'])).to eq test['commands_old_cli'].first
        end
      end
    end
  end

  canonicalize_data = [
    {
      desc: '`resources` contains no `hostname`',
      resources: [{
        name: 'default',
      }],
      results:   [{
        name: 'default',
      }],
    },
    {
      desc: '`resources` contains IPv4 `hostname`',
      resources: [{
        name: 'default',
        hostname: '192.168.1.1',
      }],
      results:   [{
        name: 'default',
        hostname: '192.168.1.1',
      }],
    },
    {
      desc: '`resources` contains uncompressed IPv6 `hostname`',
      resources: [{
        name: 'default',
        hostname: '2001:0000:4136:e378:8000:63bf:3fff:fdd2',
      }],
      results:   [{
        name: 'default',
        hostname: '2001:0:4136:E378:8000:63BF:3FFF:FDD2',
      }],
    },
    {
      desc: '`resources` contains a `hostname`',
      resources: [{
        name: 'default',
        hostname: 'foo.com',
      }],
      results:   [{
        name: 'default',
        hostname: 'foo.com',
      }],
    },
  ]

  describe '#canonicalize' do
    canonicalize_data.each do |test|
      context test[:desc].to_s do
        it 'returns canonicalized value' do
          expect(provider.canonicalize(context, test[:resources])).to eq(test[:results])
        end
      end
    end
  end
end

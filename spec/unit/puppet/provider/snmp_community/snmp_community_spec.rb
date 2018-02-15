require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::SnmpCommunity; end
require 'puppet/provider/snmp_community/snmp_community'
require 'net/ssh/telnet'

test_data = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)

describe Puppet::Provider::SnmpCommunity::SnmpCommunity do
  let(:provider) { described_class.new }
  let(:device) { instance_double(Puppet::Util::NetworkDevice::Cisco_ios::Device, 'device') }
  let(:transport) { instance_double(Puppet::Util::NetworkDevice::Transport::Cisco_ios, 'transport') }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:connection) { instance_double(Net::SSH::Telnet, 'connection') }

  before(:each) do
    allow(Puppet::Util::NetworkDevice).to receive(:current).and_return(device)
    allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:transport).and_return(transport)
    allow(transport).to receive(:connection).and_return(connection)
    allow(connection).to receive(:cmd).with(' ').and_return('cisco-c6503e#')
    allow(connection).to receive(:cmd).with('String' => 'enable', 'Match' => %r{^Password:.*$|#})
                                      .and_return('Password:')
    allow(transport).to receive(:enable_password).and_return('test_pass')
    allow(connection).to receive(:cmd).with('test_pass').and_return('cisco-c6503e#')
    allow(connection).to receive(:cmd).with('show running-config | section snmp-server community').and_return(device_output)
    # set specific
    allow(context).to receive(:creating).with(community_name).and_yield
    allow(context).to receive(:updating).with(community_name).and_yield
    allow(context).to receive(:deleting).with(community_name).and_yield
    allow(connection).to receive(:cmd).with('String' => 'conf t', 'Match' => %r{^.*\(config\).*$}).and_return('cisco-c6503e(config-if)#')
  end

  test_data['default']['tests'].each do |test|
    describe test['name'] do
      let(:device_output) { test['device_output'] }
      let(:expectations) do
        expectations = []
        test['expectations'].each do |x|
          expectations.push eval(x) # rubocop:disable Security/Eval
        end
        expectations
      end

      # If not exclusively a 'set' test then run the 'get' test
      if !test['set_test'] && !test['set_test'] == true
        it':device_output parses to a puppet hash' do
          expect(provider.get(context)).to eq expectations
        end
      end

      # Run 'set' tests
      expectation_number = 0
      test['device_output'].split("\n").each do |output_line|
        let(:community_name) { eval(test['expectations'][expectation_number])[:name] } # rubocop:disable Security/Eval

        it ':expectations parses to device_output' do
          changes = { community_name => { is: nil, should: nil } }
          if test['previous_set'] && test['previous_set'][expectation_number]
            changes[community_name][:is] = eval(test['previous_set'][expectation_number]) # rubocop:disable Security/Eval
          end
          changes[community_name][:should] = eval(test['expectations'][expectation_number]) # rubocop:disable Security/Eval
          expect(connection).to receive(:cmd).with(output_line).and_return('cisco-c6503e(config)#')
          provider.set(context, changes)
          expectation_number += 1
        end
      end
    end
  end
end

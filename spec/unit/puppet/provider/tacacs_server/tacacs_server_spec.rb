require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'
require 'puppet/utility'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::TacacsServer; end
require 'puppet/provider/tacacs_server/ios'
require 'net/ssh/telnet'

test_data = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)

describe Puppet::Provider::TacacsServer::TacacsServer do
  subject(:resource) { tacacs_server_test_resource(described_class, device_output) }

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
    allow(connection).to receive(:cmd).with('show running-config | section tacacs server').and_return(device_output)
    allow(connection).to receive(:cmd).with('String' => 'conf t', 'Match' => %r{^.*\(config\).*$}).and_return('cisco-c6503e(config)#')
    allow(context).to receive(:creating).with(tacacs_server_name).and_yield
    allow(context).to receive(:updating).with(tacacs_server_name).and_yield
    allow(context).to receive(:deleting).with(tacacs_server_name).and_yield

    allow(connection).to receive(:cmd).with('String' => "tacacs server #{tacacs_server_name}", 'Match' => %r{^.*\(config-server-tacacs\).*$}).and_return('cisco-c6503e(config-tacacs-server)#')
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
      if test['device_output'] =~ %r{(no tacacs server)}
        tacacs_server_lines = Array(test['device_output'])
      else
        tacacs_server_lines = test['device_output'].split('tacacs server ')
        tacacs_server_lines.delete_if { |e| e.empty? }
      end

      tacacs_server_lines.each do |output_line|
        let(:tacacs_server_name) { eval(test['expectations'][expectation_number])[:name] } # rubocop:disable Security/Eval

        it ':expectations parses to device_output' do
          changes = { tacacs_server_name => { is: nil, should: nil } }
          if test['previous_set'] && test['previous_set'][expectation_number]
            changes[tacacs_server_name][:is] = eval(test['previous_set'][expectation_number]) # rubocop:disable Security/Eval
          end
          changes[tacacs_server_name][:should] = eval(test['expectations'][expectation_number]) # rubocop:disable Security/Eval
          # Remove tacacs_server_name from expectation, used for get test
          if eval(test['expectations'][expectation_number])[:ensure] == :present # rubocop:disable Security/Eval
            output_line.slice! "#{tacacs_server_name}\n"
          end
          # Remove any ip mtu from expectation, we don't set these, used for get test
          output_line.slice! %r{( ip mtu \d*\n)}
          # Remove any 'no ip address' from expectation, set by default, used for get test
          output_line.slice! " no ip address\n"
          # If enabled we should send 'no shutdown' which does not show on a get
          if eval(test['expectations'][expectation_number])[:enable] == true # rubocop:disable Security/Eval
            output_line << " no shutdown\n"
          end
          expect(connection).to receive(:cmd).with(output_line).and_return('cisco-c6503e(config-tacacs-server)#')
          provider.set(context, changes)
          expectation_number += 1
        end
      end
    end
  end
end

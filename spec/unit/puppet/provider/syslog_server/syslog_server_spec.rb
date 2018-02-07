require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'
# require 'puppet/resource_api/simple_provider'

include RSpec::Mocks::ExampleMethods

module Puppet::Provider::SyslogServer; end
require 'puppet/provider/syslog_server/ios'
require 'net/ssh/telnet'

test_data = Puppet::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)

describe Puppet::Provider::SyslogServer::SyslogServer do
  let(:provider) { described_class.new }
  let(:device) { instance_double(Puppet::Util::NetworkDevice::Cisco_ios::Device, 'device') }
  let(:transport) { instance_double(Puppet::Util::NetworkDevice::Transport::Cisco_ios, 'transport') }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:connection) { instance_double(Net::SSH::Telnet, 'connection') }

  before(:each) do
    allow(Puppet::Util::NetworkDevice).to receive(:current).and_return(device)
    allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive(:transport).and_return(transport)
    allow(transport).to receive(:connection).and_return(connection)
    allow(connection).to receive(:cmd).with("\n").and_return('cisco-c6503e#')
    allow(connection).to receive(:cmd).with('String' => 'enable', 'Match' => %r{^Password:.*$|#})
                                      .and_return('Password:')
    allow(transport).to receive(:enable_password).and_return('test_pass')
    allow(connection).to receive(:cmd).with('test_pass').and_return('cisco-c6503e#')
    allow(connection).to receive(:cmd).with('show running-config all | section ^logging').and_return(device_output)
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

      it':device_output parses to a puppet hash' do
        expect(provider.get(context)).to eq expectations
      end
    end
  end
end

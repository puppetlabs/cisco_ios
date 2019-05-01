require 'spec_helper'
require 'puppet/transport/cisco_ios'
require 'puppet/resource_api/puppet_context'
require 'net/ssh/telnet'

RSpec.describe Puppet::Transport::CiscoIos do
  let(:context) { instance_double(Puppet::ResourceApi::PuppetContext, 'context') }
  let(:config) do
    {
      host: '1.1.1.1',
      user: 'admin',
      password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('password'),
      enable_password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('enable_password'),
    }
  end
  let(:instance) { described_class.new(context, config) }
  let(:telnet_connection) { double('telnet_connection') } # rubocop:disable RSpec/VerifiedDoubles
  let(:result) { '' }

  before(:each) do
    allow(Puppet).to receive(:[]).with(:vardir).and_return('.')
    allow(Net::SSH).to receive(:start).and_return('ssh_session')
    allow(Net::SSH::Telnet).to receive(:new).and_return(telnet_connection)
    allow(telnet_connection).to receive(:cmd).and_return(result)
  end

  context 'when the config is valid' do
    it { expect { instance }.not_to raise_error }
  end

  context 'when the config is invalid' do
    let(:config) do
      {
        something: '1.1.1.1',
        user: 'admin',
        password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('password'),
        enable_password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('enable_password'),
      }
    end

    # validation is not performed here, but in RSAPI
    it { expect { instance }.not_to raise_error }
  end
end

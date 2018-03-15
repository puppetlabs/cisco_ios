require 'spec_helper'
require 'puppet/type/syslog_server'

RSpec.describe 'the syslog_server type' do
  it 'loads' do
    expect(Puppet::Type.type(:syslog_server)).not_to be_nil
  end
end

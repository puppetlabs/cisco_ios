require 'spec_helper'
require 'puppet/type/syslog_settings'

RSpec.describe 'the syslog_settings type' do
  it 'loads' do
    expect(Puppet::Type.type(:syslog_settings)).not_to be_nil
  end
end

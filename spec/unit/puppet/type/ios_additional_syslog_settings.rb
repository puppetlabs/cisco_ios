require 'spec_helper'
describe 'the ios_additional_syslog_settings type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_additional_syslog_settings)).not_to be_nil
  end
end

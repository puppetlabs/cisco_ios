require 'spec_helper'
describe 'the ios_ntp_config type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_stp_global)).not_to be_nil
  end
end

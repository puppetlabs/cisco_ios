require 'spec_helper'
describe 'the ios_ntp_access_group type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_ntp_access_group)).not_to be_nil
  end
end

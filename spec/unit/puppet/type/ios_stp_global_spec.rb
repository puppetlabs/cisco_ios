require 'spec_helper'
describe 'the ios_stp_global type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_stp_global)).not_to be_nil
  end
end

require 'spec_helper'
describe 'the stp_global type' do
  it 'loads' do
    expect(Puppet::Type.type(:stp_global)).not_to be_nil
  end
end

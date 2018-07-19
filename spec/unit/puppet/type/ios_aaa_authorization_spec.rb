require 'spec_helper'
describe 'the ios_aaa_authorization type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_aaa_authorization)).not_to be_nil
  end
end

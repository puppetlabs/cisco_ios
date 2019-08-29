require 'spec_helper'
describe 'the ios_acl type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_acl)).not_to be_nil
  end
end

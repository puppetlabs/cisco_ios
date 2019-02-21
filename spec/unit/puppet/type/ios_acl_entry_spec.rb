require 'spec_helper'
describe 'the ios_acl_entry type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_acl_entry)).not_to be_nil
  end
end

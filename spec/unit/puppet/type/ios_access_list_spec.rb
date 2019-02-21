require 'spec_helper'
describe 'the ios_access_list type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_access_list)).not_to be_nil
  end
end

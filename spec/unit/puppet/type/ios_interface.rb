require 'spec_helper'
describe 'the ios_interface type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_interface)).not_to be_nil
  end
end

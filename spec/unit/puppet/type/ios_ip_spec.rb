require 'spec_helper'
describe 'the ios_ip type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_ip)).not_to be_nil
  end
end

require 'spec_helper'
describe 'the ios_network_dns type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_network_dns)).not_to be_nil
  end
end

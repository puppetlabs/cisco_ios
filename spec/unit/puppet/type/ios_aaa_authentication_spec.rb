require 'spec_helper'
describe 'the ios_aaa_authentication type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_aaa_authentication)).not_to be_nil
  end
end

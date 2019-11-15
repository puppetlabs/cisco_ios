require 'spec_helper'
describe 'the ios_cef type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_cef)).not_to be_nil
  end
end

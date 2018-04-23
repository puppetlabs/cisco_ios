require 'spec_helper'
describe 'the ios_config type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_config)).not_to be_nil
  end
end

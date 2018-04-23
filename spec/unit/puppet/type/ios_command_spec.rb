require 'spec_helper'
describe 'the ios_command type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_command)).not_to be_nil
  end
end

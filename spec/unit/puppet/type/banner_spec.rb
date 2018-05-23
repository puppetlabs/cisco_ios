require 'spec_helper'
describe 'the banner type' do
  it 'loads' do
    expect(Puppet::Type.type(:banner)).not_to be_nil
  end
end

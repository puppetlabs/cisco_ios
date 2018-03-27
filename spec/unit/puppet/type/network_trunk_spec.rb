require 'spec_helper'
require 'puppet/type/network_trunk'

RSpec.describe 'the network_trunk type' do
  it 'loads' do
    expect(Puppet::Type.type(:network_trunk)).not_to be_nil
  end
end

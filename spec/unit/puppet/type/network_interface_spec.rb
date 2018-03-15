require 'spec_helper'
require 'puppet/type/network_interface'

RSpec.describe 'the network_interface type' do
  it 'loads' do
    expect(Puppet::Type.type(:network_interface)).not_to be_nil
  end
end

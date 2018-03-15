require 'spec_helper'
require 'puppet/type/network_vlan'

RSpec.describe 'the network_vlan type' do
  it 'loads' do
    expect(Puppet::Type.type(:network_vlan)).not_to be_nil
  end
end

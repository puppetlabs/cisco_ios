require 'spec_helper'
require 'puppet/type/network_dns'

RSpec.describe 'the network_dns type' do
  it 'loads' do
    expect(Puppet::Type.type(:network_dns)).not_to be_nil
  end
end

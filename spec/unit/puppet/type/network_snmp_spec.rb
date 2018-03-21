require 'spec_helper'
require 'puppet/type/network_snmp'

RSpec.describe 'the network_snmp type' do
  it 'loads' do
    expect(Puppet::Type.type(:network_snmp)).not_to be_nil
  end
end

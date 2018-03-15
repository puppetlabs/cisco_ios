require 'spec_helper'
require 'puppet/type/snmp_community'

RSpec.describe 'the snmp_community type' do
  it 'loads' do
    expect(Puppet::Type.type(:snmp_community)).not_to be_nil
  end
end

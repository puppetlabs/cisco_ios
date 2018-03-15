require 'spec_helper'
require 'puppet/type/snmp_user'

RSpec.describe 'the snmp_user type' do
  it 'loads' do
    expect(Puppet::Type.type(:snmp_user)).not_to be_nil
  end
end

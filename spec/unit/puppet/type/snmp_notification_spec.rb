require 'spec_helper'
require 'puppet/type/snmp_notification'

RSpec.describe 'the snmp_notification type' do
  it 'loads' do
    expect(Puppet::Type.type(:snmp_notification)).not_to be_nil
  end
end

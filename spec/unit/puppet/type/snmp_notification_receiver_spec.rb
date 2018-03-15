require 'spec_helper'
require 'puppet/type/snmp_notification_receiver'

RSpec.describe 'the snmp_notification_receiver type' do
  it 'loads' do
    expect(Puppet::Type.type(:snmp_notification_receiver)).not_to be_nil
  end
end

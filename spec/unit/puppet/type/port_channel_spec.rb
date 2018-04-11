require 'spec_helper'
require 'puppet/type/port_channel'

RSpec.describe 'the port_channel type' do
  it 'loads' do
    expect(Puppet::Type.type(:port_channel)).not_to be_nil
  end
end

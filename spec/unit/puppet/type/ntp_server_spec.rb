require 'spec_helper'
require 'puppet/type/ntp_server'

RSpec.describe 'the ntp_server type' do
  it 'loads' do
    expect(Puppet::Type.type(:ntp_server)).not_to be_nil
  end
end

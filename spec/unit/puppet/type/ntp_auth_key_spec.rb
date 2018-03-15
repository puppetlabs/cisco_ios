require 'spec_helper'
require 'puppet/type/ntp_auth_key'

RSpec.describe 'the ntp_auth_key type' do
  it 'loads' do
    expect(Puppet::Type.type(:ntp_auth_key)).not_to be_nil
  end
end

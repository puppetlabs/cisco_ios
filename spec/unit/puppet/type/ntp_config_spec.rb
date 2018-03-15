require 'spec_helper'
require 'puppet/type/ntp_config'

RSpec.describe 'the ntp_config type' do
  it 'loads' do
    expect(Puppet::Type.type(:ntp_config)).not_to be_nil
  end
end

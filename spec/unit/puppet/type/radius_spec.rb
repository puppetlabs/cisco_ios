require 'spec_helper'
require 'puppet/type/radius'

RSpec.describe 'the radius type' do
  it 'loads' do
    expect(Puppet::Type.type(:radius)).not_to be_nil
  end
end

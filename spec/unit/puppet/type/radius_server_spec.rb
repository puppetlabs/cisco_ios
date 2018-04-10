require 'spec_helper'
require 'puppet/type/radius_server'

RSpec.describe 'the radius_server type' do
  it 'loads' do
    expect(Puppet::Type.type(:radius_server)).not_to be_nil
  end
end

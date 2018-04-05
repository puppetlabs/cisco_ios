require 'spec_helper'
require 'puppet/type/radius_global'

RSpec.describe 'the radius_global type' do
  it 'loads' do
    expect(Puppet::Type.type(:radius_global)).not_to be_nil
  end
end

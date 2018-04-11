require 'spec_helper'
require 'puppet/type/radius_server_group'

RSpec.describe 'the radius_server_group type' do
  it 'loads' do
    expect(Puppet::Type.type(:radius_server_group)).not_to be_nil
  end
end

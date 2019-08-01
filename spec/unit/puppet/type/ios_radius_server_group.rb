require 'spec_helper'
describe 'the ios_radius_server_group type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_radius_server_group)).not_to be_nil
  end
end

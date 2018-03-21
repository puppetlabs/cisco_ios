require 'spec_helper'
require 'puppet/type/name_server'

RSpec.describe 'the name_server type' do
  it 'loads' do
    expect(Puppet::Type.type(:name_server)).not_to be_nil
  end
end

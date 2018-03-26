require 'spec_helper'
require 'puppet/type/tacacs_server_group'

RSpec.describe 'the tacacs server group type' do
  it 'loads' do
    expect(Puppet::Type.type(:tacacs_server_group)).not_to be_nil
  end
end

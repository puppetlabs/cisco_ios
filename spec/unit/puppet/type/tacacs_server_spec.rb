require 'spec_helper'
require 'puppet/type/tacacs_server'

RSpec.describe 'the tacacs_server type' do
  it 'loads' do
    expect(Puppet::Type.type(:tacacs_server)).not_to be_nil
  end
end

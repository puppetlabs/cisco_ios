require 'spec_helper'
require 'puppet/type/tacacs'

RSpec.describe 'the tacacs type' do
  it 'loads' do
    expect(Puppet::Type.type(:tacacs)).not_to be_nil
  end
end

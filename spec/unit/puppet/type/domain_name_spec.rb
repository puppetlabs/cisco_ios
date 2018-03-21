require 'spec_helper'
require 'puppet/type/domain_name'

RSpec.describe 'the domain_name type' do
  it 'loads' do
    expect(Puppet::Type.type(:domain_name)).not_to be_nil
  end
end

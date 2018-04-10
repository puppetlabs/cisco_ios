require 'spec_helper'
require 'puppet/type/search_domain'

RSpec.describe 'the search_domain type' do
  it 'loads' do
    expect(Puppet::Type.type(:search_domain)).not_to be_nil
  end
end

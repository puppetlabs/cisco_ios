require 'spec_helper'
describe 'the ios_aaa_new_model type' do
  it 'loads' do
    expect(Puppet::Type.type(:ios_aaa_session_id)).not_to be_nil
  end
end

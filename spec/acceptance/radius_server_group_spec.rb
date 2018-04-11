require 'spec_helper_acceptance'

describe 'radius_server_group' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    radius_server_group { "bill":
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'add radius_server_group' do
    pp = <<-EOS
    radius_server_group { "bill":
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('radius_server_group', 'bill')
    expect(result).to match(%r{ensure.*present})
  end
end

require 'spec_helper_acceptance'

describe 'radius_server_group' do
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

  it 'update radius_server_group' do
    pp = <<-EOS
    radius_server_group { "bill":
      ensure => 'present',
      servers => ['1.2.3.4', '4.3.2.1'],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('radius_server_group', 'bill')
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{servers.*['1.2.3.4', '4.3.2.1']})
  end

  it 'remove radius_server_group' do
    pp = <<-EOS
    radius_server_group { "bill":
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('radius_server_group', 'bill')
    expect(result).to match(%r{ensure.*absent})
  end
end

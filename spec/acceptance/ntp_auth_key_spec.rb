require 'spec_helper_acceptance'

describe 'ntp_auth_key' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
  ntp_auth_key { '42':
    ensure => absent,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add an ntp_auth_key' do
    pp = <<-EOS
  ntp_auth_key { '42':
    ensure => present,
    algorithm => "md5",
    key => "135445415F59",
    encryption_type => 7,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_auth_key', '42')
    expect(result).to match(%r{algorithm.*md5})
    # Key becomes encrypted
    expect(result).to match(%r{encryption_type.*7})
    expect(result).to match(%r{ensure.*present})
  end

  it 'edit an existing ntp_auth_key' do
    current_result = run_resource('ntp_auth_key', '42')
    current_key = current_result.match(%r{key.*=>.*'(\w.*)'})[1]
    pp = <<-EOS
  ntp_auth_key { '42':
    ensure => present,
    algorithm => "md5",
    key => "12345abc",
    encryption_type => 5,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_auth_key', '42')
    expect(result).to match(%r{algorithm.*md5})
    expect(result).not_to match(%r{key.*#{current_key}})
    expect(result).to match(%r{ensure.*present})
  end
  it 'remove an existing ntp_server' do
    pp = <<-EOS
  ntp_auth_key { '42':
    ensure => absent,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_auth_key', '42')
    expect(result).to match(%r{ensure.*absent})
  end
end

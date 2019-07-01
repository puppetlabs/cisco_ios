require 'spec_helper_acceptance'

describe 'ntp_auth_key' do
  it 'add an ntp_auth_key' do
    pp = <<-EOS
  ntp_auth_key { '42':
    ensure => present,
    algorithm => "md5",
    password => "135445415F59",
    mode => 7,
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
    expect(result).to match(%r{mode.*7})
    expect(result).to match(%r{ensure.*present})
  end

  it 'edit an existing ntp_auth_key' do
    current_result = run_resource('ntp_auth_key', '42')
    current_password = current_result.match(%r{password.*=>.*'(\w.*)'})[1]
    pp = <<-EOS
  ntp_auth_key { '42':
    ensure => present,
    algorithm => "md5",
    password => "12345abc",
    mode => 5,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_auth_key', '42')
    expect(result).to match(%r{algorithm.*md5})
    new_password = result.match(%r{password.*=>.*'(\w.*)'})[1]
    expect(new_password).not_to eq(current_password)
    expect(result).to match(%r{ensure.*present})
  end
  it 'remove an existing ntp_auth_key' do
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

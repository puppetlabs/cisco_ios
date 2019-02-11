require 'spec_helper_acceptance'

describe 'ios_aaa_authorization' do
  before(:all) do
    pp = <<-EOS
    ios_aaa_authorization { 'auth-proxy default':
      authorization_service => 'auth-proxy',
      authorization_list => 'default',
      server_groups => ['tacacs+'],
      local => false,
      if_authenticated => false,
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'apply aaa authorization' do
    pp = <<-EOS
    ios_aaa_authorization { 'auth-proxy default':
      authorization_service => 'auth-proxy',
      authorization_list => 'default',
      server_groups => ['tacacs+'],
      local => false,
      if_authenticated => false,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_authorization', "'auth-proxy default'")
    expect(result).to match(%r{authorization_service.*auth-proxy})
    expect(result).to match(%r{authorization_list.*default})
    expect(result).to match(%r{server_groups.*tacacs})
    expect(result).to match(%r{local.*false})
    expect(result).to match(%r{if_authenticated.*false})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove aaa authorization' do
    pp = <<-EOS
    ios_aaa_authorization { 'auth-proxy default':
      authorization_service => 'auth-proxy',
      authorization_list => 'default',
      server_groups => ['tacacs+'],
      local => false,
      if_authenticated => false,
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_authorization', "'auth-proxy default'")
    expect(result).to match(%r{ensure.*absent})
  end
end

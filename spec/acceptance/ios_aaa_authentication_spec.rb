require 'spec_helper_acceptance'

describe 'ios_aaa_authentication' do
  before(:all) do
    pp = <<-EOS
    ios_aaa_authentication { 'ppp default':
      authentication_list_set => 'ppp',
      authentication_list => 'default',
      server_groups => ['test1'],
      enable_password => false,
      local => true,
      switch_auth => false,
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'apply aaa authentication' do
    pp = <<-EOS
    ios_aaa_authentication { 'ppp default':
      authentication_list_set => 'ppp',
      authentication_list => 'default',
      server_groups => ['test1'],
      enable_password => false,
      local => true,
      switch_auth => false,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_authentication', "'ppp default'")
    expect(result).to match(%r{authentication_list_set.*ppp})
    expect(result).to match(%r{authentication_list.*default})
    expect(result).to match(%r{enable_password.*false})
    expect(result).to match(%r{local.*true})
    expect(result).to match(%r{server_groups.*test1})
    expect(result).to match(%r{switch_auth.*false})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove aaa authentication' do
    pp = <<-EOS
    ios_aaa_authentication { 'ppp default':
      authentication_list_set => 'ppp',
      authentication_list => 'default',
      server_groups => ['test1'],
      enable_password => false,
      local => true,
      switch_auth => false,
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_authentication', "'ppp default'")
    expect(result).to match(%r{ensure.*absent})
  end
end

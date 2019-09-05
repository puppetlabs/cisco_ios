require 'spec_helper_acceptance'

describe 'ios_access_list' do
  it 'apply access lists' do
    pp = <<-EOS
    ios_access_list { 'test42':
      access_list_type => 'Standard',
      ensure => 'present',
    }
    ios_access_list { 'test43':
      access_list_type => 'Extended',
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_warnings: true)
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
    # Check puppet resource
    result = run_resource('ios_access_list', 'test42')
    expect(result).to match(%r{access_list_type.*Standard})
    expect(result).to match(%r{ensure.*present})
    result = run_resource('ios_access_list', 'test43')
    expect(result).to match(%r{access_list_type.*Extended})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove access lists' do
    pp = <<-EOS
    ios_access_list { 'test42':
      access_list_type => 'Standard',
      ensure => 'absent',
    }
    ios_access_list { 'test43':
      access_list_type => 'Extended',
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_warnings: true)
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
    # Check puppet resource
    result = run_resource('ios_access_list', 'test42')
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_access_list', 'test43')
    expect(result).to match(%r{ensure.*absent})
  end
end

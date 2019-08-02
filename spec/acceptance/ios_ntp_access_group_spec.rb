require 'spec_helper_acceptance'

describe 'ios_ntp_access_group' do
  it 'apply access groups' do
    pp = <<-EOS
    ios_ntp_access_group { 'system-cpp-ripv2':
      access_group_type => 'serve',
      ipv6_access_group => false,
      ensure => 'present',
    }
    ios_ntp_access_group { 'another_name':
      access_group_type => 'peer',
      ipv6_access_group => true,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_access_group', 'system-cpp-ripv2')
    expect(result).to match(%r{access_group_type.*serve})
    expect(result).to match(%r{ipv6_access_group.*false})
    expect(result).to match(%r{ensure.*present})
    result = run_resource('ios_ntp_access_group', 'another_name')
    expect(result).to match(%r{access_group_type.*peer})
    expect(result).to match(%r{ipv6_access_group.*true})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove access groups' do
    pp = <<-EOS
    ios_ntp_access_group { 'system-cpp-ripv2':
      access_group_type => 'serve',
      ensure => absent,
    }
    ios_ntp_access_group { 'another_name':
      access_group_type => 'peer',
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_access_group', 'system-cpp-ripv2')
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_ntp_access_group', 'another_name')
    expect(result).to match(%r{ensure.*absent})
  end
end

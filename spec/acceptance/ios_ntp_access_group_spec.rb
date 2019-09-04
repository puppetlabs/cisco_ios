require 'spec_helper_acceptance'

describe 'ios_ntp_access_group' do
  before(:all) do
    pp = <<-EOS
    ios_access_list { 'test_acl':
      access_list_type => 'Standard',
      ensure => 'present',
    }

    ios_config { 'create numbered access list for access group tests':
      command => 'access-list 11 permit any',
    }
    EOS

    # 3750, 3560 devices don't support creating an ipv6 access list
    unless ['3750', '3560'].include?(device_model)
      pp << <<-EOS
      ios_config { 'create ipv6 access list for access group tests':
        command => "
        ipv6 access-list ipv6_acl
           permit udp any eq 547 any eq 546 sequence 20
        ",
      }
      EOS
    end
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'apply access group using a Standard IP access list' do
    pp = <<-EOS
    ios_ntp_access_group { '11':
      access_group_type => 'serve',
      ipv6_access_group => false,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_access_group', '11')
    expect(result).to match(%r{access_group_type.*serve})
    expect(result).to match(%r{ipv6_access_group.*false})
    expect(result).to match(%r{ensure.*present})
  end

  it 'apply access group using a (WORD) named access list' do
    skip "this device #{device_model} does not support using (WORD) named access lists" if ['3750', '4507', '4948', '3560'].include?(device_model)
    pp = <<-EOS
    ios_ntp_access_group { 'test_acl':
      access_group_type => 'serve',
      ipv6_access_group => false,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_access_group', 'test_acl')
    expect(result).to match(%r{access_group_type.*serve})
    expect(result).to match(%r{ipv6_access_group.*false})
    expect(result).to match(%r{ensure.*present})
  end

  it 'apply access groups with ipv6_access_group true' do
    skip "this device #{device_model} does not support ipv6_access_group attribute" if ['2960', '3750', '4507', '4948', '6503', '3560'].include?(device_model)
    pp = <<-EOS
    ios_ntp_access_group { 'ipv6_acl':
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
    result = run_resource('ios_ntp_access_group', 'ipv6_acl')
    expect(result).to match(%r{access_group_type.*peer})
    expect(result).to match(%r{ipv6_access_group.*true})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove access groups' do
    pp = <<-EOS
    ios_ntp_access_group { '11':
      access_group_type => 'serve',
      ensure => absent,
    }

    ios_ntp_access_group { 'test_acl':
      access_group_type => 'serve',
      ensure => absent,
    }

    ios_ntp_access_group { 'ipv6_acl':
      access_group_type => 'peer',
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_access_group', '11')
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_ntp_access_group', 'test_acl')
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_ntp_access_group', 'ipv6_acl')
    expect(result).to match(%r{ensure.*absent})
  end
end

require 'spec_helper_acceptance'

describe 'ios_ntp_access_group' do
  before(:all) do
    pp = <<-EOS
    ios_access_list { 'ipv4_acl':
      access_list_type => 'Standard',
      ensure => 'present',
    }

    ios_config { 'create ipv6 access list for access group tests':
      command => "
      ipv6 access-list ipv6_acl_another_name
         permit udp any eq 547 any eq 546 sequence 20
      ",
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'apply access groups' do
    pp = <<-EOS
    ios_ntp_access_group { 'ipv4_acl':
      access_group_type => 'serve',
      ipv6_access_group => false,
      ensure => 'present',
    }
    ios_ntp_access_group { 'ipv6_acl_another_name':
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
    result = run_resource('ios_ntp_access_group', 'ipv4_acl')
    expect(result).to match(%r{access_group_type.*serve})
    expect(result).to match(%r{ipv6_access_group.*false})
    expect(result).to match(%r{ensure.*present})
    result = run_resource('ios_ntp_access_group', 'ipv6_acl_another_name')
    expect(result).to match(%r{access_group_type.*peer})
    expect(result).to match(%r{ipv6_access_group.*true})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove access groups' do
    pp = <<-EOS
    ios_ntp_access_group { 'ipv4_acl':
      access_group_type => 'serve',
      ensure => absent,
    }
    ios_ntp_access_group { 'ipv6_acl_another_name':
      access_group_type => 'peer',
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_access_group', 'ipv4_acl')
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_ntp_access_group', 'ipv6_acl_another_name')
    expect(result).to match(%r{ensure.*absent})
  end
end

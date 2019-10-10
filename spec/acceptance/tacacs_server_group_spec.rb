require 'spec_helper_acceptance'

describe 'tacacs_server_group' do
  it 'add tacacs server group' do
    pp = <<-EOS
    tacacs_server_group { "test1":
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{ensure => 'present'})
    expect(result).to match(%r{source_interface => 'unset'})
    expect(result).to match(%r{vrf => 'unset'})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'edit tacacs server group single server' do
    source_interface = ['4948'].include?(device_model) ? '' : "source_interface => 'Vlan2',"
    vrf = ['2960', '4503', '3750', '4948'].include?(device_model) ? '' : "vrf => 'Test-Vrf',"
    pp = <<-EOS
    tacacs_server_group { "test1":
      ensure => 'present',
      servers => ['1.2.3.4'],
      #{source_interface}
      #{vrf}
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{ensure => 'present'})
    expect(result).to match(%r{servers => \['1.2.3.4'\]})
    expect(result).to match(%r{source_interface => 'Vlan2'}) if source_interface != ''
    expect(result).to match(%r{vrf => 'Test-Vrf'}) if vrf != ''
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'edit tacacs server group multiple servers' do
    source_interface = ['4948'].include?(device_model) ? '' : "source_interface => 'unset',"
    vrf = ['2960', '4503', '3750', '4948'].include?(device_model) ? '' : "vrf => 'unset',"
    pp = <<-EOS
    tacacs_server_group { "test1":
      ensure => 'present',
      servers => ['1.2.3.6','1.2.3.5'],
      #{source_interface}
      #{vrf}
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{ensure => 'present'})
    expect(result).to match(%r{servers => \['1.2.3.5', '1.2.3.6'\]})
    expect(result).to match(%r{source_interface => 'unset'})
    expect(result).to match(%r{vrf => 'unset'})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'remove tacacs server group' do
    pp = <<-EOS
    tacacs_server_group { "test1":
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{ensure => 'absent'})
    # Are we idempotent
    run_device(allow_changes: false)
  end
end

require 'spec_helper_acceptance'

describe 'tacacs_server' do
  it 'add a tacacs server - CLI IPV4' do
    pp = <<-EOS
  tacacs_server { '4.3.2.1':
    ensure => 'present',
    hostname => '4.3.2.1',
    key => '0835495D1D12000E43',
    key_format => 7,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server', '4.3.2.1')

    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{4.3.2.1.*})
    expect(result).to match(%r{single_connection.*false})
    expect(result).to match(%r{hostname.*4.3.2.1})
    # Has a key, encrypted by default on 2960
    if result =~ %r{key_format.*7}
      expect(result).to match(%r{key.*})
    else
      # Plaintext
      expect(result).to match(%r{key.*testkey1})
    end
  end

  it 'edit an existing tacacs server - CLI IPV4' do
    pp = <<-EOS
  tacacs_server { '4.3.2.1':
    ensure => 'present',
    port => 7001,
    key => '32324222424243',
    key_format => 7,
    timeout => 420,
    hostname => '4.3.2.1',
    single_connection => true,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server', '4.3.2.1')

    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{4.3.2.1.*})
    expect(result).to match(%r{single_connection.*true})
    expect(result).to match(%r{hostname.*4.3.2.1})
    expect(result).to match(%r{key.*32324222424243})
    expect(result).to match(%r{port.*7001})
    expect(result).to match(%r{key_format.*7})
    expect(result).to match(%r{timeout.*420})
  end

  it 'remove existing tacacs servers - CLI IPV4' do
    pp = <<-EOS
  tacacs_server { '4.3.2.1':
    ensure => 'absent',
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server', '4.3.2.1')
    expect(result).to match(%r{4.3.2.1.*})
    expect(result).to match(%r{ensure.*absent})
  end

  it 'add a tacacs server - new CLI IPv6' do
    skip "This device #{device_model} is not compatible with the new CLI ipv6" if ['3750', '4507', '4948'].include?(device_model)
    pp = <<-EOS
  tacacs_server { 'test_tacacs_1':
    ensure => 'present',
    port => 7001,
    key => '32324222424243',
    key_format => 7,
    timeout => 420,
    hostname => '2001:0000:4136:e378:8000:63bf:3fff:fdd2',
    single_connection => true,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server', 'test_tacacs_1')

    expect(result).to match(%r{test_tacacs_1.*})
    expect(result).to match(%r{single_connection.*true})
    expect(result).to match(%r{hostname.*2001:0:4136:E378:8000:63BF:3FFF:FDD2})
    expect(result).to match(%r{key.*32324222424243})
    expect(result).to match(%r{port.*7001})
    expect(result).to match(%r{key_format.*7})
    expect(result).to match(%r{timeout.*420})
  end
  it 'unset fields on an existing tacacs server - new CLI IPv6' do
    skip "This device #{device_model} is not compatible with the new CLI ipv6" if ['3750', '4507', '4948'].include?(device_model)
    pp = <<-EOS
tacacs_server { 'test_tacacs_1':
  ensure => 'present',
  key => 'unset',
  key_format => 0,
  timeout => 0,
  hostname => 'unset',
  single_connection => false,
}
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server', 'test_tacacs_1')
    expect(result).to match(%r{ensure =>.*present})
    expect(result).to match(%r{test_tacacs_1.*})
    expect(result).to match(%r{single_connection =>.*false})
    expect(result).to match(%r{hostname.*unset})
    expect(result).to match(%r{key_format.*0})
    expect(result).to match(%r{key.*unset})
    expect(result).to match(%r{timeout.*0})
  end

  it 'remove existing tacacs servers - new CLI IPv6' do
    skip "This device #{device_model} is not compatible with new CLI ipv6" if ['3750', '4507', '4948'].include?(device_model)
    pp = <<-EOS
tacacs_server { 'test_tacacs_1':
  ensure => 'absent',
}
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server', 'test_tacacs_1')
    expect(result).to match(%r{test_tacacs_1.*})
    expect(result).to match(%r{ensure.*absent})
  end
end

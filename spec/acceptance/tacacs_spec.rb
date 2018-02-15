require 'spec_helper_acceptance'

describe 'should change tacacs' do
  before(:all) do
    # Remove if already present, add test Vlan
    pp = <<-EOS
  tacacs { "default":
    ensure => 'absent',
  }
  network_interface { 'Vlan32':
    ensure => 'present',
  }
  network_interface { 'Vlan64':
    ensure => 'present',
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add tacacs' do
    pp = <<-EOS
  tacacs { "default":
    ensure => 'present',
    key => "32324222424243",
    key_format => 7,
    source_interface => "Vlan64",
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs', 'default')
    expect(result).to match(%r{key.*=>.*"32324222424243",})
    expect(result).to match(%r{source.*=>.*"Vlan64"})
    expect(result).to match(%r{key_format.*=>.*"7"})
  end

  it 'edit tacacs' do
    pp = <<-EOS
  tacacs { "default":
    ensure => 'present',
    key => "testkey",
    key_format => 0,
    source_interface => "Vlan32",
    timeout => 42,
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs', 'default')
    expect(result).to match(%r{key.*=>.*"testkey",})
    expect(result).to match(%r{source.*=>.*"Vlan32"})
    expect(result).not_to match(%r{key_format.*})
    expect(result).to match(%r{timeout.*=>.*"42"})
  end

  it 'unset tacacs' do
    pp = <<-EOS
  tacacs { "default":
    ensure => 'present',
    key => "unset",
    source_interface => "unset",
    timeout => 0,
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs', 'default')
    expect(result).not_to match(%r{key.*})
    expect(result).not_to match(%r{source.*})
    expect(result).not_to match(%r{timeout.*})
  end

  it 'remove tacacs' do
    pp = <<-EOS
  tacacs { "default":
    ensure => 'absent',
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs', 'default')
    expect(result).to match(%r{ensure.*=>.*absent})
  end

  after(:all) do
    # Remove test Vlan
    pp = <<-EOS
  network_interface { 'Vlan32':
    ensure => 'absent',
  }
  network_interface { 'Vlan64':
    ensure => 'absent',
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end
end

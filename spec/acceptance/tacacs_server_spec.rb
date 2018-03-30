require 'spec_helper_acceptance'

describe 'tacacs_server' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
  tacacs_server { 'test_tacacs_1':
    ensure => 'absent',
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add a tacacs server' do
    pp = <<-EOS
  tacacs_server { 'test_tacacs_1':
    ensure => 'present',
    hostname => '4.3.2.1',
    key => 'testkey1',
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server', 'test_tacacs_1')
    expect(result).to match(%r{test_tacacs_1.*})
    expect(result).to match(%r{single_connection.*false})
    expect(result).to match(%r{hostname.*4.3.2.1})
    # Has a key, encrypted by default on 2960
    if device_model =~ %r{2960}
      expect(result).to match(%r{key.*})
      expect(result).to match(%r{key_format.*7})
    end
    # 6509 Can use plain text key
    if device_model =~ %r{6509}
      expect(result).to match(%r{key.*testkey1})
    end
  end

  it 'edit an existing tacacs server' do
    pp = <<-EOS
  tacacs_server { 'test_tacacs_1':
    ensure => 'present',
    port => '7001',
    key => '32324222424243',
    key_format => '7',
    timeout => '420',
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
  it 'unset fields on an existing tacacs server' do
    pp = <<-EOS
  tacacs_server { 'test_tacacs_1':
    ensure => 'present',
    port => '0',
    key => 'unset',
    timeout => '0',
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
    expect(result).to match(%r{test_tacacs_1.*})
    expect(result).to match(%r{single_connection.*false})
    expect(result).not_to match(%r{hostname.*})
    expect(result).not_to match(%r{key.*})
    expect(result).not_to match(%r{port.*})
    expect(result).not_to match(%r{key_format.*})
    expect(result).not_to match(%r{timeout.*})
  end

  it 'remove an existing tacacs server' do
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

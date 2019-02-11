require 'spec_helper_acceptance'

describe 'tacacs_server_group' do
  before(:all) do
    # Remove if already present, add test Vlan
    pp = <<-EOS
    tacacs_server_group { "test1":
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'add tacacs server group' do
    pp = <<-EOS
  tacacs_server_group { "test1":
    ensure => 'present',
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{present})
  end

  it 'edit tacacs server group single server' do
    pp = <<-EOS
  tacacs_server_group { "test1":
    ensure => 'present',
    servers => ['1.2.3.4'],
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{servers.*1.2.3.4})
  end

  it 'edit tacacs server group multiple servers' do
    pp = <<-EOS
  tacacs_server_group { "test1":
    ensure => 'present',
    servers => ['1.2.3.5','1.2.3.6'],
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{servers.*1.2.3.5.*1.2.3.6})
  end

  it 'remove tacacs server group' do
    pp = <<-EOS
  tacacs_server_group { "test1":
    ensure => 'absent',
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_server_group', 'test1')
    expect(result).to match(%r{ensure.*absent})
  end
end

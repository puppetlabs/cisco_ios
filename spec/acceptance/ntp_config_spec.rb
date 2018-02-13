require 'spec_helper_acceptance'

describe 'should change ntp_config' do
  before(:all) do
    # Remove if already present, add test Vlan
    pp = <<-EOS
  ntp_config { 'default':
    authenticate => false,
    source_interface => 'unset',
    trusted_key => '',
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

  it 'add ntp_config' do
    pp = <<-EOS
  ntp_config { 'default':
    authenticate => true,
    source_interface => 'Vlan64',
    trusted_key => '12,24,48,96',
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_config', 'default')
    expect(result).to match(%r{authenticate.*=>.*true,})
    expect(result).to match(%r{source.*=>.*"Vlan64"})
    expect(result).to match(%r{trusted_key.*=>.*"12,24,48,96"})
  end

  it 'edit ntp_config' do
    pp = <<-EOS
  ntp_config { 'default':
    authenticate => true,
    source_interface => 'Vlan32',
    trusted_key => '48,96,128',
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_config', 'default')
    expect(result).to match(%r{authenticate.*=>.*true,})
    expect(result).to match(%r{source.*=>.*"Vlan32"})
    expect(result).to match(%r{trusted_key.*=>.*"48,96,128"})
  end
  it 'remove ntp_config' do
    pp = <<-EOS
  ntp_config { 'default':
    authenticate => false,
    source_interface => 'unset',
    trusted_key => '',
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_config', 'default')
    expect(result).to match(%r{authenticate.*=>.*false,})
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

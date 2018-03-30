require 'spec_helper_acceptance'

describe 'network_snmp' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    network_snmp { 'default':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add network SNMP' do
    pp = <<-EOS
    network_snmp { 'default':
      enable => 'true',
      ensure => 'present',
      contact => 'Mr Tayto',
      location => 'Tayto castle',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_snmp', 'default')
    expect(result).to match(%r{enable.* => true,})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{contact.*Mr Tayto})
    expect(result).to match(%r{location.*Tayto castle})
  end

  it 'edit an existing network SNMP' do
    pp = <<-EOS
    network_snmp { 'default':
      enable => 'true',
      ensure => 'present',
      contact => 'Purple Monster',
      location => 'Monster Munch caves',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_snmp', 'default')
    expect(result).to match(%r{enable.* => true,})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{contact.*Purple Monster})
    expect(result).to match(%r{location.*Monster Munch caves})
  end
  it 'ensure absent on existing network SNMP' do
    pp = <<-EOS
    network_snmp { 'default':
      enable => 'true',
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_snmp', 'default')
    expect(result).to match(%r{enable.* => true,})
    expect(result).to match(%r{ensure.*absent})
    expect(result).not_to match(%r{contact.*})
    expect(result).not_to match(%r{location.*})
  end
  it 'enable false on network SNMP' do
    pp = <<-EOS
    network_snmp { 'default':
      enable => 'false',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_snmp', 'default')
    expect(result).to match(%r{enable.* => false,})
    expect(result).to match(%r{ensure.*absent})
    expect(result).not_to match(%r{contact.*})
    expect(result).not_to match(%r{location.*})
  end
end

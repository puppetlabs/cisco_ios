require 'spec_helper_acceptance'

describe 'ios_snmp_global' do
  it 'set ios_snmp_global' do
    pp = <<-EOS
    ios_snmp_global { 'default':
      trap_source => 'Vlan42',
      system_shutdown => true,
      contact => 'SNMP_TEST',
      manager => true,
      manager_session_timeout => 20,
      ifmib_ifindex_persist => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_snmp_global', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{trap_source => 'Vlan42'})
    expect(result).to match(%r{system_shutdown => true})
    expect(result).to match(%r{contact => 'SNMP_TEST'})
    expect(result).to match(%r{manager => true})
    expect(result).to match(%r{manager_session_timeout => 20})
    expect(result).to match(%r{ifmib_ifindex_persist => true})
  end

  it 'edit ios_snmp_global' do
    pp = <<-EOS
    ios_snmp_global { 'default':
      trap_source => 'Vlan43',
      system_shutdown => true,
      contact => 'SNMP_TEST_TWO',
      manager => true,
      manager_session_timeout => 'unset',
      ifmib_ifindex_persist => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_snmp_global', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{trap_source => 'Vlan43'})
    expect(result).to match(%r{system_shutdown => true})
    expect(result).to match(%r{contact => 'SNMP_TEST_TWO'})
    expect(result).to match(%r{manager => true})
    expect(result).not_to match(%r{manager_session_timeout =>})
    expect(result).to match(%r{ifmib_ifindex_persist => true})
  end

  it 'unset ios_snmp_global' do
    pp = <<-EOS
    ios_snmp_global { "default":
      trap_source => 'unset',
      system_shutdown => false,
      contact => 'unset',
      manager => false,
      manager_session_timeout => 'unset',
      ifmib_ifindex_persist => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_snmp_global', 'default')
    expect(result).to match(%r{default.*})
    # Default values
    expect(result).not_to match(%r{trap_source =>})
    expect(result).to match(%r{system_shutdown => false})
    expect(result).not_to match(%r{contact =>})
    expect(result).to match(%r{manager => false})
    expect(result).not_to match(%r{manager_session_timeout =>})
    expect(result).to match(%r{ifmib_ifindex_persist => false})
  end
end

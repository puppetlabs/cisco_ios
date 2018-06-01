require 'spec_helper_acceptance'

describe 'network_snmp' do
  before(:all) do
    # set to a known config
    pp = <<-EOS
    network_snmp { 'default':
      enable => true,
      contact => 'contact',
      location => 'location',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'edit network SNMP' do
    pp = <<-EOS
    network_snmp { 'default':
      enable => true,
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
    expect(result).to match(%r{contact.*Mr Tayto})
    expect(result).to match(%r{location.*Tayto castle})
  end

  it 'edit an existing network SNMP' do
    pp = <<-EOS
    network_snmp { 'default':
      enable => true,
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
    expect(result).to match(%r{contact.*Purple Monster})
    expect(result).to match(%r{location.*Monster Munch caves})
  end
end

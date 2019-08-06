require 'spec_helper_acceptance'

describe 'snmp_notification' do
  it 'enable stpx' do
    pp = <<-EOS
    snmp_notification { 'stpx':
      enable => true
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_notification', 'stpx')
    expect(result).to match(%r{enable.*true})
  end

  it 'disable stpx' do
    pp = <<-EOS
    snmp_notification { 'stpx':
      enable => false
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_notification', 'stpx')
    expect(result).to match(%r{enable.*false})
  end
end

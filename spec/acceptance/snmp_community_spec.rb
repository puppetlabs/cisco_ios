require 'spec_helper_acceptance'

describe 'Running puppet device should' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
snmp_community { 'ACCEPTANCE':
  ensure => 'absent'
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    run_device(options = { allow_changes: false })
  end

  it 'add a basic SNMP Community string' do
    pp = <<-EOS
snmp_community { 'ACCEPTANCE':
  group => 'RO',
  ensure => 'present'
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('snmp_community', 'ACCEPTANCE')
    expect(result).to match(%r{ensure.*:present})
    expect(result).to match(%r{group.*RO})
  end

  it 'change the SNMP Community group' do
    pp = <<-EOS
snmp_community { 'ACCEPTANCE':
  group => 'RW',
  ensure => 'present'
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('snmp_community', 'ACCEPTANCE')
    expect(result).to match(%r{ensure.*:present})
    expect(result).to match(%r{group.*RW})
  end

  it 'Add Access List to the SNMP Community' do
    pp = <<-EOS
snmp_community { 'ACCEPTANCE':
  group => 'RW',
  acl => 'GREEN',
  ensure => 'present'
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('snmp_community', 'ACCEPTANCE')
    expect(result).to match(%r{ensure.*:present})
    expect(result).to match(%r{group.*RW})
    expect(result).to match(%r{acl.*GREEN})
  end

  it 'remove the SNMP Community' do
    pp = <<-EOS
snmp_community { 'ACCEPTANCE':
  ensure => 'absent'
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotentç
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('snmp_community', 'ACCEPTANCE')
    expect(result).to match(%r{ensure.*absent})
  end
end

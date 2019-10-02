require 'spec_helper_acceptance'

describe 'snmp_notification_receiver' do
  it 'add a basic SNMP Notification Receiver' do
    pp = <<-EOS
    snmp_notification_receiver { '9.9.9.9 public 1234':
      username => 'public',
      port => 1234,
      type => 'traps',
      ensure => 'present',
    }
    snmp_notification_receiver { '9.9.9.9 public 5555':
      username => 'public',
      port => 5555,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_notification_receiver', '"9.9.9.9 public 1234"')
    expect(result).to match(%r{port.*1234})
    expect(result).to match(%r{ensure.*present})

    result = run_resource('snmp_notification_receiver', '"9.9.9.9 public 5555"')
    expect(result).to match(%r{port.*5555})
    expect(result).to match(%r{ensure.*present})
  end

  it 'add a vrf SNMP Notification Receiver' do
    skip "Test skip as #{device_model} does not support vrf" if ['2960', '4503'].include?(device_model)
    pp = <<-EOS
    snmp_notification_receiver { '8.8.8.8 public Test-Vrf 1235':
      username => 'public',
      vrf => 'Test-Vrf',
      port => 1235,
      type => 'traps',
      ensure => 'present',
    }
    snmp_notification_receiver { '8.8.8.8 public Test-Vrf 6666':
      username => 'public',
      vrf => 'Test-Vrf',
      port => 6666,
      ensure => 'present',
    }
  EOS

    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result_vrf = run_resource('snmp_notification_receiver', '"8.8.8.8 public Test-Vrf 1235"')
    expect(result_vrf).to match(%r{port.*1235})
    expect(result_vrf).to match(%r{ensure.*present})
    expect(result_vrf).to match(%r{vrf.*Test-Vrf})

    result_vrf = run_resource('snmp_notification_receiver', '"8.8.8.8 public Test-Vrf 6666"')
    expect(result_vrf).to match(%r{port.*6666})
    expect(result_vrf).to match(%r{ensure.*present})
    expect(result_vrf).to match(%r{vrf.*Test-Vrf})
  end

  it 'remove an existing SNMP Notification Receiver' do
    pp = <<-EOS
    snmp_notification_receiver { '9.9.9.9 public 1234':
      username => 'public',
      port => 1234,
      ensure => 'absent',
    }
    snmp_notification_receiver { '9.9.9.9 public 5555':
      username => 'public',
      port => 5555,
      ensure => 'absent',
    }
    EOS

    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_notification_receiver', '"9.9.9.9 public 1234"')
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('snmp_notification_receiver', '"9.9.9.9 public 5555"')
    expect(result).to match(%r{ensure.*absent})
  end

  it 'remove an existing vrf SNMP Notification receiver' do
    skip "Test skip as #{device_model} does not support vrf" if ['2960', '4503'].include?(device_model)
    pp = <<-EOS
    snmp_notification_receiver { '8.8.8.8 public Test-Vrf 1235':
      username => 'public',
      vrf => 'Test-Vrf',
      port => 1235,
      type => 'traps',
      ensure => 'absent',
    }
    snmp_notification_receiver { '8.8.8.8 public Test-Vrf 6666':
      username => 'public',
      vrf => 'Test-Vrf',
      port => 6666,
      ensure => 'absent',
    }
    EOS

    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result_vrf = run_resource('snmp_notification_receiver', '"8.8.8.8 public Test-Vrf 1235"')
    expect(result_vrf).to match(%r{ensure.*absent})
    result_vrf = run_resource('snmp_notification_receiver', '"8.8.8.8 public Test-Vrf 6666"')
    expect(result_vrf).to match(%r{ensure.*absent})
  end
end

require 'spec_helper_acceptance'

describe 'snmp_notification_receiver' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
snmp_notification_receiver { '9.9.9.9 public 1234':
  host => '9.9.9.9',
  username => 'public',
  port => 1234,
  ensure => 'absent',
}

snmp_notification_receiver { '9.9.9.9 public 5555':
  host => '9.9.9.9',
  username => 'public',
  port => 5555,
  ensure => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    run_device(options = { allow_changes: false })
  end

  it 'add a basic SNMP Notification Receiver' do
    pp = <<-EOS
snmp_notification_receiver { '9.9.9.9 public 1234':
  host => '9.9.9.9',
  username => 'public',
  port => 1234,
  ensure => 'present',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('snmp_notification_receiver', '"9.9.9.9 public 1234"')
    expect(result).to match(%r{host.*9.9.9.9})
    expect(result).to match(%r{username.*public})
    expect(result).to match(%r{port.*1234})
    expect(result).to match(%r{ensure.*present})
  end

  it 'edit an existing SNMP Notification Receiver' do
    pp = <<-EOS
snmp_notification_receiver { '9.9.9.9 public 1234':
  host => '9.9.9.9',
  username => 'public',
  port => 5555,
  ensure => 'present',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check that the original receiver is removed
    result_remove = run_resource('snmp_notification_receiver', '"9.9.9.9 public 1234"')
    expect(result_remove).to match(%r{ensure.*absent})
    # check that the new receiver is added
    result = run_resource('snmp_notification_receiver', '"9.9.9.9 public 5555"')
    expect(result).to match(%r{host.*9.9.9.9})
    expect(result).to match(%r{username.*public})
    expect(result).to match(%r{port.*5555})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove an existing SNMP Notification Receiver' do
    pp = <<-EOS
snmp_notification_receiver { '9.9.9.9 public 1234':
  host => '9.9.9.9',
  username => 'public',
  port => 1234,
  ensure => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('snmp_notification_receiver', '"9.9.9.9 public 1234"')
    expect(result).to match(%r{ensure.*absent})
  end
end

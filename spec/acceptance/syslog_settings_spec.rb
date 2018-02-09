require 'spec_helper_acceptance'

describe 'should change syslog_settings' do
  before(:all) do
    # set to known values
    pp = <<-EOS
  syslog_settings { 'default':
    monitor => 7,
    console => 7,
    source_interface => "Loopback42",
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'edit a syslog_settings' do
    pp = <<-EOS
  syslog_settings { 'default':
    monitor => 6,
    console => 6,
    source_interface => "Loopback24",
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('syslog_settings', 'default')
    expect(result).to match(%r{monitor.*6})
    expect(result).to match(%r{console.*6})
    expect(result).to match(%r{source_interface.*Loopback24})
  end

  it 'set back to normal' do
    # set to known values
    pp = <<-EOS
  syslog_settings { 'default':
    monitor => 7,
    console => 7,
    source_interface => "Loopback42",
  }
  EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end
end

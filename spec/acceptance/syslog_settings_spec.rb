require 'spec_helper_acceptance'

describe 'syslog_settings' do
  it 'disable syslog_settings' do
    pp = <<-EOS
    syslog_settings { 'default':
      enable => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('syslog_settings', 'default')
    expect(result).to match(%r{enable => false})
  end

  it 'enable syslog_settings' do
    pp = <<-EOS
    syslog_settings { 'default':
      enable => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('syslog_settings', 'default')
    expect(result).to match(%r{enable => true})
  end

  it 'edit syslog_settings' do
    pp = <<-EOS
    syslog_settings { 'default':
      enable => true,
      monitor => 4,
      console => 4,
      source_interface => ["Loopback24"],
      buffered_size => 5000,
      buffered_severity_level => 4,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('syslog_settings', 'default')
    expect(result).to match(%r{enable => true})
    expect(result).to match(%r{monitor => 4})
    expect(result).to match(%r{console => 4})
    expect(result).to match(%r{source_interface => \['Loopback24'\]})
    expect(result).to match(%r{buffered_size => 5000})
    expect(result).to match(%r{buffered_severity_level => 4})
  end

  it 'set back to normal' do
    # set to known values
    pp = <<-EOS
    syslog_settings { 'default':
      enable => true,
      monitor => 6,
      console => 6,
      source_interface => ["Loopback42"],
      buffered_size => 'unset',
      buffered_severity_level => 'unset',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('syslog_settings', 'default')
    expect(result).to match(%r{enable => true})
    expect(result).to match(%r{monitor => 6})
    expect(result).to match(%r{console => 6})
    expect(result).to match(%r{source_interface => \['Loopback42'\]})
    expect(result).not_to match(%r{buffered_size =>})
    expect(result).not_to match(%r{buffered_severity_level =>})
  end
end

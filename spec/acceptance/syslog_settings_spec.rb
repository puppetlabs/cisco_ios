require 'spec_helper_acceptance'

describe 'syslog_settings' do
  before(:all) do
    # set to known values
    pp = <<-EOS
    syslog_settings { 'default':
      enable => true,
      monitor => 7,
      console => 7,
      source_interface => ["Loopback42"],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'edit syslog_settings' do
    pp = <<-EOS
    syslog_settings { 'default':
      enable => false,
      monitor => 6,
      console => 6,
      source_interface => ["Loopback24"],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('syslog_settings', 'default')
    expect(result).to match(%r{enable.*false})
    expect(result).to match(%r{monitor.*6})
    expect(result).to match(%r{console.*6})
    expect(result).to match(%r{source_interface.*Loopback24})
  end

  it 'set back to normal' do
    # set to known values
    pp = <<-EOS
    syslog_settings { 'default':
      enable => true,
      monitor => 7,
      console => 7,
      source_interface => ["Loopback42"],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end
end

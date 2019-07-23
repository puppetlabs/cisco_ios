require 'spec_helper_acceptance'

describe 'ios_additional_syslog_settings' do
  before(:all) do
    # set to known values
    pp = <<-EOS
    ios_additional_syslog_settings { 'default':
      trap => 'unset',
      origin_id => 'unset',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'edit ios_additional_syslog_settings' do
    pp = <<-EOS
    ios_additional_syslog_settings { 'default':
      trap => 3,
      origin_id => 'ipv6',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_additional_syslog_settings', 'default')
    expect(result).to match(%r{trap => 3})
    expect(result).to match(%r{origin_id => 'ipv6'})
  end

  it 'edit ios_additional_syslog_settings again' do
    pp = <<-EOS
    ios_additional_syslog_settings { 'default':
      trap => 5,
      origin_id => ['string', 'thecakeisalie'],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_additional_syslog_settings', 'default')
    expect(result).to match(%r{trap => 5})
    expect(result).to match(%r{origin_id => \['string', 'thecakeisalie'\]})
  end

  it 'set back to normal' do
    # set to known values
    pp = <<-EOS
    ios_additional_syslog_settings { 'default':
      trap => 'unset',
      origin_id => 'unset',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    result = run_resource('ios_additional_syslog_settings', 'default')
    expect(result).not_to match(%r{trap =>})
    expect(result).not_to match(%r{origin_id =>})
  end
end

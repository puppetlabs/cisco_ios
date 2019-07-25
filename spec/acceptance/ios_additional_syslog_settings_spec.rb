require 'spec_helper_acceptance'

describe 'ios_additional_syslog_settings' do
  it 'edit ios_additional_syslog_settings' do
    origin_id = ['4948'].include?(device_model) ? '' : "origin_id => 'ipv6',"
    pp = <<-EOS
    ios_additional_syslog_settings { 'default':
      trap => 3,
      #{origin_id}
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_additional_syslog_settings', 'default')
    expect(result).to match(%r{trap => 3})
    expect(result).to match(%r{origin_id => 'ipv6'}) unless ['4948'].include?(device_model)
  end

  it 'edit ios_additional_syslog_settings again' do
    origin_id = ['4948'].include?(device_model) ? '' : "origin_id => ['string', 'thecakeisalie'],"
    pp = <<-EOS
    ios_additional_syslog_settings { 'default':
      trap => 5,
      #{origin_id}
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_additional_syslog_settings', 'default')
    expect(result).to match(%r{trap => 5})
    expect(result).to match(%r{origin_id => \['string', 'thecakeisalie'\]}) unless ['4948'].include?(device_model)
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

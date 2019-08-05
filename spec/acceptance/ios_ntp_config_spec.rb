require 'spec_helper_acceptance'

describe 'ios_ntp_config' do
  it 'add ios_ntp_config update-calendar' do
    pp = <<-EOS
    ios_ntp_config { 'default':
      update_calendar => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_config', 'default')
    expect(result).to match(%r{update_calendar.*true})
  end

  it 'unset ios_ntp_config update-calendar' do
    pp = <<-EOS
    ios_ntp_config { 'default':
      update_calendar => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_ntp_config', 'default')
    expect(result).to match(%r{update_calendar.*false})
  end
end

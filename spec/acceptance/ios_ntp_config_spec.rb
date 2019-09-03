require 'spec_helper_acceptance'

describe 'ios_ntp_config' do
  before(:all) do
    skip "this device #{device_model} does not support update_calendar" if ['2960', '3650', '3750'].include?(device_model)
  end

  it 'add ios_ntp_config update-calendar' do
    pp = <<-EOS
    ios_ntp_config { 'default':
      authenticate => true,
      source_interface => 'Vlan42',
      trusted_key => [12,24,48,96],
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
    expect(result).to match(%r{authenticate.*true})
    expect(result).to match(%r{source.*Vlan42})
    expect(result).to match(%r{trusted_key.*12.*24.*48.*96})
  end

  it 'unset ios_ntp_config update-calendar' do
    pp = <<-EOS
    ios_ntp_config { 'default':
      authenticate => false,
      source_interface => unset,
      trusted_key => [],
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
    expect(result).to match(%r{authenticate.*false})
    expect(result).to match(%r{source_interface.*unset})
    expect(result).to match(%r{trusted_key.*\[\]})
  end
end

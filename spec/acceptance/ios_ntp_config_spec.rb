require 'spec_helper_acceptance'

describe 'ios_ntp_config' do
  it 'set ios_ntp_config attributes' do
    update_calendar = ['2960', '3650', '3750'].include?(device_model) ? '' : 'update_calendar => true,'
    pp = <<-EOS
    ios_ntp_config { 'default':
      authenticate => true,
      source_interface => 'Vlan42',
      trusted_key => [12,24,48,96],
      #{update_calendar}
      logging => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_ntp_config', 'default')
    expect(result).to match(%r{authenticate => true})
    expect(result).to match(%r{source_interface => 'Vlan42'})
    expect(result).to match(%r{trusted_key => \[12, 24, 48, 96\]})
    expect(result).to match(%r{update_calendar => true}) unless update_calendar == ''
    expect(result).to match(%r{logging => true})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'unset ios_ntp_config attributes' do
    update_calendar = ['2960', '3650', '3750'].include?(device_model) ? '' : 'update_calendar => false,'
    pp = <<-EOS
    ios_ntp_config { 'default':
      authenticate => false,
      source_interface => 'unset',
      trusted_key => [],
      #{update_calendar}
      logging => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_ntp_config', 'default')
    expect(result).to match(%r{authenticate => false})
    expect(result).to match(%r{source_interface => 'unset'})
    expect(result).to match(%r{trusted_key => \[\]})
    expect(result).to match(%r{update_calendar => false}) unless update_calendar == ''
    expect(result).to match(%r{logging => false})
    # Are we idempotent
    run_device(allow_changes: false)
  end
end

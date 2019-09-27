require 'spec_helper_acceptance'
describe 'vrf:' do
  before(:all) do
    skip "This device #{device_model} does not support the setting of a VRF" if ['2960', '4503'].include?(device_model)
  end

  it 'create a vrf' do
    rd = ['3650', '6503'].include?(device_model) ? '' : "route_targets => [['export', '10.0.0.0:102']],"
    pp = <<-EOS
      vrf{"test":
        route_distinguisher => '10.10.10.10:101',
        import_map => 'map',
        ensure => 'present',
        #{rd}
      }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_warnings: true)
    # Check puppet resource
    result = run_resource('vrf', 'test')
    expect(result).to match(%r{route_distinguisher.*10.10.10.10:101})
    expect(result).to match(%r{route_targets.*\[\n.*\['export', '10.0.0.0:102'\]\]}) if rd != ''
    expect(result).to match(%r{import_map.*map})
    expect(result).to match(%r{ensure.*present})
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
  end

  it 'modify a vrf' do
    rd = ['3650', '6503'].include?(device_model) ? '' : "route_targets => [['export', '10.0.0.0:102']],"
    pp = <<-EOS
      vrf{"test":
        import_map => 'import',
        route_distinguisher => '11.1.1.1:111',
        ensure => 'present',
        #{rd}
      }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_warnings: true)
    # Check puppet resource
    result = run_resource('vrf', 'test')
    expect(result).to match(%r{route_distinguisher.*11.1.1.1:111})
    expect(result).to match(%r{route_targets.*\[\n.*\['export', '11.1.1.1:112'\]\]}) if rd != ''
    expect(result).to match(%r{import_map.*import})
    expect(result).to match(%r{ensure.*present})
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
  end

  it 'delete a vrf' do
    pp = <<-EOS
      vrf{"test":
        route_distinguisher => '11.1.1.1:111',
        import_map => 'import',
        route_targets => [['import', '11.1.1.1:112']],
        ensure => 'absent'
      }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_warnings: true)
    # Check puppet resource
    result = run_resource('vrf', 'test')
    expect(result).to match(%r{ensure.*absent})
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
  end
end

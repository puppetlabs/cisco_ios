require 'spec_helper_acceptance'
describe 'vrf' do
  it 'create a vrf' do
    pp = <<-EOS
    vrf{"test":
    route_distinguisher => '10.0.0.0:101',
    import_map => 'map',
    route_targets => [['export', '10.0.0.0:102']],
    ensure => 'present'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_warnings: true)
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
    # Check puppet resource
    result = run_resource('vrf', 'test')
    expect(result).to match(%r{route_distinguisher.*10.0.0.0:101})
    expect(result).to match(%r{route_targets.*\[\n.*\['export', '10.0.0.0:102'\]\]})
    expect(result).to match(%r{import_map.*map})
    expect(result).to match(%r{ensure.*present})
  end

  it 'modify a vrf' do
    pp = <<-EOS
    vrf{"test":
    route_distinguisher => '11.1.1.1:111',
    import_map => 'import',
    route_targets => [['import', '11.1.1.1:112']],
    ensure => 'present'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_warnings: true)
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
    # Check puppet resource
    result = run_resource('vrf', 'test')
    expect(result).to match(%r{route_distinguisher.*11.1.1.1:111})
    expect(result).to match(%r{route_targets.*\[\n.*\['import', '11.1.1.1:112'\]\]})
    expect(result).to match(%r{import_map.*import})
    expect(result).to match(%r{ensure.*present})
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
    # Are we idempotent
    run_device(allow_changes: false, allow_warnings: true)
    # Check puppet resource
    result = run_resource('vrf', 'test')
    expect(result).to match(%r{ensure.*absent})
  end
end

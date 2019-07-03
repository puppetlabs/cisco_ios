require 'spec_helper_acceptance'

describe 'ios_stp_global' do
  it 'add ios_stp_global' do
    pp = <<-EOS
    ios_stp_global { "default":
      loopguard => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_stp_global', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{loopguard.*true})
  end

  it 'edit ios_stp_global' do
    # non-destructive STP config changes that will not affect following tests
    pp = <<-EOS
    ios_stp_global { 'default':
      extend_system_id => true,
      loopguard => true,
      mst_forward_time => 13,
      mst_hello_time => 4,
      mst_max_age => 19,
      mst_max_hops => 40,
      mst_name => 'potato',
      mst_revision => 42,
      pathcost => 'long',
      portfast => ['default', 'bpdufilter_default'],
      uplinkfast => true,
      uplinkfast_max_update_rate => 42,
    }
    EOS
    make_site_pp(pp)
    # Allow warning which is not an error
    # 'Warning: this command enables portfast by default on all interfaces.'
    run_device(allow_changes: true, allow_warnings: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_stp_global', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{loopguard.*true})
    if result =~ %r{mst_forward_time}
      expect(result).to match(%r{mst_forward_time.*13})
    end
    if result =~ %r{mst_hello_time}
      expect(result).to match(%r{mst_hello_time.*4})
    end
    if result =~ %r{mst_max_age}
      expect(result).to match(%r{mst_max_age.*19})
    end
    if result =~ %r{mst_max_hops}
      expect(result).to match(%r{mst_max_hops.*40})
    end
    expect(result).to match(%r{extend_system_id.*true})
    expect(result).to match(%r{mst_name.*potato})
    expect(result).to match(%r{mst_revision.*42})
    expect(result).to match(%r{pathcost.*long})
    expect(result).to match(%r{portfast.*bpdufilter_default})
    expect(result).to match(%r{portfast.*[^_]default})
    expect(result).to match(%r{uplinkfast.*true})
    expect(result).to match(%r{uplinkfast_max_update_rate.*42})
  end

  it 'disable ios_stp_global' do
    pp = <<-EOS
    ios_stp_global { "default":
      enable => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_stp_global', 'default')
    expect(result).to match(%r{default.*})
    # Default values
    expect(result).to match(%r{loopguard.*false})
    expect(result).to match(%r{mode.*pvst})
  end
end

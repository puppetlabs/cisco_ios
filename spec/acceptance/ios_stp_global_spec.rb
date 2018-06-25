require 'spec_helper_acceptance'

describe 'ios_stp_global' do
  before(:all) do
    # Set to known values
    pp = <<-EOS
    ios_stp_global { "default":
      enable => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

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
      bridge_assurance => true,
      loopguard => true,
      mst_forward_time => 13,
      mst_hello_time => 4,
      mst_max_age => 19,
      mst_max_hops => 40,
      mst_name => 'potato',
      mst_revision => 42,
      pathcost => 'long',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_stp_global', 'default')
    expect(result).to match(%r{default.*})
    if result =~ %r{bridge_assurance}
      expect(result).to match(%r{bridge_assurance.*true})
    end
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
    expect(result).to match(%r{mst_name.*potato})
    expect(result).to match(%r{mst_revision.*42})
    expect(result).to match(%r{pathcost.*long})
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

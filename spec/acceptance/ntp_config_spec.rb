require 'spec_helper_acceptance'

describe 'ntp_config' do
  before(:all) do
    # Remove if already present, add test Vlan
    pp = <<-EOS
    ntp_config { 'default':
      authenticate => false,
      source_interface => 'unset',
      trusted_key => [],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'add ntp_config single key' do
    pp = <<-EOS
    ntp_config { 'default':
      authenticate => true,
      source_interface => 'Vlan42',
      trusted_key => [12],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_config', 'default')
    expect(result).to match(%r{authenticate.*true})
    expect(result).to match(%r{source.*Vlan42})
    expect(result).to match(%r{trusted_key.*12})
  end

  it 'edit ntp_config multiple keys' do
    pp = <<-EOS
    ntp_config { 'default':
      authenticate => true,
      source_interface => 'Vlan42',
      trusted_key => [12,24,48,96],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_config', 'default')
    expect(result).to match(%r{authenticate.*true})
    expect(result).to match(%r{source.*Vlan42})
    expect(result).to match(%r{trusted_key.*12.*24.*48.*96})
  end

  it 'edit ntp_config' do
    pp = <<-EOS
    ntp_config { 'default':
      authenticate => true,
      source_interface => 'Vlan43',
      trusted_key => [48,96,128],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_config', 'default')
    expect(result).to match(%r{authenticate.*true})
    expect(result).to match(%r{source.*Vlan43})
    expect(result).to match(%r{trusted_key.*48.*96.*128})
  end
  it 'unset ntp_config' do
    pp = <<-EOS
    ntp_config { 'default':
      authenticate => false,
      source_interface => 'unset',
      trusted_key => [],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_config', 'default')
    expect(result).to match(%r{authenticate.*false})
  end
end

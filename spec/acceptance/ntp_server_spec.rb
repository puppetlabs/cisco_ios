require 'spec_helper_acceptance'
require 'yaml'

describe 'ntp_server' do
  it 'add an ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      key    => 42,
      ensure => 'present',
      source_interface => 'Vlan42',
    }
    ntp_server { '1.2.3.5':
      key    => 42,
      ensure => 'present',
      vrf    => 'Mgmt-vrf',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(%r{key.*42})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{source_interface.*Vlan42})
    result_vrf = run_resource('ntp_server', '1.2.3.5')
    expect(result_vrf).to match(%r{key.*42})
    expect(result_vrf).to match(%r{ensure.*present})
    expect(result_vrf).to match(%r{vrf.*Mgmt-vrf})
  end

  it 'edit an existing ntp_server' do
    #  min and max poll are only supported on some devices
    minpoll = ['3750', '4507', '4948'].include?(device_model) ? '' : 'minpoll => 4,'
    maxpoll = ['3750', '4507', '4948'].include?(device_model) ? '' : 'maxpoll => 14,'
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'present',
      key => 94,
      prefer => true,
      #{minpoll}
      #{maxpoll}
      source_interface => 'Vlan42',
    }
    ntp_server { '1.2.3.5':
      key    => 49,
      ensure => 'present',
      vrf    => 'Mgmt-vrf',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(%r{key.*94})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{source_interface.*Vlan42})
    expect(result).to match(%r{minpoll.*4}) if result =~ %r{minpoll =>}
    expect(result).to match(%r{maxpoll.*14}) if result =~ %r{maxpoll =>}

    result_vrf = run_resource('ntp_server', '1.2.3.5')
    expect(result_vrf).to match(%r{key.*49})
    expect(result_vrf).to match(%r{ensure.*present})
    expect(result_vrf).to match(%r{vrf.*Mgmt-vrf})
  end
  it 'remove an existing ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'absent',
    }
    ntp_server { '1.2.3.5':
    ensure => 'absent',
    vrf    => 'Mgmt-vrf',
  }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(%r{ensure.*absent})
    result_vrf = run_resource('ntp_server', '1.2.3.5')
    expect(result_vrf).to match(%r{ensure.*absent})
  end
end

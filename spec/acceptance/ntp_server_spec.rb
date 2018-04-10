require 'spec_helper_acceptance'

describe 'ntp_server' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add an ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      key    => '42',
      ensure => 'present',
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
  end

  it 'edit an existing ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'present',
      key => 94,
      prefer => true,
      minpoll => 4,
      maxpoll => 14,
      source_interface => 'Vlan 42',
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
    expect(result).to match(%r{prefer.*true})
    expect(result).to match(%r{minpoll.*4})
    expect(result).to match(%r{maxpoll.*14})
    expect(result).to match(%r{source_interface.*Vlan42})
  end
  it 'remove an existing ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(%r{ensure.*absent})
  end
end

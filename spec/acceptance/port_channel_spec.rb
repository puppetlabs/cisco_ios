require 'spec_helper_acceptance'

describe 'port_channel' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    port_channel { 'Port-channel6':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'add port channel' do
    pp = <<-EOS
    port_channel { "Port-channel6":
      description => 'This is a test port channel',
      speed => '10m',
      duplex => 'full',
      flowcontrol_receive => 'on',
      flowcontrol_send => 'on',
      ensure => 'present',
      mode => 'passive',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('port_channel', 'Port-channel6')
    expect(result).to match(%r{Port-channel6.*})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{description.*This is a test port channel})
    expect(result).to match(%r{duplex.*full})
    expect(result).to match(%r{flowcontrol_receive.*on}) if result =~ %r{flowcontrol_receive =>}
    expect(result).to match(%r{flowcontrol_send.*on}) if result =~ %r{flowcontrol_send =>}
    expect(result).to match(%r{speed.*10}) if result =~ %r{speed =>}
    expect(result).to match(%r{mode.*passive}) if result =~ %r{mode =>}
  end

  it 'remove port channel' do
    pp = <<-EOS
    port_channel { 'Port-channel6':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('port_channel', 'Port-channel6')
    expect(result).to match(%r{Port-channel6.*})
    expect(result).to match(%r{ensure.*absent})
  end
end

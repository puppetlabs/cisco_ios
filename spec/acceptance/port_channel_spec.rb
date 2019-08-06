require 'spec_helper_acceptance'

describe 'port_channel' do
  it 'add port channel' do
    # flowcontrol send is not available on these devices
    flowcontrol_send = ['4948', '4507', '4503', '3750', '3650', '3560', '2960'].include?(device_model) ? '' : "flowcontrol_send => 'on',"
    # speed on these devices has only 1 setting
    # so it can be configured but not retrieved
    # for this reason we'll not be managing it in
    # the test
    speed = (device_model == '4507') ? '' : "speed => '10m',"
    pp = <<-EOS
    port_channel { "Port-channel6":
      description => 'This is a test port channel',
      #{speed}
      duplex => 'full',
      flowcontrol_receive => 'on',
      #{flowcontrol_send}
      ensure => 'present',
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
    expect(result).to match(%r{speed.*10m}) if result =~ %r{speed =>}
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

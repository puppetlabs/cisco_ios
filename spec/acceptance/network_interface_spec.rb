require 'spec_helper_acceptance'

describe 'network_interface' do
  it 'edit an existing interface' do
    # mtu is not supported on the following devices
    mtu = ['2960', '3650', '3750'].include?(device_model) ? '' : 'mtu => 1501,'
    pp = <<-EOS
    network_interface { 'Vlan42':
      enable => true,
      description => 'This is a test interface.',
      #{mtu}
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_interface', 'Vlan42')
    expect(result).to match(%r{Vlan42.*})
    expect(result).to match(%r{description.*This is a test interface})
    if result =~ %r{mtu =>.*}
      expect(result).to match(%r{mtu.*1501})
    end
  end
end

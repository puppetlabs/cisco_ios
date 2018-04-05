require 'spec_helper_acceptance'

describe 'network_interface' do
  before(:all) do
    # set to a known configuration
    pp = <<-EOS
    network_interface { 'Vlan42':
      enable => false,
      description => 'description',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'edit an existing interface' do
    pp = <<-EOS
    network_interface { 'Vlan42':
      enable => true,
      description => 'This is a test interface.',
      mtu => 128,
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
    # MTU present on 6509 device
    if device_model =~ %r{6509}
      expect(result).to match(%r{mtu.* => 128,})
    end
  end
end

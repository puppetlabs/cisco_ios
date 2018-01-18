require 'spec_helper_acceptance'

describe 'should change an interface_old' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
  network_interface_old { 'Vlan42':
    enable => 'false',
  }
  network_interface_old { 'GigabitEthernet3/42':
    enable => 'false',
  }
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    run_device(options = { allow_changes: false })
  end

  it 'add an interface' do
    pp = <<-EOS
network_interface_old { 'Vlan42':
  enable => 'true',
}
network_interface_old { 'GigabitEthernet3/42':
  enable => 'true',
}
  EOS

    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('network_interface_old', 'Vlan42')
    expect(result).to match(%r{Vlan42.*})
    result = run_resource('network_interface_old', 'GigabitEthernet3/42')
    expect(result).to match(%r{GigabitEthernet3/42.*})
  end

  it 'edit an existing interface' do
    pp = <<-EOS
network_interface_old { 'Vlan42':
  enable => 'true',
  description => 'This is a test interface.',
  mtu => 128,
}
network_interface_old { 'GigabitEthernet3/42':
  enable => 'true',
  description => 'This is another test interface.',
  speed => '100m',
  duplex => 'half',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('network_interface_old', 'Vlan42')
    expect(result).to match(%r{Vlan42.*})
    expect(result).to match(%r{description.* => 'This is a test interface.',})
    expect(result).to match(%r{mtu.* => '128',})
    result = run_resource('network_interface_old', 'GigabitEthernet3/42')
    expect(result).to match(%r{GigabitEthernet3/42.*})
    expect(result).to match(%r{description.* => 'This is another test interface.',})
    expect(result).to match(%r{speed.* => '100m',})
    expect(result).to match(%r{duplex.* => 'half',})
  end
  it 'remove an existing interface' do
    pp = <<-EOS
network_interface_old { 'Vlan42':
  enable => 'false',
}
network_interface_old { 'GigabitEthernet3/42':
  enable => 'false',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('network_interface_old', 'Vlan42')
    expect(result).to match(%r{Vlan42.*})
    result = run_resource('network_interface_old', 'GigabitEthernet3/42')
    expect(result).to match(%r{GigabitEthernet3/42.*})
  end
end

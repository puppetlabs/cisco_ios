require 'spec_helper_acceptance'

describe 'should change an interface' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
  network_interface { 'Vlan42':
    enable => 'false',
  }
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    run_device(options = { allow_changes: false })
  end

  it 'add an interface' do
    pp = <<-EOS
network_interface { 'Vlan42':
  enable => 'true',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('network_interface', 'Vlan42')
    expect(result).to match(%r{Vlan42.*})
  end

  it 'edit an existing interface' do
    pp = <<-EOS
network_interface { 'Vlan42':
  enable => 'true',
  description => 'This is a test interface.',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('network_interface', 'Vlan42')
    expect(result).to match(%r{Vlan42.*})
    expect(result).to match(%r{description.* => 'This is a test interface.',})
  end
  it 'remove an existing interface' do
    pp = <<-EOS
network_interface { 'Vlan42':
  enable => 'false',
}
    EOS
    make_site_pp(pp)
    run_device(options = { allow_changes: true })
    # Are we idempotent
    run_device(options = { allow_changes: false })
    # Check puppet resource
    result = run_resource('network_interface', 'Vlan42')
    expect(result).to match(%r{Vlan42.*})
  end
end

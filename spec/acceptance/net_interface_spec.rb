require 'spec_helper_acceptance'

describe 'should change an interface' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
  net_interface { 'Vlan42':
    ensure => 'absent',
  }
    EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
  end

  it 'add an interface' do
    pp = <<-EOS
net_interface { 'Vlan42':
  ensure => 'present',
}
    EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    # Are we idempotent
    run_device(options={:allow_changes => false})
    # Check puppet resource
    result = run_resource('net_interface', 'Vlan42')
    expect(result).to match(/ensure.* => 'present',/)
  end

  it 'edit an existing interface' do
    pp = <<-EOS
net_interface { 'Vlan42':
  ensure => 'present',
  description => 'This is a test interface.',
}
    EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    # Are we idempotent
    run_device(options={:allow_changes => false})
    # Check puppet resource
    result = run_resource('net_interface', 'Vlan42')
    expect(result).to match(/ensure.* => 'present',/)
    expect(result).to match(/description.* => 'This is a test interface.',/)
  end
  it 'remove an existing interface' do
    pp = <<-EOS
net_interface { 'Vlan42':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    # Are we idempotent
    run_device(options={:allow_changes => false})
    # Check puppet resource
    result = run_resource('net_interface', 'Vlan42')
    expect(result).to match(/ensure.* => 'absent',/)
  end
end

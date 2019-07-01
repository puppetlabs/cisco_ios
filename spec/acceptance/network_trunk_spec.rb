require 'spec_helper_acceptance'

describe 'network_trunk' do
  it 'add a network trunk' do
    pp = <<-EOS
    network_trunk { 'Port-channel1':
      ensure => 'present',
      mode => 'access',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_trunk', 'Port-channel1')
    expect(result).to match(%r{Port-channel1.*})
    expect(result).to match(%r{mode.*access})
    expect(result).to match(%r{ensure.*present})
  end

  it 'edit an existing trunk' do
    pp = <<-EOS
    network_trunk { 'Port-channel1':
      ensure => 'present',
      encapsulation => 'dot1q',
      mode => 'dynamic_desirable',
      untagged_vlan => 42,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_trunk', 'Port-channel1')
    expect(result).to match(%r{Port-channel1.*})
    # Not set/read on a 2960
    expect(result).to match(%r{encapsulation.*dot1q}) if result =~ %r{encapsulation =>}
    expect(result).to match(%r{mode.*dynamic_desirable})
    expect(result).to match(%r{untagged_vlan.*42})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove an existing interface' do
    # NOTE That this will fail on a 2960
    # as switchport is always on
    pp = <<-EOS
    network_trunk { 'Port-channel1':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('network_trunk', 'Port-channel1')
    expect(result).to match(%r{Port-channel1.*})
    # Cannot currently test
    # expect(result).to match(%r{ensure.*absent})
  end
end

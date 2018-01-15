require 'spec_helper_acceptance'

describe 'should change an ntp_server' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
ntp_server { '1.2.3.4':
  ensure => 'absent',
}
  EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    run_device(options={:allow_changes => false})
  end

  it 'add an ntp_server' do
    pp = <<-EOS
ntp_server { '1.2.3.4':
  key    => '42',
  ensure => 'present',
}
EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    # Are we idempotent
    run_device(options={:allow_changes => false})
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(/key.* => '42',/)
    expect(result).to match(/ensure.* => 'present',/)
  end

  it 'edit an existing ntp_server' do
    pp = <<-EOS
ntp_server { '1.2.3.4':
  ensure => 'present',
  key => 94,
  prefer => true,
  minpoll => 4,
  maxpoll => 14,
  source_interface => 'Vlan 1',
}
EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    # Are we idempotent
    run_device(options={:allow_changes => false})
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(/key.* => '94',/)
    expect(result).to match(/ensure.* => 'present',/)
    expect(result).to match(/prefer.* => true,/)
    expect(result).to match(/minpoll.* => '4',/)
    expect(result).to match(/maxpoll.* => '14',/)
    expect(result).to match(/source_interface.* => 'Vlan1',/)
  end
  it 'remove an existing ntp_server' do
    pp = <<-EOS
ntp_server { '1.2.3.4':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    # Are we idempotent
    run_device(options={:allow_changes => false})
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(/ensure.* => 'absent',/)
  end
end

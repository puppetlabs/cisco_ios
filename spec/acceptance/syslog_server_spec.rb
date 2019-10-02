require 'spec_helper_acceptance'

describe 'syslog_server' do
  it 'add a syslog_server' do
    pp = <<-EOS
      syslog_server { '1.2.3.4':
        ensure => 'present',
      }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('syslog_server', '1.2.3.4')
    expect(result).to match(%r{ensure => 'present'})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'add a vrf to the server' do
    vrf = ['2960', '4503'].include?(device_model) ? '' : "vrf => 'Test-Vrf',"
    pp = <<-EOS
      syslog_server { '1.2.3.4':
        ensure => 'present',
        #{vrf}
      }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    result = run_resource('syslog_server', '1.2.3.4')
    expect(result).to match(%r{ensure => 'present'})
    expect(result).to match(%r{vrf => 'Test-Vrf'}) unless ['2960', '4503'].include?(device_model)
    run_device(allow_changes: false)
    # Check puppet resource
  end

  it 'remove an existing syslog_server' do
    pp = <<-EOS
      syslog_server { '1.2.3.4':
        ensure => 'absent',
      }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('syslog_server', '1.2.3.4')
    expect(result).to match(%r{ensure => 'absent'})
    # Are we idempotent
    run_device(allow_changes: false)
  end
end

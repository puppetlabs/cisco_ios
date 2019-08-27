require 'spec_helper_acceptance'

describe 'ios_radius_server_group' do
  it 'add ios_radius_server_group' do
    pp = <<-EOS
    ios_radius_server_group { "ted":
      ensure => 'present',
      servers => ['1.2.3.4'],
      private_servers => ['5.6.7.8'],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_radius_server_group', 'ted')
    expect(result).to match(%r{ensure => 'present'})
    expect(result).to match(%r{servers => \['1.2.3.4'\]})
    expect(result).to match(%r{private_servers => \['5.6.7.8'\]})
  end

  it 'update ios_radius_server_group' do
    pp = <<-EOS
    ios_radius_server_group { "ted":
      ensure => 'present',
      servers => ['8.7.6.5', '4.3.2.1'],
      private_servers => ['1.2.3.4', '5.6.7.8'],
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_radius_server_group', 'ted')
    expect(result).to match(%r{ensure => 'present'})
    expect(result).to match(%r{servers => \['4.3.2.1', '8.7.6.5'\]})
    expect(result).to match(%r{private_servers => \['1.2.3.4', '5.6.7.8'\]})
  end

  it 'remove ios_radius_server_group' do
    pp = <<-EOS
    ios_radius_server_group { "ted":
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_radius_server_group', 'ted')
    expect(result).to match(%r{ensure => 'absent'})
    expect(result).not_to match(%r{servers =>})
    expect(result).not_to match(%r{private_servers =>})
  end
end

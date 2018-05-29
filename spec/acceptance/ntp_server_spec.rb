require 'spec_helper_acceptance'

describe 'ntp_server' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'add an ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      key    => 42,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(%r{key.*42})
    expect(result).to match(%r{ensure.*present})
  end

  it 'edit an existing ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'present',
      key => 94,
      prefer => true,
      minpoll => 4,
      maxpoll => 14,
      source_interface => 'Vlan 42',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    # As documented in readme, it is possible that an ntp_server with a different source_interface
    # may create a new entry. As resource gets all entries, and this seems to be Cisco functionality,
    # iterate over entries until appropriate entry is found, check assertions.
    results = YAML.safe_load(run_resource('ntp_server --to_yaml'))
    found_edited = false
    results['ntp_server'].each do |result|
      next unless result.first.to_s == '1.2.3.4' && result[1]['key'] == '94'
      expect(result[1]['ensure']).to eq('present')
      expect(result[1]['prefer']).to eq(true)
      expect(result[1]['minpoll']).to eq('4') if result[1].key?('minpoll')
      expect(result[1]['maxpoll']).to eq('14') if result[1].key?('maxpoll')
      expect(result[1]['source_interface']).to eq('Vlan42') if result[1].key?('source_interface')
      found_edited = true
    end
    expect(found_edited).to eq(true)
  end
  it 'remove an existing ntp_server' do
    pp = <<-EOS
    ntp_server { '1.2.3.4':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(%r{ensure.*absent})
  end
end

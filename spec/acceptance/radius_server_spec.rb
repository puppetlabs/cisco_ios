require 'spec_helper_acceptance'

describe 'radius_server' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    radius_server { "2.2.2.2":
      auth_port => '1645',
      acct_port => '1646',
      key => 'bill',
      key_format => '0',
      retransmit_count => '7',
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add radius_server' do
    pp = <<-EOS
    radius_server { "2.2.2.2":
      auth_port => '1645',
      acct_port => '1646',
      key => 'bill',
      key_format => '1',
      retransmit_count => '7',
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('radius_server', '2.2.2.2')
    expect(result).to match(%r{2.2.2.2.*})
    expect(result).to match(%r{key.*bill})
    expect(result).to match(%r{key_format.*1})
    expect(result).to match(%r{retransmit_count.*7})
    expect(result).to match(%r{acct_port.*1646})
    expect(result).to match(%r{auth_port.*1645})
  end
end

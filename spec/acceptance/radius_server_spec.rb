require 'spec_helper_acceptance'

describe 'radius_server' do
  before(:all) do
    pp = <<-EOS
    radius_server { "2.2.2.2":
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'add radius_server' do
    pp = <<-EOS
    radius_server { "2.2.2.2":
      hostname => '1.2.3.4',
      auth_port => 1642,
      acct_port => 1643,
      key => 'bill',
      key_format => 1,
      retransmit_count => 7,
      timeout => 42,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('radius_server', '2.2.2.2')
    # Does our target device support the 'new' Radius Server syntax?
    # If so, should be present, otherwise we will skip test
    if result =~ %r{ensure.*present}
      expect(result).to match(%r{2.2.2.2.*})
      # Has a key, encrypted by default on 2960
      if result =~ %r{key_format.*7}
        expect(result).to match(%r{key.*})
      else
        # Plaintext
        expect(result).to match(%r{key.*bill})
        expect(result).to match(%r{key_format.*1})
      end
      expect(result).to match(%r{hostname.*1.2.3.4})
      expect(result).to match(%r{retransmit_count.*7})
      expect(result).to match(%r{acct_port.*1643})
      expect(result).to match(%r{auth_port.*1642})
      expect(result).to match(%r{timeout.*42})
    else
      skip 'Radius server 2.2.2.2 not present, device not compatible'
    end
  end

  it 'delete radius_server' do
    result = run_resource('radius_server', '2.2.2.2')
    # Does our target device support the 'new' Radius Server syntax?
    # If so, should be present, otherwise we will skip test
    if result =~ %r{ensure.*present}
      pp = <<-EOS
  radius_server { '2.2.2.2':
    ensure => 'absent',
  }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource
      result = run_resource('radius_server', '2.2.2.2')
      expect(result).to match(%r{2.2.2.2.*})
      expect(result).to match(%r{ensure.*absent})
    else
      skip 'Radius server 2.2.2.2 not present, device not compatible'
    end
  end
end

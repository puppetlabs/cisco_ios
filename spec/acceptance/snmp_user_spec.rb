require 'spec_helper_acceptance'

describe 'snmp_user' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    snmp_user { 'bob v1':
      ensure => 'absent',
      version => 'v1'
    }
    snmp_user { 'bill v3':
      ensure => 'absent',
      version => 'v3'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add a v1 SNMP User' do
    pp = <<-EOS
    snmp_user { 'bob v1':
      version => 'v1',
      roles => 'private',
      ensure => 'present'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_user', '"bob v1"')
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{version.*v1})
    expect(result).to match(%r{roles.*private})
  end

  it 'add a v3 SNMP User' do
    pp = <<-EOS
    snmp_user { 'bill v3':
      version => 'v3',
      roles => 'public',
      auth => "md5",
      password => "b7:d1:92:a4:4e:0d:a1:6c:d1:80:eb:e8:5e:fb:7c:8f",
      privacy => "aes 128",
      private_key => "b7:d1:92:a4:4e:0d:a1:6c:d1:80:eb:e8:5e:fb:7c:8f",
      enforce_privacy => true,
      ensure => 'present'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_user', '"bill v3"')
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{version.*v3})
    expect(result).to match(%r{roles.*public})
    expect(result).to match(%r{auth.*md5})
    expect(result).to match(%r{privacy.*AES128})
  end

  it 'change a v1 SNMP User' do
    pp = <<-EOS
    snmp_user { 'bob v1':
      version => 'v1',
      roles => 'public',
      ensure => 'present'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_user', '"bob v1"')
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{version.*v1})
    expect(result).to match(%r{roles.*public})
  end

  it 'change a v3 SNMP User' do
    pp = <<-EOS
    snmp_user { 'bill v3':
      version => 'v3',
      roles => 'private',
      auth => "md5",
      password => "auth_pass",
      privacy => "aes 128",
      private_key => "privacy_pass",
      enforce_privacy => false,
      ensure => 'present'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_user', '"bill v3"')
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{version.*v3})
    expect(result).to match(%r{roles.*private})
    expect(result).to match(%r{auth.*md5})
    expect(result).not_to match(%r{ \sencrypted\s })
  end

  it 'delete a v1 SNMP User' do
    pp = <<-EOS
    snmp_user { 'bob v1':
      version => 'v1',
      roles => 'public',
      ensure => 'absent'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_user', '"bob v1"')
    expect(result).to match(%r{ensure.*absent})
  end

  it 'delete a v3 SNMP User' do
    pp = <<-EOS
    snmp_user { 'bill v3':
      version => 'v3',
      roles => 'private',
      ensure => 'absent'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('snmp_user', '"bill v3"')
    expect(result).to match(%r{ensure.*absent})
  end
end

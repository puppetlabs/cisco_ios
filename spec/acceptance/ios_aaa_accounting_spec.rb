require 'spec_helper_acceptance'

describe 'ios_aaa_accounting' do
<<<<<<< HEAD
=======
  before(:all) do
    pp = <<-EOS
    ios_aaa_accounting { 'network default':
      accounting_service => 'network',
      accounting_list => 'default',
      accounting_status => 'start-stop',
      server_groups => ['radius','test1'],
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)

    pp = <<-EOS
    ios_aaa_accounting { 'identity test1':
      accounting_service => 'identity',
      accounting_list => 'test1',
      accounting_status => 'start-stop',
      server_groups => ['radius','test1'],
      ensure => 'absent',
    }
      EOS
    make_site_pp(pp)
    run_device(allow_changes: true)

    pp = <<-EOS
    ios_aaa_accounting { 'onep default':
      accounting_service => 'onep',
      accounting_list => 'default',
      accounting_status => 'none',
      ensure => 'absent',
    }
      EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

>>>>>>> (FM-7740) Add XE functionality for ios_aaa_accounting
  it 'apply aaa accounting' do
    pp = <<-EOS
    ios_aaa_accounting { 'network default':
      accounting_service => 'network',
      accounting_list => 'default',
      accounting_status => 'start-stop',
      server_groups => ['radius','test1'],
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'network default'")
    expect(result).to match(%r{accounting_service.*network})
    expect(result).to match(%r{accounting_list.*default})
    expect(result).to match(%r{server_groups.*radius.*test1})
    expect(result).to match(%r{accounting_status.*start-stop})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove aaa accounting' do
    pp = <<-EOS
    ios_aaa_accounting { 'network default':
      accounting_service => 'network',
      accounting_list => 'default',
      accounting_status => 'start-stop',
      server_groups => ['radius','test1'],
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'network default'")
    expect(result).to match(%r{ensure.*absent})
  end

<<<<<<< HEAD
  it 'apply aaa accounting newinfo' do
    pp = <<-EOS
    ios_aaa_accounting { 'update newinfo':
      accounting_service => 'update',
      update_newinfo => true,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'update newinfo'")
    expect(result).to match(%r{update_newinfo.*true})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove aaa accounting newinfo' do
    pp = <<-EOS
    ios_aaa_accounting { 'update newinfo':
      accounting_service => 'update',
      update_newinfo => false,
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'update newinfo'")
    expect(result).to match(%r{ensure.*absent})
  end

  it 'apply aaa accounting periodic' do
    pp = <<-EOS
    ios_aaa_accounting { 'update periodic':
      accounting_service => 'update',
      update_periodic => 4242,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'update periodic'")
    expect(result).to match(%r{update_periodic.*4242})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove aaa accounting periodic' do
    pp = <<-EOS
    ios_aaa_accounting { 'update periodic':
      accounting_service => 'update',
      update_periodic => 4242,
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'update periodic'")
    expect(result).to match(%r{ensure.*absent})
  end

  it 'apply aaa accounting newinfo periodic' do
    pp = <<-EOS
    ios_aaa_accounting { 'update newinfo periodic':
      accounting_service => 'update',
      update_newinfo_periodic => 4242,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'update newinfo periodic'")
    expect(result).to match(%r{update_newinfo_periodic.*4242})
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove aaa accounting newinfo periodic' do
    pp = <<-EOS
    ios_aaa_accounting { 'update newinfo periodic':
      accounting_service => 'update',
      update_newinfo_periodic => 4242,
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_accounting', "'update newinfo periodic'")
    expect(result).to match(%r{ensure.*absent})
  end

=======
>>>>>>> (FM-7740) Add XE functionality for ios_aaa_accounting
  it 'apply aaa accounting identity' do
    if XeCheck.device_xe?
      pp = <<-EOS
    ios_aaa_accounting { 'identity test1':
      accounting_service => 'identity',
      accounting_list => 'test1',
      accounting_status => 'start-stop',
      server_groups => ['radius','test1'],
      ensure => 'present',
    }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource
      result = run_resource('ios_aaa_accounting', "'identity test1'")
      expect(result).to match(%r{accounting_service.*identity})
      expect(result).to match(%r{accounting_list.*test1})
      expect(result).to match(%r{server_groups.*radius.*test1})
      expect(result).to match(%r{accounting_status.*start-stop})
      expect(result).to match(%r{ensure.*present})
    else
      skip 'Skipping XE specific tests'
    end
  end

  it 'remove aaa accounting identity' do
    if XeCheck.device_xe?

      pp = <<-EOS
    ios_aaa_accounting { 'identity test1':
      accounting_service => 'identity',
      accounting_list => 'test1',
      accounting_status => 'start-stop',
      server_groups => ['radius','test1'],
      ensure => 'absent',
    }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource
      result = run_resource('ios_aaa_accounting', "'identity test1'")
      expect(result).to match(%r{ensure.*absent})
    else
      skip 'Skipping XE specific tests'
    end
  end

  it 'apply aaa accounting onep' do
    if XeCheck.device_xe?
      pp = <<-EOS
    ios_aaa_accounting { 'onep default':
      accounting_service => 'onep',
      accounting_list => 'default',
      accounting_status => 'none',
      ensure => 'present',
    }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource
      result = run_resource('ios_aaa_accounting', "'onep default'")
      expect(result).to match(%r{accounting_service.*onep})
      expect(result).to match(%r{accounting_list.*default})
      expect(result).to match(%r{ensure.*present})
    else
      skip 'Skipping XE specific tests'
    end
  end

  it 'remove aaa accounting onep' do
    if XeCheck.device_xe?
      pp = <<-EOS
    ios_aaa_accounting { 'onep default':
      accounting_service => 'onep',
      accounting_list => 'default',
      ensure => 'absent',
    }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource
      result = run_resource('ios_aaa_accounting', "'onep default'")
      expect(result).to match(%r{ensure.*absent})
    else
      skip 'Skipping XE specific tests'
    end
  end
end

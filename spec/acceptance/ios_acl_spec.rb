require 'spec_helper_acceptance'

describe 'ios_acl' do
  it 'apply access list entries' do
    pp = <<-EOS
    ios_acl { '12 standard 10':
      permission => 'permit',
      ensure => 'present',
      source_address_any => true,
    }
    ios_acl { 'test42 standard 10':
      permission => 'deny',
      ensure => 'present',
      source_address => '1.2.3.4',
    }
    ios_acl { 'test43 extended 30':
      permission => 'deny',
      ensure => 'present',
      protocol => 'tcp',
      source_address => '1.1.1.0',
      source_address_wildcard_mask => '0.0.0.1',
      destination_address => '0.2.4.2',
      destination_address_wildcard_mask => '1.1.1.1',
      match_all => ['+ack', '-fin'],
      log => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_acl', "'12 standard 10'")
    expect(result).to match(%r{entry.*10})
    expect(result).to match(%r{permission.*permit})
    expect(result).to match(%r{access_list.*12})
    expect(result).to match(%r{access_list_type.*standard})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{source_address_any.*true})
    result = run_resource('ios_acl', "'test42 standard 10'")
    expect(result).to match(%r{entry.*10})
    expect(result).to match(%r{permission.*deny})
    expect(result).to match(%r{access_list.*test42})
    expect(result).to match(%r{access_list_type.*standard})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{source_address.*1.2.3.4})
    result = run_resource('ios_acl', "'test43 extended 30'")
    expect(result).to match(%r{entry.*30})
    expect(result).to match(%r{permission.*deny})
    expect(result).to match(%r{access_list.*test43})
    expect(result).to match(%r{access_list_type.*extended})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{protocol.*tcp})
    expect(result).to match(%r{source_address.*1.1.1.0})
    expect(result).to match(%r{source_address_wildcard_mask.*0.0.0.1})
    expect(result).to match(%r{destination_address.*0.2.4.2})
    expect(result).to match(%r{destination_address_wildcard_mask.*1.1.1.1})
    expect(result).to match(%r{match_all.*\+ack.*-fin})
    expect(result).to match(%r{log.*true})
  end

  it 'modify access list entries' do
    pp = <<-EOS
    ios_acl { '12 standard 10':
      permission => 'deny',
      ensure => 'present',
      source_address_any => true,
    }
    ios_acl { 'test42 standard 10':
      permission => 'permit',
      ensure => 'present',
      source_address => '4.3.2.1',
    }
    ios_acl { 'test43 extended 30':
      permission => 'permit',
      ensure => 'present',
      protocol => 'tcp',
      source_address => '3.3.3.1',
      source_address_wildcard_mask => '0.0.0.254',
      destination_address => '5.5.4.1',
      destination_address_wildcard_mask => '0.0.1.254',
      match_all => ['+ack'],
      log => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_acl', "'12 standard 10'")
    expect(result).to match(%r{entry.*10})
    expect(result).to match(%r{permission.*deny})
    expect(result).to match(%r{access_list.*12})
    expect(result).to match(%r{access_list_type.*standard})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{source_address_any.*true})
    result = run_resource('ios_acl', "'test42 standard 10'")
    expect(result).to match(%r{entry.*10})
    expect(result).to match(%r{permission.*permit})
    expect(result).to match(%r{access_list.*test42})
    expect(result).to match(%r{access_list_type.*standard})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{source_address.*4.3.2.1})
    result = run_resource('ios_acl', "'test43 extended 30'")
    expect(result).to match(%r{entry.*30})
    expect(result).to match(%r{permission.*permit})
    expect(result).to match(%r{access_list.*test43})
    expect(result).to match(%r{access_list_type.*extended})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{protocol.*tcp})
    expect(result).to match(%r{source_address.*3.3.3.1})
    expect(result).to match(%r{source_address_wildcard_mask.*0.0.0.254})
    expect(result).to match(%r{destination_address.*5.5.4.1})
    expect(result).to match(%r{destination_address_wildcard_mask.*0.0.1.254})
    expect(result).to match(%r{match_all.*\+ack})
    expect(result).not_to match(%r{match_all.*\-fin})
    expect(result).to match(%r{log.*false})
  end

  it 'remove access list entries' do
    pp = <<-EOS
    ios_acl { '12 standard 10':
      ensure => 'absent'
    }
    ios_acl { 'test42 standard 10':
      ensure => 'absent'
    }
    ios_acl { 'test43 extended 30':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_acl', "'12 standard 10'")
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_acl', "'test42 standard 10'")
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_acl', "'test43 extended 30'")
    expect(result).to match(%r{ensure.*absent})
  end
end

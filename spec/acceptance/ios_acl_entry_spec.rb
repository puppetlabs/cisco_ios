require 'spec_helper_acceptance'

describe 'ios_acl_entry' do
  before(:all) do
    pp = <<-EOS
    ios_access_list { 'test42':
      access_list_type => 'Standard',
      ensure => 'present',
    }
    ios_access_list { 'test43':
      access_list_type => 'Extended',
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'apply access list entries' do
    pp = <<-EOS
    ios_acl_entry { 'test42 10':
      entry => 10,
      permission => 'deny',
      access_list => 'test42',
      ensure => 'present',
      source_address => '1.2.3.4',
    }
    ios_acl_entry { 'test43 30':
      entry => 30,
      permission => 'deny',
      access_list => 'test43',
      ensure => 'present',
      protocol => 'tcp',
      source_address => '1.0.1.4',
      source_address_wildcard_mask => '4.3.2.1',
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
    result = run_resource('ios_acl_entry', "'test42 10'")
    expect(result).to match(%r{entry.*10})
    expect(result).to match(%r{permission.*deny})
    expect(result).to match(%r{access_list.*test42})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{source_address.*1.2.3.4})
    result = run_resource('ios_acl_entry', "'test43 30'")
    expect(result).to match(%r{entry.*30})
    expect(result).to match(%r{permission.*deny})
    expect(result).to match(%r{access_list.*test43})
    expect(result).to match(%r{ensure.*present})
    expect(result).to match(%r{protocol.*tcp})
    expect(result).to match(%r{source_address.*1.0.1.4})
    expect(result).to match(%r{source_address_wildcard_mask.*4.3.2.1})
    expect(result).to match(%r{destination_address.*0.2.4.2})
    expect(result).to match(%r{destination_address_wildcard_mask.*1.1.1.1})
    expect(result).to match(%r{match_all.*\+ack.*-fin})
    expect(result).to match(%r{log.*true})
  end

  it 'remove access list entries' do
    pp = <<-EOS
    ios_acl_entry { 'test42 10':
      entry => 10,
      permission => 'deny',
      access_list => 'test42',
      ensure => 'absent',
      source_address => '1.2.3.4',
    }
    ios_acl_entry { 'test43 30':
      entry => 30,
      permission => 'deny',
      access_list => 'test43',
      ensure => 'absent',
      protocol => 'tcp',
      source_address => '1.0.1.4',
      source_address_wildcard_mask => '4.3.2.1',
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
    result = run_resource('ios_acl_entry', "'test42 10'")
    expect(result).to match(%r{ensure.*absent})
    result = run_resource('ios_acl_entry', "'test43 30'")
    expect(result).to match(%r{ensure.*absent})
  end
end

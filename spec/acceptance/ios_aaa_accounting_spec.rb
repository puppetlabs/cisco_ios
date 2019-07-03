require 'spec_helper_acceptance'

describe 'ios_aaa_accounting' do
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
end

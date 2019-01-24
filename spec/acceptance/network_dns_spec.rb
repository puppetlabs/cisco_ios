require 'spec_helper_acceptance'
describe 'network_dns' do
  domain_name = 'temp_hostname'

  before(:all) do
    result = run_resource('network_dns')
    actual = result.match(%r{domain => '(\w.*)'})
    domain_name = actual[1] unless actual.nil?
  end

  it 'set one way' do
    pp = <<-EOS
    network_dns { "default":
      servers => ['1.1.1.1', '1.1.1.3'],
      search => ['jim.com'],
      domain => 'amy.com',
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
    result = run_resource('network_dns')
    expect(result).to match(%r{domain.*amy.com})
    expect(result).to match(%r{search.*jim.com})
    expect(result).to match(%r{servers.*1.1.1.1})
    expect(result).to match(%r{servers.*1.1.1.3})
  end

  it 'set a different way' do
    pp = <<-EOS
    network_dns { "default":
      servers => ['2.2.2.2', '2.2.2.3'],
      search => ['john.com', 'bill.com'],
      domain => 'jill.com',
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
    result = run_resource('network_dns')
    expect(result).to match(%r{domain.*jill.com})
    expect(result).to match(%r{search.*john.com})
    expect(result).to match(%r{search.*bill.com})
    expect(result).to match(%r{servers.*2.2.2.3})
    expect(result).to match(%r{servers.*2.2.2.2})
  end

  it 'set domain_name back to normal' do
    pp = <<-EOS
    network_dns{ 'default':
      ensure => 'present',
      domain => '#{domain_name}',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end
end

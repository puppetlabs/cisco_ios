require 'spec_helper_acceptance'
describe 'ios_config' do
  domain_name = 'temp_hostname'

  before(:all) do
    result = run_resource('network_dns')
    actual = result.match(%r{domain => '(\w.*)'})[1]
    domain_name = actual unless actual.nil?
  end

  it 'just "command" set' do
    pp = <<-EOS
    ios_config { "jimmy":
      command => 'ip domain-name jimmy'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: true)
    # Use domain_name for check
    result = run_resource('network_dns')
    expect(result).to match(%r{domain.*jimmy})
  end

  it 'command and idempotent_regex, should stay set to jimmy' do
    pp = <<-EOS
    ios_config { "jimmy":
      command => 'ip domain-name bill',
      idempotent_regex => 'ip domain-name jimmy'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Use domain_name for check
    result = run_resource('network_dns')
    expect(result).to match(%r{domain.*jimmy})
  end

  it 'command and idempotent_regex, should change to bill' do
    pp = <<-EOS
    ios_config { "jimmy":
      command => 'ip domain-name bill',
      idempotent_regex => 'ip domain-name bill'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Use domain_name for check
    result = run_resource('network_dns')
    expect(result).to match(%r{domain.*bill})
  end

  it 'set domain_name back to normal' do
    pp = <<-EOS
    domain_name { '#{domain_name}':
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end
end

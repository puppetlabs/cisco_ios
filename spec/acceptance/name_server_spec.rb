require 'spec_helper_acceptance'

describe 'should change an name_server' do
  before(:all) do
    # Remove if already present
    pp = <<-EOS
    name_server { '1.2.3.4':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    run_device(allow_changes: false)
  end

  it 'add an name_server' do
    pp = <<-EOS
    name_server { '1.2.3.4':
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('name_server', '1.2.3.4')
    expect(result).to match(%r{ensure.*present})
  end

  it 'remove an existing name_server' do
    pp = <<-EOS
    name_server { '1.2.3.4':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('name_server', '1.2.3.4')
    expect(result).to match(%r{ensure.*absent})
  end
end

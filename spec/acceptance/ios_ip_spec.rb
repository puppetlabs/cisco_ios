require 'spec_helper_acceptance'

describe 'ios_ip' do
  before(:all) do
    skip "This device #{device_model} does not support the setting of ip routing" if ['2960', '6503'].include?(device_model)
    skip "This device #{device_model}, has been exluded from testing as the local copy we run against has issues when ip routing is disabled" if ['3560', '4503'].include?(device_model)
  end

  it 'edit ios_ip' do
    pp = <<-EOS
    ios_ip { 'default':
      routing => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_ip', 'default')
    expect(result).to match(%r{routing => true})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'unset' do
    pp = <<-EOS
    ios_ip { 'default':
      routing => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_ip', 'default')
    expect(result).to match(%r{routing => false})
    # Are we idempotent
    run_device(allow_changes: false)
  end
end

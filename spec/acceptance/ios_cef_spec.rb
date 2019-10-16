require 'spec_helper_acceptance'

describe 'ios_cef' do
  before(:all) do
    skip "This device #{device_model} does not support the setting of CEF settings" if ['2960'].include?(device_model)
  end

  it 'edit ios_cef' do
    distributed = ['3560', '3650', '3750', '4503', '4507', '4948', '6503'].include?(device_model) ? '' : 'distributed => false,'
    optimize_resolution = ['4948'].include?(device_model) ? '' : 'optimize_resolution => false,'
    pp = <<-EOS
    ios_cef { 'default':
      #{distributed}
      #{optimize_resolution}
      load_sharing => 'tunnel',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_cef', 'default')
    expect(result).to match(%r{distributed => false}) if distributed != ''
    expect(result).to match(%r{optimize_resolution => false}) if optimize_resolution != ''
    expect(result).to match(%r{load_sharing => 'tunnel'})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'edit ios_cef again' do
    distributed = ['3560', '3650', '3750', '4503', '4507', '4948', '6503'].include?(device_model) ? '' : 'distributed => true,'
    optimize_resolution = ['4948'].include?(device_model) ? '' : 'optimize_resolution => true,'
    pp = <<-EOS
    ios_cef { 'default':
      #{distributed}
      #{optimize_resolution}
      load_sharing => 'original',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_cef', 'default')
    expect(result).to match(%r{distributed => true}) if distributed != ''
    expect(result).to match(%r{optimize_resolution => true}) if optimize_resolution != ''
    expect(result).to match(%r{load_sharing => 'original'})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'default ios_cef' do
    distributed = ['3560', '3650', '3750', '4503', '4507', '4948', '6503'].include?(device_model) ? '' : 'distributed => true,'
    optimize_resolution = ['4948'].include?(device_model) ? '' : 'optimize_resolution => true,'
    pp = <<-EOS
    ios_cef { 'default':
      #{distributed}
      #{optimize_resolution}
      load_sharing => 'universal',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_cef', 'default')
    expect(result).to match(%r{distributed => true}) if distributed != ''
    expect(result).to match(%r{optimize_resolution => true}) if optimize_resolution != ''
    expect(result).to match(%r{load_sharing => 'universal'})
    # Are we idempotent
    run_device(allow_changes: false)
  end
end

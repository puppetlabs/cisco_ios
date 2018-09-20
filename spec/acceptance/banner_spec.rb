require 'spec_helper_acceptance'

describe 'banner' do
  before(:all) do
    # Set to known values
    pp = <<-EOS
    banner { "default":
      motd => 'woof',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'edit banner' do
    pp = <<-EOS
    banner { "default":
      motd => 'meow',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('banner', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{motd.*meow})
  end
  it 'unset banner' do
    pp = <<-EOS
    banner { "default":
      motd => 'unset',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('banner', 'default')
    expect(result).to match(%r{default.*})
    expect(result).not_to match(%r{motd.*})
  end
end

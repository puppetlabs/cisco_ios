require 'spec_helper_acceptance'

describe 'banner' do
  it 'edit banner' do
    pp = <<-EOS
    banner { "default":
      motd =>  'meow',
      login => 'meow    meow',
      exec =>  'meow meow meow',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('banner', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{motd => 'meow'})
    expect(result).to match(%r{login => 'meow    meow'})
    expect(result).to match(%r{exec => 'meow meow meow'})
    # Are we idempotent
    run_device(allow_changes: false)
  end
  it 'unset banner' do
    pp = <<-EOS
    banner { "default":
      motd => 'unset',
      login => 'unset',
      exec =>  'unset',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('banner', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{motd => 'unset'})
    expect(result).to match(%r{login => 'unset'})
    expect(result).to match(%r{exec => 'unset'})
    # Are we idempotent
    run_device(allow_changes: false)
  end
end

require 'spec_helper_acceptance'

describe 'tacacs_global' do
  before(:all) do
    # Set to known values
    pp = <<-EOS
    tacacs_global { "default":
      key => 'jim',
      key_format => 3,
      source_interface => ['Vlan42'],
      timeout => 50,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end

  it 'edit tacacs_global' do
    pp = <<-EOS
    tacacs_global { "default":
      key => 'bill',
      key_format => 4,
      source_interface => ['Vlan43'],
      timeout => 60,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('tacacs_global', 'default')
    expect(result).to match(%r{default.*})
    # Has a key, encrypted by default on 2960
    if result =~ %r{key_format.*7}
      expect(result).to match(%r{key.*})
    else
      # Plaintext
      expect(result).to match(%r{key.*bill})
      expect(result).to match(%r{key_format.*4})
    end
    expect(result).to match(%r{source_interface.*Vlan43})
    expect(result).to match(%r{timeout.*60})
  end
end

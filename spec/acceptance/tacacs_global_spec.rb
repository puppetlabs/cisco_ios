require 'spec_helper_acceptance'

describe 'tacacs_global' do
  it 'edit tacacs_global' do
    pp = <<-EOS
    tacacs_global { "default":
      key => '08750C4C001509',
      key_format => 7,
      source_interface => ['Vlan42'],
      timeout => 50,
      directed_request => true,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
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
    expect(result).to match(%r{source_interface.*=> \['Vlan42'\]}) if result =~ %r{source_interface.*=>}
    # Due to Cisco bug as described at
    # https://supportforums.cisco.com/t5/aaa-identity-and-nac/tacacs-timeout-value-ignored/td-p/346109
    # The timeout may not apply and may remain at default
    if result !~ %r{timeout.*5}
      expect(result).to match(%r{timeout.*50})
    end
    expect(result).to match(%r{directed_request => true})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'edit tacacs_global again' do
    pp = <<-EOS
    tacacs_global { "default":
      key => '08750C4C001509',
      key_format => 7,
      source_interface => ['Vlan43'],
      timeout => 60,
      directed_request => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
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
    expect(result).to match(%r{source_interface.*=> \['Vlan43'\]}) if result =~ %r{source_interface.*=>}
    # Due to Cisco bug as described at
    # https://supportforums.cisco.com/t5/aaa-identity-and-nac/tacacs-timeout-value-ignored/td-p/346109
    # The timeout may not apply and may remain at default
    if result !~ %r{timeout.*5}
      expect(result).to match(%r{timeout.*60})
    end
    expect(result).to match(%r{directed_request => false})
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'when given vrf nothing changes' do
    pp = <<-EOS
    tacacs_global { "default":
      key => '08750C4C001509',
      key_format => 7,
      source_interface => ['Vlan42'],
      timeout => 60,
      vrf => ['error_vrf']
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true, allow_errors: true)
    # Check puppet resource
    result = run_resource('tacacs_global', 'default')
    expect(result).to match(%r{default.*})
    expect(result).to match(%r{source_interface.*=> \['Vlan43'\]}) if result =~ %r{source_interface.*=>}
    expect(result).not_to match(%r{vrf =>})
  end
end

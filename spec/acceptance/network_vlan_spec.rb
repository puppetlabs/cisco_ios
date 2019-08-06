require 'spec_helper_acceptance'

describe 'network_vlan' do
  describe 'handling regular VLANs' do
    it 'creates a network VLAN' do
      pp = <<-EOS
      network_vlan { "44":
        shutdown => true,
        ensure => present,
      }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource
      result = run_resource('network_vlan', '44')
      expect(result).to match(%r{ensure.*present})
      expect(result).to match(%r{shutdown.*true})
    end

    it 'edit a network VLAN' do
      pp = <<-EOS
      network_vlan { "44":
        vlan_name => "testvlansoitis",
        shutdown => false,
        ensure => present,
      }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource after 10 seconds
      sleep(10)
      result = run_resource('network_vlan', '44')
      expect(result).to match(%r{ensure.*present})
      expect(result).to match(%r{shutdown.*false})
      expect(result).to match(%r{vlan_name.*testvlansoitis})
    end

    it 'delete a network VLAN' do
      pp = <<-EOS
      network_vlan { "44":
        ensure => absent,
      }
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
      # Are we idempotent
      run_device(allow_changes: false)
      # Check puppet resource
      result = run_resource('network_vlan', '44')
      expect(result).to match(%r{ensure.*absent})
    end
  end

  describe 'handling default VLANs' do
    it 'errors on update' do
      pp = <<-EOS
      network_vlan { "1":
        vlan_name => "default",
        shutdown => true,
        ensure => present,
      }
      EOS
      make_site_pp(pp)
      expect(run_device(allow_changes: true, allow_errors: true)).to include('VLAN 1 is a Cisco default VLAN and may not be updated')
    end

    it 'errors on delete' do
      pp = <<-EOS
      network_vlan { "1":
        ensure => absent,
      }
      EOS
      make_site_pp(pp)
      expect(run_device(allow_changes: true, allow_errors: true)).to include('VLAN 1 is a Cisco default VLAN and may not be deleted')
    end
  end
end

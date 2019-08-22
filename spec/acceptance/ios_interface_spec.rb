require 'spec_helper_acceptance'

describe 'ios_interface' do
  let(:target) do
    if ['3650', '3750', '2960'].include?(device_model)
      'GigabitEthernet1/0'
    elsif ['4507', '4948', '6503'].include?(device_model)
      'GigabitEthernet1'
    elsif ['4503'].include?(device_model)
      'GigabitEthernet2'
    else
      'GigabitEthernet0'
    end
  end

  it 'Set Two Instances' do
    mac = if ['2960', '4507', '6503'].include?(device_model)
            ['', '', '', '']
          else
            ['mac_notification_added => false,', 'mac_notification_removed => false,',
             'mac_notification_added => true,', 'mac_notification_removed => true,']
          end
    ip = if ['6503'].include?(device_model)
           ['', '', '', '']
         else
           ['ip_dhcp_snooping_trust => true,', 'ip_dhcp_snooping_limit => 500,',
            'ip_dhcp_snooping_trust => false,', 'ip_dhcp_snooping_limit => 1500,']
         end
    pp = <<-EOS
    ios_interface { '#{target}/1':
      #{mac[0]}
      #{mac[1]}
      #{ip[0]}
      #{ip[1]}
      link_status_duplicates => true,
      logging_event => ['nfas-status','subif-link-status'],
      flowcontrol_receive => 'on',
    }
    ios_interface { '#{target}/2':
      #{mac[2]}
      #{mac[3]}
      #{ip[2]}
      #{ip[3]}
      logging_event => ['trunk-status'],
      logging_event_link_status => false,
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_interface', "#{target}/1")
    expect(result).to match(%r{mac_notification_added => false}) if mac[0] != ''
    expect(result).to match(%r{mac_notification_removed => false}) if mac[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_trust => true}) if ip[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_limit => 500,}) if ip[0] != ''
    expect(result).to match(%r{link_status_duplicates => true})
    expect(result).to match(%r{logging_event => \['nfas-status', 'subif-link-status'\]})
    expect(result).to match(%r{logging_event_link_status => true})
    expect(result).to match(%r{flowcontrol_receive => 'on'}) if result =~ %r{flowcontrol_receive =>}
    result = run_resource('ios_interface', "#{target}/2")
    expect(result).to match(%r{mac_notification_added => true}) if mac[0] != ''
    expect(result).to match(%r{mac_notification_removed => true}) if mac[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_trust => false}) if ip[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_limit => 1500,}) if ip[0] != ''
    expect(result).to match(%r{link_status_duplicates => false})
    expect(result).to match(%r{logging_event => \['trunk-status'\]})
    expect(result).to match(%r{logging_event_link_status => false})
    expect(result).to match(%r{flowcontrol_receive => 'off'}) if result =~ %r{flowcontrol_receive =>}
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'Update Two Instances' do
    mac = if ['2960', '4507', '6503'].include?(device_model)
            ['', '', '', '']
          else
            ['mac_notification_added => true,', 'mac_notification_removed => true,',
             'mac_notification_added => false,', 'mac_notification_removed => false,']
          end
    ip = if ['6503'].include?(device_model)
           ['', '']
         else
           ['ip_dhcp_snooping_trust => false,', 'ip_dhcp_snooping_limit => 1500,',
            'ip_dhcp_snooping_trust => true,', 'ip_dhcp_snooping_limit => 500,']
         end
    pp = <<-EOS
    ios_interface { '#{target}/1':
      #{mac[0]}
      #{mac[1]}
      #{ip[0]}
      #{ip[1]}
      link_status_duplicates => false,
      logging_event => ['trunk-status'],
      logging_event_link_status => true,
      flowcontrol_receive => 'off',
    }
    ios_interface { '#{target}/2':
      #{mac[2]}
      #{mac[3]}
      #{ip[2]}
      #{ip[3]}
      link_status_duplicates => true,
      logging_event => ['nfas-status','subif-link-status'],
      logging_event_link_status => false,
      flowcontrol_receive => 'on',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_interface', "#{target}/1")
    expect(result).to match(%r{mac_notification_added => true}) if mac[0] != ''
    expect(result).to match(%r{mac_notification_removed => true}) if mac[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_trust => false}) if ip[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_limit => 1500,}) if ip[0] != ''
    expect(result).to match(%r{link_status_duplicates => false})
    expect(result).to match(%r{logging_event => \['trunk-status'\]})
    expect(result).to match(%r{logging_event_link_status => true})
    expect(result).to match(%r{flowcontrol_receive => 'off'}) if result =~ %r{flowcontrol_receive =>}
    result = run_resource('ios_interface', "#{target}/2")
    expect(result).to match(%r{mac_notification_added => false}) if mac[0] != ''
    expect(result).to match(%r{mac_notification_removed => false}) if mac[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_trust => true}) if ip[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_limit => 500}) if ip[0] != ''
    expect(result).to match(%r{link_status_duplicates => true})
    expect(result).to match(%r{logging_event => \['nfas-status', 'subif-link-status'\]})
    expect(result).to match(%r{logging_event_link_status => false})
    expect(result).to match(%r{flowcontrol_receive => 'on'}) if result =~ %r{flowcontrol_receive =>}
    # Are we idempotent
    run_device(allow_changes: false)
  end

  it 'Unset Two Instances' do
    mac = if ['2960', '4507', '6503'].include?(device_model)
            ['', '']
          else
            ['mac_notification_added => false,', 'mac_notification_removed => false,']
          end
    ip = if ['6503'].include?(device_model)
           ['', '']
         else
           ['ip_dhcp_snooping_limit => false,', 'ip_dhcp_snooping_trust => false,']
         end
    pp = <<-EOS
    ios_interface { '#{target}/1':
      #{mac[0]}
      #{mac[1]}
      #{ip[0]}
      #{ip[1]}
      link_status_duplicates => false,
      logging_event => 'unset',
      logging_event_link_status => true,
    }
    ios_interface { '#{target}/2':
      #{mac[0]}
      #{mac[1]}
      #{ip[0]}
      #{ip[1]}
      link_status_duplicates => false,
      logging_event => 'unset',
      logging_event_link_status => true,
      flowcontrol_receive => 'off',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Check puppet resource
    result = run_resource('ios_interface', "#{target}/1")
    expect(result).to match(%r{mac_notification_added => false}) if mac[0] != ''
    expect(result).to match(%r{mac_notification_removed => false}) if mac[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_trust => false}) if ip[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_limit => false}) if ip[0] != ''
    expect(result).to match(%r{link_status_duplicates => false})
    expect(result).to match(%r{logging_event => 'unset'})
    expect(result).to match(%r{logging_event_link_status => true})
    expect(result).to match(%r{flowcontrol_receive => 'off'}) if result =~ %r{flowcontrol_receive =>}
    result = run_resource('ios_interface', "#{target}/2")
    expect(result).to match(%r{mac_notification_added => false}) if mac[0] != ''
    expect(result).to match(%r{mac_notification_removed => false}) if mac[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_trust => false}) if ip[0] != ''
    expect(result).to match(%r{ip_dhcp_snooping_limit => false}) if ip[0] != ''
    expect(result).to match(%r{link_status_duplicates => false})
    expect(result).to match(%r{logging_event => 'unset'})
    expect(result).to match(%r{logging_event_link_status => true})
    expect(result).to match(%r{flowcontrol_receive => 'off'}) if result =~ %r{flowcontrol_receive =>}
    # Are we idempotent
    run_device(allow_changes: false)
  end
end

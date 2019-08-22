# Test Matrix

The module works against a broad range of IOS and IOS-XE based devices, but we don't test against all device types. We have continuous integration pipelines where we test against physical devices. Listed below are details of those device types. Please note that our initial development and testing has focussed on switches, with routers and firewalls to follow-on.

### Table of Contents

1. [Devices used in testing](#devices-used-in-testing)
1. [Resources vs Device Type](#resources-vs-device-type)
3. [Deviations](#deviations)
4. [Anomalies in Cisco CLI](#anomalies-in-cisco-cli)


## Devices used in testing
| Device Type | IOS Version                                                                                                                                |
|-------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| 2960        | Cisco IOS Software, C2960S Software (C2960S-UNIVERSALK9-M), Version 12.2(58)SE2, RELEASE SOFTWARE (fc1)                                    |
| 3650        | Cisco IOS Software, IOS-XE Software, Catalyst L3 Switch Software (CAT3K_CAA-UNIVERSALK9-M), Version 03.06.05.E RELEASE SOFTWARE (fc2)      |
| 3750        | Cisco IOS Software, C3750 Software (C3750-IPSERVICESK9-M), Version 12.2(55)SE10, RELEASE SOFTWARE (fc2)                                    |
| 4503        | Cisco IOS Software, IOS-XE Software, Catalyst 4500 L3 Switch  Software (cat4500e-UNIVERSALK9-M), Version 03.07.03.E RELEASE SOFTWARE (fc3) |
| 4507r       | Cisco IOS Software, Catalyst 4000 L3 Switch Software (cat4000-I5K91S-M), Version 12.2(25)EWA9, RELEASE SOFTWARE (fc3)                      |
| 4948        | Cisco IOS Software, Catalyst 4500 L3 Switch Software (cat4500-ENTSERVICESK9-M), Version 12.2(37)SG1, RELEASE SOFTWARE (fc2)                |
| 6503        | Cisco IOS Software, s72033_rp Software (s72033_rp-IPSERVICESK9_WAN-M), Version 12.2(33)SXJ10, RELEASE SOFTWARE (fc3)                       |

## Resources vs Device type
| Resource                        | 2960                 | 3650(IOS-XE)         | 3750                 | 4503(IOS-XE)         | 4507r                | 4948                 | 6503                 |
|---------------------------------|----------------------|----------------------|----------------------|----------------------|----------------------|----------------------|----------------------|
| banner                          | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| domain_name                     | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      |
| ios_config                      | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| ios_radius_global               | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| ios_stp_global                  | ok*                  | ok*                  | ok*                  | ok*                  | ok*                  | ok*                  | ok                   |
| ios_additional_syslog_settings  | ok                   | ok                   | ok                   | ok                   | ok                   | ok*                  | ok                   |
| ios_interface                   | ok*                  | ok                   | ok                   | ok*                  | ok*                  | ok                   | ok*                  |
| name_server                     | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      |
| network_dns                     | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| network_interface               | ok*                  | ok*                  | ok*                  | ok                   | ok                   | ok                   | ok                   |
| network_snmp                    | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| network_trunk                   | ok*                  | ok*                  | ok                   | ok*                  | ok                   | ok                   | ok                   |
| network_vlan                    | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| ntp_auth_key*                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| ntp_config                      | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| ntp_server                      | ok                   | ok                   | ok*                  | ok                   | ok                   | ok*                  | ok                   |
| port_channel                    | ok*                  | ok*                  | ok*                  | ok*                  | ok*                  | ok*                  | ok                   |
| radius                          | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS |
| radius_global*                  | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| radius_server                   | ok                   | ok                   | not supported        | ok                   | not supported        | not supported        | not supported        |
| radius_server_group             | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| search_domain                   | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      | use network_dns      |
| snmp_community                  | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| snmp_notification               | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| snmp_notification_receiver      | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| snmp_user*                      | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| syslog_server                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| syslog_settings                 | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| tacacs                          | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS |
| tacacs_global*                  | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| tacacs_server                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |
| tacacs_server_group             | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   | ok                   |

Cells marked with the * have deviations. See the section below for details.

## Deviations

### snmp_user

As required by RFC 3414 SNMP server, user commands will not be displayed in the configuration output of the device. The values `password` and `enforce_privacy` are not comparable on the device. This means when using the resource to manage v3 SNMP users, we can't support idempotency and a corrective change will occur when `password` and `enforce_privacy` are present in a manifest.

### network_interface

#### 2960

The switch does not support the MTU on a per-interface basis. It does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960/software/release/15-2_2_e/configuration/guide/b_1522e_2960_2960c_2960s_2960sf_2960p_cg/b_1522e_2960_2960c_2960s_2960sf_2960p_cg_chapter_01001.html)

* mtu

#### 3650

The switch does not support the MTU on a per-interface basis. It does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3650/software/release/3se/int_hw_components/configuration_guide/b_int_3se_3650_cg/b_int_3se_3650_cg_chapter_0110.html)

* mtu

#### 3750

The switch does not support the MTU on a per-interface basis. It does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750/software/release/12-2_55_se/configuration/guide/scg3750/swint.html)

* mtu

### ios_interface

#### 2960

#### 4507

#### 6503

The above devices do not support the params `mac_notification_added` or `mac_notification_added`.

#### 4503

#### 6503

The above devices do not support the params `ip_dhcp_snooping_trust` or `ip_dhcp_snooping_limit`.

### network_trunk

#### 2960

This device does not have native trunking. It does not support the following attributes: [link](https://learningnetwork.cisco.com/thread/75947)

* ensure
* encapsulation

#### ntp_auth_key

When managing the `password` and `mode`, the expectation is that these will supplied as stored on the device, i.e. the encrypted password and `mode` 7 in most cases. To get the current configuration the `--resource` command can be used:

```
puppet device --target cisco.example.com --resource ntp_auth_key
```

This is the configuration which should be managed in your Puppet manifest.

#### XE OS

This device type only supports a single method of encapsulation, `802.1q`, and as such the attribute to set it is not supported.

### ntp_server

#### 3750

Does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750x_3560x/software/release/12-2_55_se/configuration/guide/3750xscg/swadmin.html)

* minpoll
* maxpoll

#### 4948

Does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst4500/12-2/31sga/configuration/guide/config/swadmin.html)

* minpoll
* maxpoll

#### 4507

Does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst4500/12-2/31sga/configuration/guide/config/swadmin.html#wp1245750)

* minpoll
* maxpoll

### port_channel

#### 2960

#### 3560

#### 3650

#### 3750

#### 4503

#### 4507

#### 4948

The above devices do not have native trunking. The following attributes are not supported: [link](https://learningnetwork.cisco.com/thread/75947)

* flowcontrol_send

### radius_global

The IOS operating system does not support:

* enable

### radius_server

#### 3750

#### 4507r

#### 4948

#### 6503

The IOS operating system needs to support the new "radius server" command, we do not use "radius-server" [link](https://www.cisco.com/c/en/us/support/docs/security-vpn/remote-authentication-dial-user-service-radius/200403-AAA-Server-Priority-explained-with-new-R.html)

### ios_stp_global

#### 3650

#### 3750

#### 2960

#### 4503

#### 4507

#### 4948

This device does not support bridge assurance [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960/software/release/12-2_53_se/configuration/guide/2960scg/swstp.html)

### syslog_settings

Does not implement `vrf` or `time_stamp_units` as described in the netdev_stdlib type definition.

### tacacs_server

#### 2960

#### 3750

The IOS operating system uses the deprecated "tacacs_server" syntax, we cannot use 'unset' functionality for individual fields [link](https://slaptijack.com/networking/new-style-tacacs-configuration/)

### tacacs_global

The IOS operating system does not support:

* enable
* retransmit_count

### ios_additional_syslog_settings

#### 4948

The `origin-id` command is not avalible on th above machine.

## Anomalies in Cisco CLI

### ntp_server

It has been noted that NTP Server configuration may allow multiple entries of the same NTP Server address with different Source Interfaces

For example:
````
ntp server 1.2.3.4 key 42
ntp server 1.2.3.4 key 94 source Vlan42
ntp server 1.2.3.4 key 50 source Loopback42
````
While Puppet Resource will obtain all entries, Puppet Apply compares against the first entry found with the same name.

#### Workaround

Send an ensure 'absent' manifest to remove all ntp servers of the same name, before rebuilding the ntp server configuration:

````Puppet
    ntp_server { '1.2.3.4':
      ensure => 'absent',
    }
````

followed by:

````Puppet
    ntp_server { '1.2.3.4':
      ensure => 'present',
      key => 94,
      prefer => true,
      minpoll => 4,
      maxpoll => 14,
      source_interface => 'Vlan 42',
    }
````

Any edits can be made by referencing the same ntp_server name and source_interface.


# cisco_ios


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with cisco_ios](#setup)
    * [What cisco_ios affects](#what-cisco_ios-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cisco_ios](#beginning-with-cisco_ios)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module allows for the configuration of Cisco Catalyst devices running IOS.

## Setup

### What cisco_ios affects

The Cisco IOS module automatically installs the Telnet-SSH ruby library for communications purposes.

Any changes made by this module are made to the current running-config. Changes may be lost on device reboot unless this is backed up to startup-config.

### Setup Requirements

The Cisco device must have a user set up that is accessible via SSH, and has 'enable mode' privelege.
These details, along with the device IP address or hostname, must be known.

### Beginning with cisco_ios

Please see the wiki - https://github.com/puppetlabs/cisco_ios/wiki - for latest details on how to install and configure the module.

Create credentials file with the known details of the Cisco device eg.

```
  default {
    node {
      address = 10.0.10.20
      username = admin
      port = 22
      password = P@$$w0rd
      enable_password = 3n4bleP@$$w0rd
    }
  }
```

(Note that enable_password key must be supplied even if the user has enable mode privilege, enter any value here)

Create or edit `/etc/puppetlabs/puppet/device.conf` with a target name, type of cisco_ios and file URL of where the credentials file lives eg.

```
[target]
    type cisco_ios
    url file:////etc/puppetlabs/puppet/2690credentials.yaml`
```

Test your setup. For example, if a domain name is configured on the device run:

`puppet device --resource domain_name --target target`

All matching resources should be returned:

```
domain_name { "devices.domain.net":
   ensure => 'present',
 }
```

## Usage

See the wiki for latest usage information: https://github.com/puppetlabs/cisco_ios/wiki

Typically create a manifest with the changes that you wish to apply eg.

```
    ntp_server { '1.2.3.4':
      ensure => 'present',
      key => 94,
      prefer => true,
      minpoll => 4,
      maxpoll => 14,
      source_interface => 'Vlan 42',
    }
```

Run Puppet device apply to apply the changes

`puppet device  --target target --apply manifest.pp `

Run Puppet device resource to obtain the current values

`puppet device --resource --target target ntp_server`

## Reference

### Classes
* [`cisco_ios`](#cisco_ios): 
* [`cisco_ios::install`](#cisco_iosinstall): Private class
### Resource types
* [`domain_name`](#domain_name): Configure the domain name of the device
* [`name_server`](#name_server): Configure the resolver to use the specified DNS server
* [`network_dns`](#network_dns): Configure DNS settings for network devices
* [`network_interface`](#network_interface): Manage physical network interfaces, e.g. Ethernet1
* [`network_snmp`](#network_snmp): Manage snmp location, contact and enable SNMP on the device
* [`network_trunk`](#network_trunk): Ethernet logical (switch-port) interface.  Configures VLAN trunking.
* [`network_vlan`](#network_vlan): Manage VLAN's.  Layer-2 VLAN's are managed by this resource type.
* [`ntp_auth_key`](#ntp_auth_key): NTP Authentication keys
* [`ntp_config`](#ntp_config): Global configuration for the NTP system
* [`ntp_server`](#ntp_server): Specify an NTP server
* [`port_channel`](#port_channel): Network Device Link Aggregation Group
* [`radius`](#radius): Enable or disable radius functionality
* [`radius_global`](#radius_global): Configure global radius settings
* [`radius_server`](#radius_server): Configure a radius server
* [`radius_server_group`](#radius_server_group): Configure a radius server group
* [`search_domain`](#search_domain): Configure the resolver to use the specified search domain
* [`snmp_community`](#snmp_community): Manage the SNMP community
* [`snmp_notification`](#snmp_notification): Enable or disable notification groups and events
* [`snmp_notification_receiver`](#snmp_notification_receiver): Manage an SNMP notification receiver
* [`snmp_user`](#snmp_user): Set the SNMP contact name
* [`syslog_server`](#syslog_server): Configure a remote syslog server for logging
* [`syslog_settings`](#syslog_settings): Configure global syslog settings
* [`tacacs`](#tacacs): Enable or disable tacacs functionality
* [`tacacs_global`](#tacacs_global): Configure global tacacs settings
* [`tacacs_server`](#tacacs_server): Configure a tacacs server
* [`tacacs_server_group`](#tacacs_server_group): Configure a tacacs server group
### Classes

#### cisco_ios

The cisco_ios class.


#### cisco_ios::install

Private class


### Resource types

#### domain_name

Configure the domain name of the device


##### Properties

The following properties are available in the `domain_name` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

##### Parameters

The following parameters are available in the `domain_name` type.

###### `name`

namevar

The domain name of the device


#### name_server

Configure the resolver to use the specified DNS server


##### Properties

The following properties are available in the `name_server` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

##### Parameters

The following parameters are available in the `name_server` type.

###### `name`

namevar

The hostname or address of the DNS server


#### network_dns

Configure DNS settings for network devices


##### Properties

The following properties are available in the `network_dns` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `domain`

The default domain name to append to the device hostname

###### `search`

Array of DNS suffixes to search for FQDN entries

###### `servers`

Array of DNS servers to use for name resolution

##### Parameters

The following parameters are available in the `network_dns` type.

###### `name`

namevar

Name, generally "settings", not used to manage the resource


#### network_interface

Manage physical network interfaces, e.g. Ethernet1


##### Properties

The following properties are available in the `network_interface` type.

###### `enable`

Valid values: `true`, `false`

Enable the interface, true or false

###### `description`

Interface physical port description

###### `mtu`

Interface Maximum Transmission Unit in bytes

###### `speed`

Valid values: auto, 1g, 10g, 40g, 56g, 100g, 100m, 10m

Link speed [auto*|10m|100m|1g|10g|40g|56g|100g]

###### `duplex`

Valid values: auto, full, half

Duplex mode [auto*|full|half]

##### Parameters

The following parameters are available in the `network_interface` type.

###### `name`

namevar

Interface Name, e.g. Ethernet1


#### network_snmp

Manage snmp location, contact and enable SNMP on the device


##### Properties

The following properties are available in the `network_snmp` type.

###### `enable`

Valid values: `true`, `false`

Enable or disable SNMP functionality [true|false]

###### `contact`

The contact name for this device

###### `location`

The location of this device

##### Parameters

The following parameters are available in the `network_snmp` type.

###### `name`

namevar

The name of the Puppet resource, not used to manage the device


#### network_trunk

Ethernet logical (switch-port) interface.  Configures VLAN trunking.


##### Properties

The following properties are available in the `network_trunk` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `encapsulation`

Valid values: dot1q, isl, negotiate, none

The vlan-tagging encapsulation protocol, usually dot1q

###### `mode`

Valid values: access, trunk, dynamic_auto, dynamic_desirable

The L2 interface mode, enables or disables trunking

###### `untagged_vlan`

VLAN used for untagged VLAN traffic. a.k.a Native VLAN

###### `tagged_vlans`

Array of VLAN names used for tagged packets

###### `pruned_vlans`

Array of VLAN ID numbers used for VLAN pruning

##### Parameters

The following parameters are available in the `network_trunk` type.

###### `name`

namevar

The switch interface name, e.g. "Ethernet1"


#### network_vlan

Manage VLAN's.  Layer-2 VLAN's are managed by this resource type.


##### Properties

The following properties are available in the `network_vlan` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `vlan_name`

The VLAN name, e.g. VLAN100

###### `shutdown`

Valid values: `true`, `false`

VLAN shutdown if true, not shutdown if false

###### `description`

The VLAN Description, e.g. 'Engineering'

##### Parameters

The following parameters are available in the `network_vlan` type.

###### `id`

The VLAN ID, e.g. 100


#### ntp_auth_key

NTP Authentication keys


##### Properties

The following properties are available in the `ntp_auth_key` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `algorithm`

Valid values: md5, sha1, sha256

Hash algorithm [md5|sha1|sha256]

###### `mode`

Password mode [0 (plain) | 7 (encrypted)]

###### `password`

Password text

##### Parameters

The following parameters are available in the `ntp_auth_key` type.

###### `name`

namevar

Authentication key ID


#### ntp_config

Global configuration for the NTP system


##### Properties

The following properties are available in the `ntp_config` type.

###### `authenticate`

Valid values: `true`, `false`

NTP authentication enabled [true|false]

###### `source_interface`

The source interface for the NTP system

###### `trusted_key`

Array of global trusted-keys.  Contents can be a String or Integers

##### Parameters

The following parameters are available in the `ntp_config` type.

###### `name`

namevar

Resource name, not used to configure the device


#### ntp_server

Specify an NTP server


##### Properties

The following properties are available in the `ntp_server` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `key`

Authentication key ID

###### `maxpoll`

The maximul poll interval

###### `minpoll`

The minimum poll interval

###### `prefer`

Valid values: `true`, `false`

Prefer this NTP server [true|false]

###### `source_interface`

The source interface used to reach the NTP server

###### `vrf`

The VRF instance this server is bound to.

##### Parameters

The following parameters are available in the `ntp_server` type.

###### `name`

namevar

The hostname or address of the NTP server


#### port_channel

Network Device Link Aggregation Group


##### Properties

The following properties are available in the `port_channel` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `id`

Channel Group ID, e.g. 10

###### `description`

Port Channel description

###### `mode`

Valid values: active, passive, disabled

LACP mode [ passive | active | disabled* ]

###### `interfaces`

Array of Physical Interfaces

###### `minimum_links`

Number of active links required for LAG to be up

###### `speed`

Valid values: auto, 1g, 10g, 40g, 56g, 100g, 100m, 10m

Link speed [auto*|10m|100m|1g|10g|40g|56g|100g]

###### `duplex`

Valid values: auto, full, half

Duplex mode [auto*|full|half]

###### `flowcontrol_send`

Valid values: desired, on, off

Flow control (send) [desired|on|off]

###### `flowcontrol_receive`

Valid values: desired, on, off

Flow control (receive) [desired|on|off]

##### Parameters

The following parameters are available in the `port_channel` type.

###### `name`

namevar

LAG Name

###### `force`

Valid values: `true`, `false`

Force configuration (true / false)


#### radius

Enable or disable radius functionality


##### Properties

The following properties are available in the `radius` type.

###### `enable`

Valid values: `true`, `false`

Enable or disable radius functionality [true|false]

##### Parameters

The following parameters are available in the `radius` type.

###### `name`

namevar

Resource name, not used to manage the device


#### radius_global

Configure global radius settings


##### Properties

The following properties are available in the `radius_global` type.

###### `enable`

Valid values: `true`, `false`

Enable or disable radius functionality [true|false]

###### `key`

Encryption key (plaintext or in hash form depending on key_format)

###### `key_format`

Encryption key format [0-7]

###### `retransmit_count`

How many times to retransmit

###### `source_interface`

The source interface used for RADIUS packets (array of strings for multiple).

###### `timeout`

Number of seconds before the timeout period ends

###### `vrf`

The VRF associated with source_interface (array of strings for multiple).

##### Parameters

The following parameters are available in the `radius_global` type.

###### `name`

namevar

Resource identifier, not used to manage the device


#### radius_server

Configure a radius server


##### Properties

The following properties are available in the `radius_server` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `hostname`

The hostname or address of the radius server

###### `auth_port`

Port number to use for authentication

###### `acct_port`

Port number to use for accounting

###### `key`

Encryption key (plaintext or in hash form depending on key_format)

###### `key_format`

Encryption key format [0-7]

###### `group`

Server group associated with this server

###### `deadtime`

Number of minutes to ignore an unresponsive server

###### `timeout`

Number of seconds before the timeout period ends

###### `vrf`

Interface to send syslog data from, e.g. "management"

###### `source_interface`

Source interface to send syslog data from, e.g. "ethernet 2/1"

###### `retransmit_count`

How many times to retransmit

###### `accounting_only`

Valid values: `true`, `false`

Enable this server for accounting only

###### `authentication_only`

Valid values: `true`, `false`

Enable this server for authentication only

##### Parameters

The following parameters are available in the `radius_server` type.

###### `name`

namevar

The name of the radius server


#### radius_server_group

Configure a radius server group


##### Properties

The following properties are available in the `radius_server_group` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `servers`

Array of servers associated with this group

##### Parameters

The following parameters are available in the `radius_server_group` type.

###### `name`

namevar

The name of the radius server group


#### search_domain

Configure the resolver to use the specified search domain


##### Properties

The following properties are available in the `search_domain` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

##### Parameters

The following parameters are available in the `search_domain` type.

###### `name`

namevar

The search domain to configure in the resolver


#### snmp_community

Manage the SNMP community


##### Properties

The following properties are available in the `snmp_community` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `group`

The SNMP group for this community

###### `acl`

The ACL name to associate with this community string

##### Parameters

The following parameters are available in the `snmp_community` type.

###### `name`

namevar

The name of the community, e.g. "public" or "private"


#### snmp_notification

Enable or disable notification groups and events


##### Properties

The following properties are available in the `snmp_notification` type.

###### `enable`

Valid values: `true`, `false`

Enable or disable the notification [true|false]

##### Parameters

The following parameters are available in the `snmp_notification` type.

###### `name`

namevar

The notification name or "all" for all notifications


#### snmp_notification_receiver

Manage an SNMP notification receiver


##### Properties

The following properties are available in the `snmp_notification_receiver` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `port`

SNMP UDP port number

###### `username`



###### `version`

Valid values: v1, v2, v3

SNMP version [v1|v2|v3]

###### `type`

Valid values: traps, informs

The type of receiver [traps|informs]

###### `security`

Valid values: auth, noauth, priv

SNMPv3 security mode

###### `vrf`

Interface to send SNMP data from, e.g. "management"

###### `source_interface`

Source interface to send SNMP data from, e.g. "ethernet 2/1"

##### Parameters

The following parameters are available in the `snmp_notification_receiver` type.

###### `name`

namevar

Hostname or IP address of the receiver


#### snmp_user

Set the SNMP contact name


##### Properties

The following properties are available in the `snmp_user` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `version`

Valid values: v1, v2, v2c, v3

SNMP version [v1|v2|v2c|v3]

###### `roles`

A list of roles associated with this SNMP user

###### `auth`

Valid values: md5, sha

Authentication mode [md5|sha]

###### `password`

Cleartext password for the user

###### `privacy`

Valid values: aes128, des

Privacy encryption method [aes128|des]

###### `private_key`

Private key in hexadecimal string

###### `engine_id`

Necessary if the SNMP engine is encrypting data

##### Parameters

The following parameters are available in the `snmp_user` type.

###### `name`

namevar

The name of the SNMP user

###### `localized_key`

Valid values: `true`, `false`

If true, password needs to be a hexadecimal value

###### `enforce_privacy`

Valid values: `true`, `false`

If true, message encryption is enforced


#### syslog_server

Configure a remote syslog server for logging


##### Properties

The following properties are available in the `syslog_server` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `port`

Port number of remote syslog server

###### `severity_level`

Syslog severity level to log

###### `vrf`

Interface to send syslog data from, e.g. "management"

###### `source_interface`

Source interface to send syslog data from, e.g. "ethernet 2/1"

##### Parameters

The following parameters are available in the `syslog_server` type.

###### `name`

namevar

The hostname or address of the remote syslog server


#### syslog_settings

Configure global syslog settings


##### Properties

The following properties are available in the `syslog_settings` type.

###### `enable`

Valid values: `true`, `false`

Enable or disable syslog logging [true|false]

###### `console`

Console logging severity level [0-7] or 'unset'

###### `monitor`

Monitor (terminal) logging severity level [0-7] or 'unset'

###### `source_interface`

Source interface to send syslog data from, e.g. "ethernet 2/1" (array of strings for multiple)

###### `time_stamp_units`

Valid values: seconds, milliseconds

The unit to log time values in

###### `vrf`

The VRF associated with source_interface (array of strings for multiple).

##### Parameters

The following parameters are available in the `syslog_settings` type.

###### `name`

namevar

Resource name, not used to configure the device


#### tacacs

Enable or disable tacacs functionality


##### Properties

The following properties are available in the `tacacs` type.

###### `enable`

Valid values: `true`, `false`

Enable or disable tacacs functionality [true|false]

##### Parameters

The following parameters are available in the `tacacs` type.

###### `name`

namevar

Resource name, not used to manage the device


#### tacacs_global

Configure global tacacs settings


##### Properties

The following properties are available in the `tacacs_global` type.

###### `enable`

Valid values: `true`, `false`

Enable or disable radius functionality [true|false]

###### `key`

Encryption key (plaintext or in hash form depending on key_format)

###### `key_format`

Encryption key format [0-7]

###### `retransmit_count`

How many times to retransmit

###### `source_interface`

The source interface used for TACACS packets (array of strings for multiple).

###### `timeout`

Number of seconds before the timeout period ends

###### `vrf`

The VRF associated with source_interface (array of strings for multiple).

##### Parameters

The following parameters are available in the `tacacs_global` type.

###### `name`

namevar

Resource identifier, not used to manage the device


#### tacacs_server

Configure a tacacs server


##### Properties

The following properties are available in the `tacacs_server` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `hostname`

The hostname or address of the tacacs server

###### `single_connection`

Valid values: `true`, `false`

Enable or disable session multiplexing [true|false]

###### `vrf`

specifies the VRF instance used to communicate with the server

###### `port`

The port of the tacacs server

###### `key`

Encryption key (plaintext or in hash form depending on key_format)

###### `key_format`

Encryption key format [0-7]

###### `timeout`

Number of seconds before the timeout period ends

###### `group`

Server group associated with this server

##### Parameters

The following parameters are available in the `tacacs_server` type.

###### `name`

namevar

The name of the tacacs server group


#### tacacs_server_group

Configure a tacacs server group


##### Properties

The following properties are available in the `tacacs_server_group` type.

###### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

###### `servers`

Array of servers associated with this group

##### Parameters

The following parameters are available in the `tacacs_server_group` type.

###### `name`

namevar

The name of the tacacs server group




## Limitations

The following devices have been tested against this module, with the type compatibilities listed.

Note that this is *not* an exhaustive list of supported devices, but rather the results found from execution across a cross section of devices.

  | Resource | 2960 | 3750 | 6503 |
  | --- | --- | --- | --- |
  | domain_name | ok | ok | ok |
  | name_server | ok | ok | ok |
  | network_dns | ok | ok | ok | 
  | network_interface | ok | ok | ok |
  | network_snmp | ok | ok | ok |
  | network_trunk | not ok | ok | ok |
  | network_vlan | ok | ok | ok |
  | ntp_auth_key | not ok | ok | ok |
  | ntp_config | ok | ok | ok |
  | ntp_server | ok | ok | ok |
  | port_channel | not supported | not supported | not supported |
  | radius | not supported | not supported | not supported |
  | radius_global | ok | ok | ok |
  | radius_server | ok | not supported | not supported |
  | radius_server_group | ok | ok | ok |
  | search_domain | ok | ok | ok |
  | snmp_community | ok | ok | ok |
  | snmp_notification | ok | ok | ok |
  | snmp_notification_receiver | ok | ok | ok |
  | snmp_user | ok | ok | ok |
  | syslog_server | ok | ok | ok |
  | syslog_settings | ok | ok | ok |
  | tacacs | not supported | not supported | not supported |
  | tacacs_global | ok | ok | ok |
  | tacacs_server | ok | not supported | not supported |
  | tacacs_server_group | ok | ok | ok |

## Development

Contributions are welcomed, especially if they can be of use to other users.

Checkout the repo by forking https://github.com/puppetlabs/cisco_ios and creating your feature branch.

Prior to development, copy the types from netdev standard library https://github.com/puppetlabs/netdev_stdlib/tree/master/lib/puppet/type to the `/lib/puppet/types` directory.

### Type

Typically existing types from the netdev standard library are utilised.
Copy the type definition to Resource API format, use existing examples for guidance eg.

```
require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_old_netdev_type

  # Existing netdev type
  Puppet::Type.newtype(:domain_name) do
    @doc = 'Configure the domain name of the device'

    apply_to_all
    ensurable

    newparam(:name, namevar: true) do
      desc 'The domain name of the device'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end
  end
  # End of existing netdev type

else
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'domain_name',
    docs: 'Configure the domain name of the device',
    features: ['remote_resource'],
    attributes: {
      ensure:       {
        type:       'Enum[present, absent]',
        desc:       'Whether the name server should be present or absent on the target system.',
        default:    'present',
      },
      name:         {
        type:      'String',
        desc:      'The domain name of the device',
        behaviour: :namevar,
      },
    },
  )
end
```

### Provider

Add a provider - see existing examples.
Parsing logic is contained in `ios.rb`.
Regular expressions for parsing, getting and setting values are contained within `command.yaml`.

### Modes

If the new provider requires accessing a CLI "mode" eg. Interface `(config-if)`, add this as a new mode state to `device.rb` and associated prompt to `command.yaml`.

### Testing

There are 2 levels of testing found under `spec`

#### Unit Testing

Unit tests test the parsing and command generation logic executed locally. Specs typically iterate over `read_tests` and `update_tests` which contain testing values within `test_data.yaml`

Execute with `bundle exec rake spec`

#### Acceptance Testing

Acceptance tests are executed on actual devices.

Use test values and make sure that these are non-destructive.

Typically the following flow is used:

- Remove any existing entry as test setup
- Test adding
- Test editing with as many values as possible
- Test removing 

Any other logic or values that can be tested should be added as appropriate.

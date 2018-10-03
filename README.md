
# cisco_ios


#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with cisco_ios](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cisco_ios](#beginning-with-cisco_ios)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Module Description

The Cisco IOS module allows for the configuration of Cisco Catalyst devices running IOS.

This module automatically installs the Telnet-SSH ruby library for communication purposes.

Any changes made by this module affect the current `running-config`. These changes will lost on device reboot unless they are backed up to `startup-config`. This module provides a Puppet task to save `running-config` to `startup-config`.

## Setup

### Setup Requirements

This module requires a user that can access the device via SSH and that has the `enable mode` privilege.

### Beginning with cisco_ios

To get started, create or edit `/etc/puppetlabs/puppet/device.conf`, add a section for the device (this will become the device's `certname`), specify a type of `cisco_ios`, and specify a `url` to a credentials file. For example:

```INI
[cisco.example.com]
type cisco_ios
url file:////etc/puppetlabs/puppet/devices/cisco.example.com.conf`
```

Next, create a credentials file, following the [HOCON documentation](https://github.com/lightbend/config/blob/master/HOCON.md) regarding quoted/unquoted strings, with connection information for the device. For example:

```
address = 10.0.10.20
username = admin
port = 22
password = "P@$$w0rd"
enable_password = "3n4bleP@$$w0rd"
```

The following additional fields are optional:

`verify_host_key` By default this is true. Setting to false will disable the verification of the SSH host fingerprint.
**Note** Disabling this has security risks and should be done only after considering the implications.

`known_hosts_file` By default this is set to within the vardir eg. `/opt/puppetlabs/puppet/cache/devices/cisco.example.com/ssl/known_hosts`. You can specify your own SSH known hosts file here.

Note that the `enable_password` key must be supplied even if the user has the `enable mode` privilege. Enter any value here.

Test your setup. For example:

`puppet device --verbose --target cisco.example.com`

#### Signing Certificates

The first run of `puppet device` for a device will generate a certificate request:

```bash
Info: Creating a new SSL key for cisco.example.com
Info: Caching certificate for ca
Info: csr_attributes file loading from /opt/puppetlabs/puppet/cache/devices/cisco.example.com/csr_attributes.yaml
Info: Creating a new SSL certificate request for cisco.example.com
Info: Certificate Request fingerprint (SHA256): ...
Info: Caching certificate for ca
```

Unless [autosign](https://puppet.com/docs/puppet/latest/ssl_autosign.html) is enabled, the following (depending upon `waitforcert`) will be output:

```bash
Notice: Did not receive certificate
Notice: Did not receive certificate
Notice: Did not receive certificate
...
```

Or:

```bash
Exiting; no certificate found and waitforcert is disabled
```

On the master, execute the following to sign the certificate for the device:

* Puppet 6 or later

```bash
puppetserver ca sign --certname cisco.example.com
```

This will output that the certificate for the device has been signed:

```bash
Successfully signed certificate request for cisco.example.com
```

* Earlier versions of Puppet

```bash
puppet cert sign cisco.example.com
```

This will output that the certificate for the device has been signed:

```bash
Signing Certificate Request for:
  "cisco.example.com" (SHA256) ...
Notice: Signed certificate request for cisco.example.com
Notice: Removing file Puppet::SSL::CertificateRequest cisco.example.com at '/etc/puppetlabs/puppet/ssl/ca/requests/cisco.example.com.pem'
```

**Note (Security Warning)** The SSH server key, and hence its identity, will not be verified during the first connection attempt. Please follow up by verifying the SSH key for the device is correct. The fingerprint will be added to the known hosts file. By default this is the device cache directory eg. `/opt/puppetlabs/puppet/cache/devices/cisco.example.com/ssl/known_hosts`.
This can be changed by setting the `known_hosts_file` value in the credentials file, see above.

## Usage

Create a manifest with the changes you want to apply. For example:

```Puppet
    ntp_server { '1.2.3.4':
      ensure => 'present',
      key => 94,
      prefer => true,
      minpoll => 4,
      maxpoll => 14,
      source_interface => 'Vlan 42',
    }
```

> Note: The `--apply` and `--resource` options are only available with Puppet agent 5.5.0 and higher.

Run Puppet device apply to apply the changes:

`puppet device  --target cisco.example.com --apply manifest.pp `

Run Puppet device resource to obtain the current values:

`puppet device --resource --target cisco.example.com ntp_server`

## Reference

Please see the netdev_stdlib docs https://github.com/puppetlabs/netdev_stdlib/blob/master/README.md

### Classes
* [`cisco_ios`](#cisco_ios):
* [`cisco_ios::install`](#cisco_iosinstall): Private class

### Resource types
* [`ios_aaa_accounting`](#ios_aaa_accounting): Configure aaa accounting on device
* [`ios_aaa_authentication`](#ios_aaa_authentication): Configure aaa authentication on device
* [`ios_aaa_authorization`](#ios_aaa_authorization): Configure aaa authorization on device
* [`ios_aaa_new_model`](#ios_aaa_new_model): Enable aaa new model on device
* [`ios_aaa_session_id`](#ios_aaa_session_id): Configure aaa session id on device
* [`ios_config`](#ios_config): Execute an arbitrary configuration against the cisco_ios device with or without a check for idempotency.
* [`ios_stp_global`](#ios_stp_global): Manages the Cisco Spanning-tree Global configuration resource.

#### cisco_ios

The cisco_ios class.

#### cisco_ios::install

Private class.

#### ios_config

Execute an arbitrary configuration against the cisco_ios device with or without a check for idempotency

##### attributes

The following attributes are available in the `ios_config` type.

###### `name`

namevar

The friendly name for this ios command.

###### `command`

The ios command to run.

###### `command_mode`

Valid values: CONF_T.

The command line mode to be in, when executing the command

Default value: CONF_T.

###### `idempotent_regex`

Expected string, when running a regex against the 'show running-config'.

###### `idempotent_regex_options`

Array of one or more options which control how the pattern can match.

Allowed values: ['ignorecase', 'extended', 'multiline', 'fixedencoding', 'noencoding']

###### `negate_idempotent_regex`

Boolean

Negate the regex used with idempotent_regex.

Default value: false.

### ios_aaa_accounting

Configure aaa accounting on device

#### Properties

The following properties are available in the `ios_aaa_accounting` type.

##### `ensure`

Data type: `Enum[present, absent]`

Whether this aaa accounting should be present or absent on the target system.

Default value: present

##### `accounting_service`

Data type: `Enum["auth-proxy","commands","connection","dot1x","exec","network","resource"]`

AAA Accounting service to use

##### `commands_enable_level`

Data type: `Optional[Integer]`

Enable level - needed for "commands" accounting_service

##### `accounting_list`

Data type: `String`

The accounting list - named or default

Default value: default

##### `accounting_status`

Data type: `Enum["none","start-stop","stop-only"]`

The status of the accounting

##### `server_groups`

Data type: `Optional[Array[String]]`

Array of the server groups eg. `['tacacs+'], ['test1', 'test2']`

#### Parameters

The following parameters are available in the `ios_aaa_accounting` type.

##### `name`

namevar

Data type: `String`

Name. On resource this is a composite of the authorization_service (and enable level if "commands") and authorization_list name eg. "commands_15_default" or "exec_authlist1"

Default value: default

### ios_aaa_authentication

Configure aaa authentication on device

#### Properties

The following properties are available in the `ios_aaa_authentication` type.

##### `ensure`

Data type: `Enum[present, absent]`

Whether this aaa authentication should be present or absent on the target system.

Default value: present

##### `authentication_list_set`

Data type: `Enum["arap","login","enable","dot1x","eou","ppp","sgbp"]`

Set authentication lists for - Login, Enable or dot1x

##### `authentication_list`

Data type: `String`

The authentication list - named or default

Default value: default

##### `server_groups`

Data type: `Optional[Array[String]]`

Array of the server groups eg. `['tacacs+'], ['test1', 'test2']`

##### `enable_password`

Data type: `Optional[Boolean]`

Use enable password for authentication.

##### `local`

Data type: `Optional[Boolean]`

Use local username authentication.

##### `switch_auth`

Data type: `Optional[Boolean]`

Switch authentication.

#### Parameters

The following parameters are available in the `ios_aaa_authentication` type.

##### `name`

namevar

Data type: `String`

Name. On resource this is a composite of the authentication_list_set and authentication_list name eg. "login_default"

Default value: default

### ios_aaa_authorization

Configure aaa authorization on device

#### Properties

The following properties are available in the `ios_aaa_authorization` type.

##### `ensure`

Data type: `Enum[present, absent]`

Whether this aaa authorization should be present or absent on the target system.

Default value: present

##### `authorization_service`

Data type: `Enum["auth-proxy","commands","configuration","exec","network","reverse_access"]`

AAA Authorization service to use

##### `commands_enable_level`

Data type: `Optional[Integer]`

Enable level - needed for "commands" authorization_service

##### `authorization_list`

Data type: `String`

The authorization list - named or default

Default value: default

##### `server_groups`

Data type: `Optional[Array[String]]`

Array of the server groups eg. `['tacacs+'], ['test1', 'test2']`

##### `local`

Data type: `Optional[Boolean]`

Use local database.

##### `if_authenticated`

Data type: `Optional[Boolean]`

Succeed if user has authenticated.

#### Parameters

The following parameters are available in the `ios_aaa_authorization` type.

##### `name`

namevar

Data type: `String`

Name. On resource this is a composite of the authorization_service (and enable level if "commands") and authorization_list name eg. "commands_15_default" or "exec_authlist1"

Default value: default

### ios_aaa_new_model

Enable aaa new model on device

#### Properties

The following properties are available in the `ios_aaa_new_model` type.

##### `enable`

Data type: `Boolean`

Enable or disable aaa new model

#### Parameters

The following parameters are available in the `ios_aaa_new_model` type.

##### `name`

namevar

Data type: `String`

The name stays as "default"

Default value: default

### ios_aaa_session_id

Configure aaa session id on device

#### Properties

The following properties are available in the `ios_aaa_session_id` type.

##### `session_id_type`

Data type: `Enum["common","unique"]`

Type of aaa session id - common or unique

#### Parameters

The following parameters are available in the `ios_aaa_session_id` type.

##### `name`

namevar

Data type: `String`

The name stays as "default"

Default value: default

### ios_stp_global

Manages the Cisco Spanning-tree Global configuration resource.

#### Properties

The following properties are available in the `ios_stp_global` type.

##### `enable`

Data type: `Optional[Boolean]`

Enable or disable STP functionality [true|false]

##### `bridge_assurance`

Data type: `Optional[Boolean]`

Bridge Assurance on all network ports

##### `loopguard`

Data type: `Optional[Boolean]`

Bridge Assurance on all network ports

##### `mode`

Data type: `Optional[Enum["mst","pvst","rapid-pvst"]]`

Operating Mode

##### `mst_forward_time`

Data type: `Optional[Integer]`

Forward delay for the spanning tree

##### `mst_hello_time`

Data type: `Optional[Integer]`

Hello interval for the spanning tree

##### `mst_inst_vlan_map`

Data type: `Optional[Array[Tuple[Integer,String]]]`

An array of [mst_inst, vlan_range] pairs.

##### `mst_max_age`

Data type: `Optional[Integer[6,40]]`

Max age interval for the spanning tree

##### `mst_max_hops`

Data type: `Optional[Integer[1,255]]`

Max hops value for the spanning tree

##### `mst_name`

Data type: `Optional[String]`

Configuration name.

##### `mst_priority`

Data type: `Optional[Array[Tuple[String,Integer]]]`

An array of [mst_inst_list, priority] pairs.

##### `mst_revision`

Data type: `Optional[Integer]`

Configuration revision number.

##### `pathcost`

Data type: `Optional[Enum["long","short"]]`

Method to calculate default port path cost

##### `vlan_forward_time`

Data type: `Optional[Array[Tuple[String,Integer]]]`

An array of [vlan_inst_list, forward_time] pairs.

##### `vlan_hello_time`

Data type: `Optional[Array[Tuple[String,Integer]]]`

An array of [vlan_inst_list, hello_time] pairs.

##### `vlan_max_age`

Data type: `Optional[Array[Tuple[String,Integer]]]`

An array of [vlan_inst_list, max_age] pairs.

##### `vlan_priority`

Data type: `Optional[Array[Tuple[String,Integer]]]`

An array of [vlan_inst_list, priority] pairs.

#### Parameters

The following parameters are available in the `ios_stp_global` type.

##### `name`

namevar

Data type: `String`

ID of the stp global config. Valid values are default.

Default value: default

## Limitations

The following devices have been tested against this module — with the type compatibilities listed.

Note that this is *not* an exhaustive list of supported devices, but rather the results found from execution across a cross section of the devices that we use for internal testing.

### Devices used in testing
| Device Type | IOS Version |
| --- | --- |
| 2960 | Cisco IOS Software, C2960S Software (C2960S-UNIVERSALK9-M), Version 12.2(58)SE2, RELEASE SOFTWARE (fc1) |
| 3750 | Cisco IOS Software, C3750 Software (C3750-IPSERVICESK9-M), Version 12.2(55)SE10, RELEASE SOFTWARE (fc2) |
| 4507r | Cisco IOS Software, Catalyst 4000 L3 Switch Software (cat4000-I5K91S-M), Version 12.2(25)EWA9, RELEASE SOFTWARE (fc3) |
| 4948 | Cisco IOS Software, Catalyst 4500 L3 Switch Software (cat4500-ENTSERVICESK9-M), Version 12.2(37)SG1, RELEASE SOFTWARE (fc2) |
| 6503 | Cisco IOS Software, s72033_rp Software (s72033_rp-IPSERVICESK9_WAN-M), Version 12.2(33)SXJ10, RELEASE SOFTWARE (fc3) |

### Resources vs Device type
| Resource | 2960 | 3750 | 4507r | 4948 | 6503 |
| --- | --- | --- | --- | --- | --- |
| banner | ok | ok | ok | ok | ok |
| domain_name | use network_dns | use network_dns | use network_dns | use network_dns | use network_dns |
| ios_config | ok | ok | ok | ok | ok |
| ios_stp_global | ok* | ok* | ok* | ok* | ok |
| name_server | use network_dns | use network_dns | use network_dns | use network_dns | use network_dns |
| network_dns | ok | ok | ok | ok | ok |
| network_interface | ok* | ok* | ok | ok | ok |
| network_snmp | ok | ok | ok | ok | ok |
| network_trunk | ok* | ok | ok | ok | ok |
| network_vlan | ok | ok | ok | ok | ok |
| ntp_auth_key | ok | ok | ok | ok | ok |
| ntp_config | ok | ok | ok | ok | ok |
| ntp_server | ok | ok* | ok | ok* | ok |
| port_channel | ok | ok* | ok* | ok | ok |
| radius | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS |
| radius_global* | ok | ok | ok | ok | ok |
| radius_server | ok | not supported | ok | ok | not supported |
| radius_server_group | ok | ok | ok | ok | ok |
| search_domain | use network_dns | use network_dns | use network_dns | use network_dns | use network_dns |
| snmp_community | ok | ok | ok | ok | ok |
| snmp_notification | ok | ok | ok | ok | ok |
| snmp_notification_receiver | ok | ok | ok | ok | ok |
| snmp_user | ok | ok | ok | ok | ok |
| syslog_server | ok | ok | ok | ok | ok |
| syslog_settings | ok | ok | ok | ok | ok |
| tacacs | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS | not supported by IOS |
| tacacs_global* | ok | ok | ok | ok | ok |
| tacacs_server | ok | ok | ok | ok | ok |
| tacacs_server_group | ok | ok | ok | ok | ok |

Cells marked with the * have deviations. See the section below for details.

### Deviations

#### network_interface

##### 2960

The switch does not support the MTU on a per-interface basis. It does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960/software/release/15-2_2_e/configuration/guide/b_1522e_2960_2960c_2960s_2960sf_2960p_cg/b_1522e_2960_2960c_2960s_2960sf_2960p_cg_chapter_01001.html)

* mtu

##### 3750

The switch does not support the MTU on a per-interface basis. It does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750/software/release/12-2_55_se/configuration/guide/scg3750/swint.html)

* mtu

#### network_trunk

##### 2960

This device does not have native trunking. It does not support the following attributes: [link](https://learningnetwork.cisco.com/thread/75947)

* ensure
* encapsulation

#### ntp_server

##### 3750

Does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750x_3560x/software/release/12-2_55_se/configuration/guide/3750xscg/swadmin.html)

* minpoll
* maxpoll

##### 4948

Does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst4500/12-2/31sga/configuration/guide/config/swadmin.html)

* minpoll
* maxpoll

##### 4507

Does not support the following attributes: [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst4500/12-2/31sga/configuration/guide/config/swadmin.html#wp1245750)

* minpoll
* maxpoll

#### port_channel

##### 3750

##### 4507

This device does not have native trunking. It does not support the following attributes: [link](https://learningnetwork.cisco.com/thread/75947)

* flowcontrol_send

#### radius_global

The IOS operating system does not support:

* enable

#### radius_server

##### 3750

##### 6503

The IOS operating system needs to support the new "radius server" command, we do not use "radius-server" [link](https://www.cisco.com/c/en/us/support/docs/security-vpn/remote-authentication-dial-user-service-radius/200403-AAA-Server-Priority-explained-with-new-R.html)

#### ios_stp_global

##### 3750

##### 2960

##### 4507

##### 4948

This device does not support bridge assurance [link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960/software/release/12-2_53_se/configuration/guide/2960scg/swstp.html)

#### tacacs_server

##### 2960

##### 3750

The IOS operating system uses the deprecated "tacacs_server" syntax, we cannot use 'unset' functionality for individual fields [link](https://slaptijack.com/networking/new-style-tacacs-configuration/)

#### tacacs_global

The IOS operating system does not support:

* enable
* retransmit_count

### Anomalies in Cisco CLI

#### ntp_server

It has been noted that NTP Server configuration may allow multiple entries of the same NTP Server address with different Source Interfaces

For example:
````
ntp server 1.2.3.4 key 42
ntp server 1.2.3.4 key 94 source Vlan42
ntp server 1.2.3.4 key 50 source Loopback42
````
While Puppet Resource will obtain all entries, Puppet Apply compares against the first entry found with the same name.

##### Workaround

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

## Development

Contributions are welcome, especially if they can be of use to other users.

Checkout the [repo](https://github.com/puppetlabs/cisco_ios) by forking and creating your feature branch.

Prior to development, copy the types from the [netdev standard library](https://github.com/puppetlabs/netdev_stdlib/tree/master/lib/puppet/type) to the `/lib/puppet/types` directory.

See the [command guide for IOS](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/bsm/command/bsm-cr-book.html).

### Type

Add new types to the type directory.
We use the [Resource API format](https://github.com/puppetlabs/puppet-resource_api/blob/master/README.md)
Use the bundled ios_config example for guidance. Here is a simple example:

```Ruby
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'new_thing',
    docs: 'Configure the new thing of the device',
    features: ['remote_resource'],
    attributes: {
      ensure:       {
        type:       'Enum[present, absent]',
        desc:       'Whether the new thing should be present or absent on the target system.',
        default:    'present',
      },
      name:         {
        type:      'String',
        desc:      'The name of the new thing',
        behaviour: :namevar,
      },
      # Other fields in resource API format
    },
  )

```

### Provider

Add a provider — see existing examples. Parsing logic is contained in `ios.rb`. Regular expressions for parsing, getting and setting values, are contained within `command.yaml`.

### Modes

If the new provider requires accessing a CLI "mode", for example, Interface `(config-if)`, add this as a new mode state to `device.rb` and an associated prompt to `command.yaml`.

### Testing

There are 2 levels of testing found under `spec`.

#### Unit Testing

Unit tests test the parsing and command generation logic executed locally. Specs typically iterate over `read_tests` and `update_tests`, which contain testing values within `test_data.yaml`.

Execute with `bundle exec rake spec`.

#### Acceptance Testing

Acceptance tests are executed on actual devices.

Use test values and make sure that these are non-destructive.

Typically, the following flow is used:

- Remove any existing entry
- Add test
- Edit test — with as many values as possible
- Remove test

Any other logic or values that can be tested should be added, as appropriate.

##### Executing

Ensure that the IP address/hostname, username, password and enable password are specified as environment variables from your execution environment, for example:

```
export DEVICE_IP=10.0.10.20
export DEVICE_USER=admin
export DEVICE_PASSWORD="devicePa$$w0rd"
export DEVICE_ENABLE_PASSWORD="enablePa$$w0rd"
```

Execute the acceptance test suite with the following command:

`BEAKER_provision=yes PUPPET_INSTALL_TYPE=pe BEAKER_set=vmpooler bundle exec rspec spec/acceptance/`


# cisco_ios

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with cisco_ios](#setup)
    * [What cisco_ios affects](#what-cisco_ios-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cisco_ios with bolt](#beginning-with-cisco_ios-with-bolt)
    * [Beginning with cisco_ios with Puppet](#beginning-with-cisco_ios-with-puppet)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Module Description

The Cisco IOS module allows for the configuration of Cisco Catalyst devices running IOS and IOS-XE.

Any changes made by this module affect the current `running-config`. These changes will lost on device reboot unless they are backed up to `startup-config`. This module provides a Puppet task to save `running-config` to `startup-config`.

## Setup

### What cisco_ios affects

This module installs the Net::SSH::Telnet gem; and Puppet Resource API gem, if necessary. To activate the Puppet Resource API gem, a reload of the puppetserver service is necessary. In most cases, this should happen automatically and cause little to no interruption to service.

### Setup Requirements

#### Device access

This module requires a user that can access the device via SSH and that has the `enable mode` privilege.

#### Proxy Puppet agent

Since a Puppet agent is not available for the Catalysts (and, seriously, who would want to run an agent on them?) we need a proxy Puppet agent (either a compiler, or another agent) to run Puppet on behalf of the device.

#### Install dependencies

To install dependencies of the Cisco IOS module:

1. Classify or apply the `cisco_ios` class on each server (server of servers, and if present, compilers and replica servers) that serves catalogs for this module.
1. Classify or apply the `cisco_ios` class on each proxy Puppet agent that proxies for Cisco IOS devices.

Run puppet agent -t on the server(s) before using the module on the agent(s).

### Beginning with cisco_ios with Bolt

Check out the [Hands-on Lab](https://github.com/puppetlabs/cisco_ios/tree/main/docs/README.md) for getting started with bolt.

### Beginning with cisco_ios with Puppet

To get started, create or edit `/etc/puppetlabs/puppet/device.conf` on the proxy Puppet agent, add a section for the device (this will become the device's `certname`), specify a type of `cisco_ios`, and specify a `url` to a credentials file.

For example:

```INI
[cisco.example.com]
type cisco_ios
url file:////etc/puppetlabs/puppet/devices/cisco.example.com.conf`
```

The credentials file must contain a hash in [HOCON format](https://github.com/lightbend/config/blob/main/HOCON.md) that matches the schema defined in [lib/puppet/transport/schema/cisco_ios.rb](lib/puppet/transport/schema/cisco_ios.rb) for example:

```
host:            "10.0.0.246"
port:            22
user:            admin
password:        password
enable_password: password
```

To automate the creation of these files, use the [device_manager](https://forge.puppet.com/puppetlabs/device_manager) module, the `credentials` section should follow the schema as described above:

```puppet
device_manager { 'cisco.example.com':
  type        => 'cisco_ios',
  credentials => {
    host            => '10.0.0.246',
    port            => 22,
    user            => 'admin',
    password        => 'password',
    enable_password => 'password',
  },
}
```

(Using the `device_manager` module will also automatically classify the proxy Puppet agent with the `cisco_ios` class.)

#### Test your setup

Run `puppet device` on the proxy Puppet agent. For example:

`puppet device --verbose --target cisco.example.com`

#### Signing certificates

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

On the server, execute the following to sign the certificate for the device:

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
This can be changed by setting the `known_hosts_file` value in the [credentials](#credentials) file.

## Usage

Create a manifest with the changes you want to apply. For example:

```puppet
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

Run `puppet device --apply` on the proxy Puppet agent to apply the changes:

`puppet device  --target cisco.example.com --apply manifest.pp `

Run `puppet device --resource` on the proxy Puppet agent to obtain the current values:

`puppet device --target cisco.example.com --resource ntp_server`

### Tasks

To save the running config, it is possible to use the `cisco_ios::config_save` task. Before running this task, install the module on your machine, along with [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html). When complete, execute the following command:

```
bolt task run cisco_ios::config_save --nodes ios --modulepath <module_installation_dir> --inventoryfile <inventory_yaml_path>
```

The following [inventory file](https://puppet.com/docs/bolt/latest/inventory_file.html) can be used to connect to your switch.

```yaml
# inventory.yaml
nodes:
  - name: cisco.example.com
    alias: ios
    config:
      transport: remote
      remote:
        remote-transport: cisco_ios
        user: admin
        password: password
        enable_password: password
```

The `--modulepath` param can be retrieved by typing `puppet config print modulepath`.

> NOTE: If you have only bolt installed, `puppet config print` does not exist. See [https://puppet.com/docs/bolt/latest/installing_tasks_from_the_forge.html#task-8928](https://puppet.com/docs/bolt/latest/installing_tasks_from_the_forge.html#task-8928) on how bolt can be used to install modules into your boltdir.

### Type

Add new types to the type directory.
We use the [Resource API format](https://github.com/puppetlabs/puppet-resource_api/blob/main/README.md)
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

If the new provider requires accessing a CLI "mode", for example, Interface `(config-if)`, add this as a new mode state to [`Puppet::Transport::CiscoIos`](lib/puppet/transport/cisco_ios.rb) and an associated prompt to [`command.yaml`](lib/puppet/transport/command.yaml).

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

```
bundle exec rspec spec/acceptance/
```

### References

Generated documentation is available in [REFERENCE.md](REFERENCE.md). If you need to generate this again for any reason, run the following command:

```
bundle exec puppet strings generate --format markdown --out REFERENCE.md
```
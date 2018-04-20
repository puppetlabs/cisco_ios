
# cisco_ios

Welcome to your new module. A short overview of the generated parts can be found in the PDK documentation at https://puppet.com/pdk/latest/pdk_generating_modules.html .

The README template below provides a starting point with details about what information to include in your README.

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

Start with a one- or two-sentence summary of what the module does and/or what problem it solves. This is your 30-second elevator pitch for your module. Consider including OS/Puppet version it works with.

You can give more descriptive information in a second paragraph. This paragraph should answer the questions: "What does this module *do*?" and "Why would I use it?" If your module has a range of functionality (installation, configuration, management, etc.), this is the time to mention it.

## Setup

### What cisco_ios affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For example, folks can probably figure out that your mysql_instance module affects their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* Files, packages, services, or operations that the module will alter, impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled, another module, etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps for upgrading, you might want to include an additional "Upgrading" section here.

### Beginning with cisco_ios

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the fancy stuff with your module here. It's especially helpful if you include usage examples and code samples for doing things with your module.

## Reference

Users need a complete list of your module's classes, types, defined types providers, facts, and functions, along with the parameters for each. You can provide this list either via Puppet Strings code comments or as a complete list in the README Reference section.

* If you are using Puppet Strings code comments, this Reference section should include Strings information so that your users know how to access your documentation.

* If you are not using Puppet Strings, include a list of all of your classes, defined types, and so on, along with their parameters. Each element in this listing should include:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there are Known Issues, you might want to include them under their own heading here.

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
| port_channel | ok | ok | ok |
| radius | ok | ok | ok |
| radius_global | ok | ok | ok |
| radius_server | ok | pending | pending |
| radius_server_group | ok | ok | ok |
| search_domain | ok | ok | ok |
| snmp_community | ok | ok | ok |
| snmp_notification | ok | ok | ok |
| snmp_notification_receiver | ok | ok | ok |
| snmp_user | ok | ok | ok |
| syslog_server | ok | ok | ok |
| syslog_settings | ok | ok | ok |
| tacacs | ok | ok | ok |
| tacacs_global | ok | ok | ok |
| tacacs_server | ok | pending | not ok |
| tacacs_server_group | ok | ok | ok |

## Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.

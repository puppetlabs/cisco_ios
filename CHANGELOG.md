# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v1.2.0](https://github.com/puppetlabs/cisco_ios/tree/v1.2.0) (2019-11-21)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/1.1.0...v1.2.0)

### Added

- \(FM-8572\) - Addition of `route\_cache\_cef` to `ios\_interface` [\#409](https://github.com/puppetlabs/cisco_ios/pull/409) ([david22swan](https://github.com/david22swan))
- \(FM-8572\) - Addition of type ios\_cef [\#408](https://github.com/puppetlabs/cisco_ios/pull/408) ([david22swan](https://github.com/david22swan))
- \(FM-8572\) - Addition of type ios\_ip [\#404](https://github.com/puppetlabs/cisco_ios/pull/404) ([david22swan](https://github.com/david22swan))
- \(FM-8608\) - Addition of attribute `directed\_request` to `tacacs\_global` [\#403](https://github.com/puppetlabs/cisco_ios/pull/403) ([david22swan](https://github.com/david22swan))
- \(FM-8607\) - logging attribute added to ios\_ntp\_config [\#402](https://github.com/puppetlabs/cisco_ios/pull/402) ([david22swan](https://github.com/david22swan))
- \(FM-8576\) - Addition of support for `source\_interface` and `vrf` to `tacacs\_server\_group` [\#401](https://github.com/puppetlabs/cisco_ios/pull/401) ([david22swan](https://github.com/david22swan))
- \(FM-8501\) Add vrf support to ios\_interface [\#397](https://github.com/puppetlabs/cisco_ios/pull/397) ([MaxMagill](https://github.com/MaxMagill))
- \(FM-8500\) Add vrf provider [\#393](https://github.com/puppetlabs/cisco_ios/pull/393) ([MaxMagill](https://github.com/MaxMagill))
- Add vrf support to SNMP Notification Receiver [\#387](https://github.com/puppetlabs/cisco_ios/pull/387) ([MaxMagill](https://github.com/MaxMagill))
- \(FM-8436\) - Implementation of vrf for syslog\_server [\#383](https://github.com/puppetlabs/cisco_ios/pull/383) ([david22swan](https://github.com/david22swan))

### Fixed

- \(MODULES-10058\) - ntp-server fix [\#407](https://github.com/puppetlabs/cisco_ios/pull/407) ([david22swan](https://github.com/david22swan))
- \(FM-8705\) - Exclusions added for Cisco-3560 [\#406](https://github.com/puppetlabs/cisco_ios/pull/406) ([david22swan](https://github.com/david22swan))
- \(maint\) Exclusion fixes [\#400](https://github.com/puppetlabs/cisco_ios/pull/400) ([MaxMagill](https://github.com/MaxMagill))
- \(maint\) Remove Mgm-vrf and add VRF ModeState [\#398](https://github.com/puppetlabs/cisco_ios/pull/398) ([MaxMagill](https://github.com/MaxMagill))
- \(FM-8435\) - Exclude a VRF from being set in tacacs\_global [\#396](https://github.com/puppetlabs/cisco_ios/pull/396) ([david22swan](https://github.com/david22swan))
- \(maint\) - Additional Fix for vrf type [\#395](https://github.com/puppetlabs/cisco_ios/pull/395) ([david22swan](https://github.com/david22swan))
- \(maint\) - Fix for vrf type [\#394](https://github.com/puppetlabs/cisco_ios/pull/394) ([david22swan](https://github.com/david22swan))
- \(maint\) Improve wording for known\_hosts\_file [\#390](https://github.com/puppetlabs/cisco_ios/pull/390) ([DavidS](https://github.com/DavidS))
- \(maint\) - Fix for syslog\_Server [\#389](https://github.com/puppetlabs/cisco_ios/pull/389) ([david22swan](https://github.com/david22swan))
- \(FM-8439\) Fix vrf deletion error on 4948 [\#388](https://github.com/puppetlabs/cisco_ios/pull/388) ([MaxMagill](https://github.com/MaxMagill))
- \(FM-8437\) - tacacs idempotency fixes [\#384](https://github.com/puppetlabs/cisco_ios/pull/384) ([david22swan](https://github.com/david22swan))

## [1.1.0](https://github.com/puppetlabs/cisco_ios/tree/1.1.0) (2019-09-10)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/v1.0.0...1.1.0)

### Added

- Move References from README to REFERENCE.md [\#370](https://github.com/puppetlabs/cisco_ios/pull/370) ([MaxMagill](https://github.com/MaxMagill))
- \(FM-7818\) - Addition of attributes to banner type [\#368](https://github.com/puppetlabs/cisco_ios/pull/368) ([david22swan](https://github.com/david22swan))
- \(FM-8434\) Added VRF support for NTP server [\#364](https://github.com/puppetlabs/cisco_ios/pull/364) ([MaxMagill](https://github.com/MaxMagill))
- \(FM-7758\) Add type ios\_radius\_server\_group [\#360](https://github.com/puppetlabs/cisco_ios/pull/360) ([david22swan](https://github.com/david22swan))
- \(FM-7741\) add XE support in ios\_aaa\_authentication [\#352](https://github.com/puppetlabs/cisco_ios/pull/352) ([Lavinia-Dan](https://github.com/Lavinia-Dan))
- \(FM-8210\) add xe functionality for ntp\_config [\#350](https://github.com/puppetlabs/cisco_ios/pull/350) ([Lavinia-Dan](https://github.com/Lavinia-Dan))
- \(FM-7760\) add ios\_interface [\#348](https://github.com/puppetlabs/cisco_ios/pull/348) ([david22swan](https://github.com/david22swan))
- \(FM-7740\) Add XE support for ios\_aaa\_accounting [\#347](https://github.com/puppetlabs/cisco_ios/pull/347) ([DavidS](https://github.com/DavidS))
- \(FM-7760\) Add ios\_snmp\_global type and provider [\#346](https://github.com/puppetlabs/cisco_ios/pull/346) ([david22swan](https://github.com/david22swan))
- \(FM-7764\) - IOS Additional Syslog Settings created [\#344](https://github.com/puppetlabs/cisco_ios/pull/344) ([david22swan](https://github.com/david22swan))
- \(FM-7764\) - Functionality added to Syslog Settings [\#343](https://github.com/puppetlabs/cisco_ios/pull/343) ([david22swan](https://github.com/david22swan))
- \(FM-7747\) IOS Network DNS Created [\#341](https://github.com/puppetlabs/cisco_ios/pull/341) ([david22swan](https://github.com/david22swan))
- \(FM-8181\) - Ios Network Trunk created [\#338](https://github.com/puppetlabs/cisco_ios/pull/338) ([david22swan](https://github.com/david22swan))
- \(FM-7757\) Add IOS\_radius\_global type and provider [\#334](https://github.com/puppetlabs/cisco_ios/pull/334) ([willmeek](https://github.com/willmeek))
- Add hands on lab [\#319](https://github.com/puppetlabs/cisco_ios/pull/319) ([davinhanlon](https://github.com/davinhanlon))

### Fixed

- \(maint\) - VRF Fix [\#379](https://github.com/puppetlabs/cisco_ios/pull/379) ([david22swan](https://github.com/david22swan))
- \(FM-8438\) - Fix to make the attributes of syslog\_settings `console` and `monitor` idempotent [\#378](https://github.com/puppetlabs/cisco_ios/pull/378) ([david22swan](https://github.com/david22swan))
- \(FM-8434\) ntp\_server: fix idempotency issue with VRF [\#376](https://github.com/puppetlabs/cisco_ios/pull/376) ([MaxMagill](https://github.com/MaxMagill))
- \(FM-7815\) Merge functions of ios\_access\_list and ios\_acl\_entry [\#375](https://github.com/puppetlabs/cisco_ios/pull/375) ([da-ar](https://github.com/da-ar))
- \(FM-8441\) - Remove code that removes additional spaces [\#374](https://github.com/puppetlabs/cisco_ios/pull/374) ([david22swan](https://github.com/david22swan))
- \(maint\) return cli\_command errors as JSON [\#373](https://github.com/puppetlabs/cisco_ios/pull/373) ([DavidS](https://github.com/DavidS))
- Optimise ios\_network\_trunk performance [\#369](https://github.com/puppetlabs/cisco_ios/pull/369) ([MaxMagill](https://github.com/MaxMagill))
- \(MODULES-9465\) ios\_radius\_global: fix spurious whitespace in attributes returned from device [\#365](https://github.com/puppetlabs/cisco_ios/pull/365) ([david22swan](https://github.com/david22swan))
- \(maint\) fixes for the final ios\_snmp\_global idempotency failures [\#362](https://github.com/puppetlabs/cisco_ios/pull/362) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- \(FM-8310\) idempotency fixes for ios stp global [\#357](https://github.com/puppetlabs/cisco_ios/pull/357) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- Fix documentation example device conf file [\#356](https://github.com/puppetlabs/cisco_ios/pull/356) ([seanmil](https://github.com/seanmil))
- \(FM-7764\) Exclusion added for ios\_additional\_syslog\_settings tests [\#351](https://github.com/puppetlabs/cisco_ios/pull/351) ([david22swan](https://github.com/david22swan))
- \(maint\) Update the connection prompt to match on confirmation prompts [\#336](https://github.com/puppetlabs/cisco_ios/pull/336) ([willmeek](https://github.com/willmeek))
- \(FM-7222\) Error out instead of attemping to delete default Cisco VLANs [\#245](https://github.com/puppetlabs/cisco_ios/pull/245) ([willmeek](https://github.com/willmeek))

## [v1.0.0](https://github.com/puppetlabs/cisco_ios/tree/v1.0.0) (2019-06-14)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.6.2...v1.0.0)

### Added

- \(FM-8099\) Update README to reflect status of types for XE devices [\#330](https://github.com/puppetlabs/cisco_ios/pull/330) ([willmeek](https://github.com/willmeek))
- \(maint\) Add 4948 exclusion to Radius Server [\#327](https://github.com/puppetlabs/cisco_ios/pull/327) ([willmeek](https://github.com/willmeek))
- \(FM-8083\) fix up the POC cli task for generic command execution [\#316](https://github.com/puppetlabs/cisco_ios/pull/316) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- FM-7753 XE functionality for ntp\_config [\#315](https://github.com/puppetlabs/cisco_ios/pull/315) ([Lavinia-Dan](https://github.com/Lavinia-Dan))
- \(maint\) Add a function to allow for backwards compatible credentials [\#314](https://github.com/puppetlabs/cisco_ios/pull/314) ([willmeek](https://github.com/willmeek))
- \(FM-7849\) Acceptance test updates [\#313](https://github.com/puppetlabs/cisco_ios/pull/313) ([Lavinia-Dan](https://github.com/Lavinia-Dan))
- \(FM-7746\) Add additional fields to IOS STP Global [\#312](https://github.com/puppetlabs/cisco_ios/pull/312) ([willmeek](https://github.com/willmeek))
- \(FM-7750\) - Network Trunk update to account for XE [\#310](https://github.com/puppetlabs/cisco_ios/pull/310) ([david22swan](https://github.com/david22swan))
- \(maint\) acl and access conversion to match other providers [\#307](https://github.com/puppetlabs/cisco_ios/pull/307) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- \(FM-7748\) checking of support for network interface and xe [\#306](https://github.com/puppetlabs/cisco_ios/pull/306) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- \(maint\) adding the new devices to readme test matrix [\#304](https://github.com/puppetlabs/cisco_ios/pull/304) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- \(maint\) adding in an os family fact value for allowing xe exclusions [\#303](https://github.com/puppetlabs/cisco_ios/pull/303) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- \(maint\) Add an OS Family fact [\#295](https://github.com/puppetlabs/cisco_ios/pull/295) ([willmeek](https://github.com/willmeek))
- \(FM-7737\) Add enable secret to test pre-requisite [\#293](https://github.com/puppetlabs/cisco_ios/pull/293) ([willmeek](https://github.com/willmeek))
- \(FM-7727\) Update to use RSAPI Transports and adjust credential configuration to default keys [\#292](https://github.com/puppetlabs/cisco_ios/pull/292) ([da-ar](https://github.com/da-ar))
- \(FM-7653\) implement a standardized install class [\#288](https://github.com/puppetlabs/cisco_ios/pull/288) ([tkishel](https://github.com/tkishel))
- \(FM-7653\) implement a standardized install class [\#286](https://github.com/puppetlabs/cisco_ios/pull/286) ([tkishel](https://github.com/tkishel))
- \(FM-7138\) Add support for Access Lists [\#235](https://github.com/puppetlabs/cisco_ios/pull/235) ([willmeek](https://github.com/willmeek))

### Fixed

- \(maint\) Fix for IOS STP Global test [\#324](https://github.com/puppetlabs/cisco_ios/pull/324) ([willmeek](https://github.com/willmeek))
- \(maint\) Fix for TACACS Server acceptance test [\#323](https://github.com/puppetlabs/cisco_ios/pull/323) ([willmeek](https://github.com/willmeek))
- \(maint\) Fix for TACACS Global test [\#322](https://github.com/puppetlabs/cisco_ios/pull/322) ([willmeek](https://github.com/willmeek))
- \(maint\) SNMP Notification acceptance test fix [\#321](https://github.com/puppetlabs/cisco_ios/pull/321) ([willmeek](https://github.com/willmeek))
- \(maint\) Fix for Network Trunk test [\#320](https://github.com/puppetlabs/cisco_ios/pull/320) ([willmeek](https://github.com/willmeek))
- \(maint\) Fix for NTP Server test [\#318](https://github.com/puppetlabs/cisco_ios/pull/318) ([willmeek](https://github.com/willmeek))
- \(maint\) Update Spec Helper Acceptance to reflect new transport schema [\#300](https://github.com/puppetlabs/cisco_ios/pull/300) ([willmeek](https://github.com/willmeek))
- \(maint\) Unit tests - ACL entry types should be integers [\#299](https://github.com/puppetlabs/cisco_ios/pull/299) ([willmeek](https://github.com/willmeek))
- make "des" working [\#298](https://github.com/puppetlabs/cisco_ios/pull/298) ([seppeel](https://github.com/seppeel))
- \(maint\) Fix for the enable password regex [\#294](https://github.com/puppetlabs/cisco_ios/pull/294) ([willmeek](https://github.com/willmeek))
- \(maint\) Fix acceptance tests with a dependency on vlan presence [\#291](https://github.com/puppetlabs/cisco_ios/pull/291) ([willmeek](https://github.com/willmeek))
- \(maint\) Fix acceptance tests on fresh device config [\#290](https://github.com/puppetlabs/cisco_ios/pull/290) ([willmeek](https://github.com/willmeek))

## [0.6.2](https://github.com/puppetlabs/cisco_ios/tree/0.6.2) (2018-12-06)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.6.1...0.6.2)

### Fixed

- \(FM-7604\) only use verify\_host\_key on versions of net-ssh which have it [\#282](https://github.com/puppetlabs/cisco_ios/pull/282) ([Thomas-Franklin](https://github.com/Thomas-Franklin))

## [0.6.1](https://github.com/puppetlabs/cisco_ios/tree/0.6.1) (2018-11-26)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.6.0...0.6.1)

### Fixed

- \(maint\) Fix network\_interface canonicalisation [\#279](https://github.com/puppetlabs/cisco_ios/pull/279) ([willmeek](https://github.com/willmeek))

## [0.6.0](https://github.com/puppetlabs/cisco_ios/tree/0.6.0) (2018-11-22)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.5.0...0.6.0)

### Added

- Refactor to RSAPI device specific providers [\#273](https://github.com/puppetlabs/cisco_ios/pull/273) ([da-ar](https://github.com/da-ar))
- pdksync - pdksync\_1.7.1-0-g810b982 [\#272](https://github.com/puppetlabs/cisco_ios/pull/272) ([david22swan](https://github.com/david22swan))

### Fixed

- \(maint\) Send command and prompt hardening [\#276](https://github.com/puppetlabs/cisco_ios/pull/276) ([willmeek](https://github.com/willmeek))

## [0.5.0](https://github.com/puppetlabs/cisco_ios/tree/0.5.0) (2018-11-05)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.4.0...0.5.0)

### Added

- \(maint\) switch the Device to url\_or\_config handling [\#267](https://github.com/puppetlabs/cisco_ios/pull/267) ([DavidS](https://github.com/DavidS))
- \(MODULES-8069\) prepare for updates to netdev\_stdlib [\#264](https://github.com/puppetlabs/cisco_ios/pull/264) ([DavidS](https://github.com/DavidS))
- \(FM-7481\) Update install instructions and classes [\#263](https://github.com/puppetlabs/cisco_ios/pull/263) ([DavidS](https://github.com/DavidS))
- \(MODULES-8068\) empty canonicalize method to netdev\_stdlib providers [\#262](https://github.com/puppetlabs/cisco_ios/pull/262) ([Thomas-Franklin](https://github.com/Thomas-Franklin))

### Fixed

- \(maint\) Change command used to obtain device vardir for SSL fingerpri… [\#269](https://github.com/puppetlabs/cisco_ios/pull/269) ([willmeek](https://github.com/willmeek))
- \(maint\) resolving resource issue when applying manifest [\#268](https://github.com/puppetlabs/cisco_ios/pull/268) ([Thomas-Franklin](https://github.com/Thomas-Franklin))

## [0.4.0](https://github.com/puppetlabs/cisco_ios/tree/0.4.0) (2018-10-02)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.3.0...0.4.0)

### Added

- \(maint\) Allow support for Puppet 6 [\#252](https://github.com/puppetlabs/cisco_ios/pull/252) ([willmeek](https://github.com/willmeek))
- \(FM-7028\) Add 'unset' function to banner. [\#250](https://github.com/puppetlabs/cisco_ios/pull/250) ([willmeek](https://github.com/willmeek))
- \(FM-7396\) syslog\_server match new style hosts [\#249](https://github.com/puppetlabs/cisco_ios/pull/249) ([shermdog](https://github.com/shermdog))
- \(maint\) Prepare for Puppet 6 [\#247](https://github.com/puppetlabs/cisco_ios/pull/247) ([justinstoller](https://github.com/justinstoller))

### Fixed

- CVE-2018-11752 \(FM-7259\) explicit configuration for SSH session logging [\#258](https://github.com/puppetlabs/cisco_ios/pull/258) ([willmeek](https://github.com/willmeek))
- CVE-2018-11750 \(FM-7215\) Verify SSH known hosts if specified [\#257](https://github.com/puppetlabs/cisco_ios/pull/257) ([willmeek](https://github.com/willmeek))
- \(maint\) Add missing coexistence check to banner [\#251](https://github.com/puppetlabs/cisco_ios/pull/251) ([shermdog](https://github.com/shermdog))
- \(FM-7283\) Fix network\_vlan acceptance test [\#248](https://github.com/puppetlabs/cisco_ios/pull/248) ([willmeek](https://github.com/willmeek))
- \(FM-6988\) Add canonicalize function to network\_interface [\#243](https://github.com/puppetlabs/cisco_ios/pull/243) ([willmeek](https://github.com/willmeek))

# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [0.3.0](https://github.com/puppetlabs/cisco_ios/tree/0.3.0) (2018-08-06)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.2.0...0.3.0)

### Added

- \(FM-6952\) Add types and providers for configuring AAA [\#232](https://github.com/puppetlabs/cisco_ios/pull/232) ([willmeek](https://github.com/willmeek))
- \(NETDEV-41\) add facility to syslog\_settings [\#228](https://github.com/puppetlabs/cisco_ios/pull/228) ([shermdog](https://github.com/shermdog))

### Fixed

- \(NETDEV-38\) removing banner type, use netdev [\#238](https://github.com/puppetlabs/cisco_ios/pull/238) ([tphoney](https://github.com/tphoney))
- \(FM-7184/FM-7197\) Handle authentication errors and custom prompts [\#237](https://github.com/puppetlabs/cisco_ios/pull/237) ([shermdog](https://github.com/shermdog))
- \(FM-7224\) Split command and connection timeout and make configurable [\#236](https://github.com/puppetlabs/cisco_ios/pull/236) ([shermdog](https://github.com/shermdog))
- Update 'create issue' link in metadata.json [\#233](https://github.com/puppetlabs/cisco_ios/pull/233) ([davidmalloncares](https://github.com/davidmalloncares))
- \(maint\) Fix os fact and add hostname fact [\#227](https://github.com/puppetlabs/cisco_ios/pull/227) ([shermdog](https://github.com/shermdog))
- \(maint\) Fix for NTP Auth key password test on 3750 [\#224](https://github.com/puppetlabs/cisco_ios/pull/224) ([willmeek](https://github.com/willmeek))
- \(maint\) NTP Server acceptance test - allow symbol on yaml load [\#223](https://github.com/puppetlabs/cisco_ios/pull/223) ([willmeek](https://github.com/willmeek))
- \(FM-7064\) Improve parsing of network interface speed values [\#214](https://github.com/puppetlabs/cisco_ios/pull/214) ([willmeek](https://github.com/willmeek))
- \(FM-7067\) Send a newline on Config T mode to clear prompt [\#212](https://github.com/puppetlabs/cisco_ios/pull/212) ([willmeek](https://github.com/willmeek))

## [0.2.0](https://github.com/puppetlabs/cisco_ios/tree/0.2.0) (2018-06-15)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.1.0...0.2.0)

### Added

- \(FM-6989\) Support Tacacs server deprecated CLI [\#220](https://github.com/puppetlabs/cisco_ios/pull/220) ([willmeek](https://github.com/willmeek))

### Fixed

- \(maint\) Adding changelog generator [\#217](https://github.com/puppetlabs/cisco_ios/pull/217) ([tphoney](https://github.com/tphoney))
- \(FM-7074\) Add list of tested IOS versions to OperatingSystem metadata [\#216](https://github.com/puppetlabs/cisco_ios/pull/216) ([willmeek](https://github.com/willmeek))
- \(FM-7069\) hocon vs yaml [\#215](https://github.com/puppetlabs/cisco_ios/pull/215) ([tkishel](https://github.com/tkishel))
- \(FM-7068\) run pdk update, fix blacksmith [\#213](https://github.com/puppetlabs/cisco_ios/pull/213) ([tphoney](https://github.com/tphoney))




\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*

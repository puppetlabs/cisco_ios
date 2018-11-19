# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [0.6.0](https://github.com/puppetlabs/cisco_ios/tree/0.6.0) (2018-11-19)

[Full Changelog](https://github.com/puppetlabs/cisco_ios/compare/0.5.0...0.6.0)

### Added

- Refactor to RSAPI device specific providers [\#273](https://github.com/puppetlabs/cisco_ios/pull/273) ([da-ar](https://github.com/da-ar))
- pdksync - pdksync\_1.7.1-0-g810b982 [\#272](https://github.com/puppetlabs/cisco_ios/pull/272) ([david22swan](https://github.com/david22swan))

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

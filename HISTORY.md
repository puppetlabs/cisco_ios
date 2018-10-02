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



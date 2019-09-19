require 'puppet/resource_api'

Puppet::ResourceApi.register_transport(
  name: 'cisco_ios',
  desc: <<-EOS,
This transport connects to a Cisco IOS device.
EOS
  features: [],
  connection_info: {
    host: {
      type: 'String',
      desc: 'The FQDN or IP address of the device to connect to.',
    },
    port: {
      type: 'Optional[Integer]',
      desc: 'The port of the device to connect to. (Default: 22)',
    },
    user: {
      type: 'String',
      desc: 'The username to use for authenticating all connections to the device.',
    },
    password: {
      type: 'String',
      sensitive: true,
      desc: 'The password to use for authenticating all connections to the device.',
    },
    enable_password: {
      type: 'String',
      sensitive: true,
      desc: 'The password to use for entering into enable mode on the device.',
    },
    timeout: {
      type: 'Optional[Integer]',
      desc: 'Timeout value in seconds, to wait on a connection request. (Default: 30)',
    },
    verify_hosts: {
      type: 'Optional[Boolean]',
      desc: <<-DESC,
Setting to false will disable the verification of the SSH host fingerprint. (Default: true)

Note (Security Warning) Disabling verification has security risks and should be done only after considering the implications.
DESC
      default: true,
    },
    known_hosts_file: {
      type: 'Optional[String]',
      desc: <<-DESC,
The location to store device host keys. The location will be used on the node running the catalog, not the device.

The SSH host key, and hence its identity, will not be verified during the first connection
attempt. The host key will be added to this file and verified on subsequent accesses.

To force using specific host keys, instead of trusting the initial connection handshake, deploy a `known_hosts` file to your puppet master, or proxy agent, with verified fingerprints and specify that file here.
(Default is based on the device's cache directory. For example: `/opt/puppetlabs/puppet/cache/devices/<CERTNAME>/ssl/known_hosts`)
DESC
    },
    ssh_logging: {
      type: 'Optional[Boolean]',
      desc: <<-DESC,
If set to true, SSH session will be logged for debug purposes.
Requires Puppet debug level set to `debug`.

(Default: false)
DESC
    },
    ssh_log_file: {
      type: 'Optional[String]',
      desc: <<-DESC,
Absolute path to the file for which SSH logging will be written. Requires `ssh_logging` to be set to `true`.
(Default: $puppet[:statedir]/SSH_I_DUMPED)
See: https://puppet.com/docs/puppet/5.3/configuration.html#statedir
DESC
    },
    command_timeout: {
      type: 'Optional[Integer]',
      desc: 'Timeout value in seconds, to wait on a response to a command. (Default: 120)',
    },
  },
)

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
Setting to false will disable the verification of the SSH host fingerprint.

Note (Security Warning) Disabling verification has security risks and should be done only after considering the implications.
DESC
      default: true,
    },
    known_hosts_file: {
      type: 'Optional[String]',
      desc: <<-DESC,
The SSH server key, and hence its identity, will not be verified during the first connection attempt.
Please follow up by verifying the SSH key for the device is correct. The fingerprint will be added to the known hosts file.
By default this is the device cache directory eg. `/opt/puppetlabs/puppet/cache/devices/cisco.example.com/ssl/known_hosts`
This attribute allows this directory to be modified.
DESC
    },
    ssh_logging: {
      type: 'Optional[Boolean]',
      desc: <<-DESC,
If set to true, SSH session will be logged for debug purposes.
Requires Puppet debug level set to `debug`.
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

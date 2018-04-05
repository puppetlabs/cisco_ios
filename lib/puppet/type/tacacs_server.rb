require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_old_netdev_type
  Puppet::Type.newtype(:tacacs_server) do
    @doc = 'Configure a tacacs server'

    apply_to_all
    ensurable

    newparam(:name, namevar: true) do
      desc 'The name of the tacacs server group'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:hostname) do
      desc 'The hostname or address of the tacacs server'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:single_connection) do
      desc 'Enable or disable session multiplexing [true|false]'
      newvalues(:true, :false)
    end

    newproperty(:vrf) do
      desc 'specifies the VRF instance used to communicate with the server'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:port) do
      desc 'The port of the tacacs server'

      munge { |v| Integer(v) }
    end

    newproperty(:key) do
      desc 'Encryption key (plaintext or in hash form depending on key_format)'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:key_format) do
      desc 'Encryption key format [0-7]'
      munge { |v| Integer(v) }
    end

    newproperty(:timeout) do
      desc 'Number of seconds before the timeout period ends'
      munge { |v| Integer(v) }
    end

    newproperty(:group) do
      desc 'Server group associated with this server'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end
  end
else
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'tacacs_server',
    docs: 'Configure a tacacs server',
    features: ['remote_resource'],
    attributes: {
      ensure:      {
        type:    'Enum[present, absent]',
        desc:    'Whether this tacacs server should be present or absent on the target system.',
        default: 'present',
      },
      name:     {
        type:   'String',
        desc:   'Name of the tacacs server',
        behaviour: :namevar,
      },
      hostname:    {
        type:   'Optional[String]',
        desc:   'ipv4 address of the tacacs server',
      },
      single_connection:    {
        type:   'Optional[Boolean]',
        desc:   'Enable or disable session multiplexing [true|false]',
      },
      port:      {
        type:    'Optional[Integer]',
        desc:    'The port of the tacacs server',
      },
      key:      {
        type:    'Optional[String]',
        desc:    'Encryption key (plaintext or in hash form depending on key_format)',
      },
      key_format:      {
        type:    'Optional[Integer]',
        desc:    'Encryption key format [0|7]',
      },
      timeout:      {
        type:    'Optional[Integer]',
        desc:    'Number of seconds before the timeout period ends',
      },
    },
  )
end

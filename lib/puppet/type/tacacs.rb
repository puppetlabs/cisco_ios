require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_resource_api
  Puppet::Type.newtype(:tacacs) do
    @doc = 'Enable or disable tacacs functionality'

    apply_to_all

    newparam(:name, namevar: true) do
      desc 'Resource name, not used to manage the device'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:enable) do
      desc 'Enable or disable tacacs functionality [true|false]'
      newvalues(:true, :false)
    end
  end
else
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'tacacs',
    docs: 'Configure global tacacs settings',
    features: ['remote_resource'],
    attributes: {
      ensure:       {
        type:       'Enum[present, absent]',
        desc:       'Whether this global Tacacs gonfig should be present or absent on the target system.',
        default:    'present',
      },
      name:         {
        type:      'String',
        desc:      'Config name, default to "default" as the Tacacs config is global rather than instance based',
        behaviour: :namevar,
        default:   'default',
      },
      key:  {
        type:      'Optional[String]',
        desc:      'Encryption key (plaintext or in hash form depending on key_format)',
      },
      key_format:  {
        type:      'Integer',
        desc:      'Encryption key format [0-7]',
        default:   '0',
      },
      source_interface:  {
        type:      'String',
        desc:      'The source interface used for TACACS packets',
      },
      # Set to 0 to unset
      timeout: {
        type:      'Integer',
        desc:      'The encryption type',
      },
    },
  )
end

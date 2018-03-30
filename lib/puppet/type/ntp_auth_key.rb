require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_resource_api
  Puppet::Type.newtype(:ntp_auth_key) do
    @doc = 'NTP Authentication keys'

    apply_to_all
    ensurable

    newparam(:name, namevar: true, parent: PuppetX::PuppetLabs::NetdevStdlib::Property::PortRange) do
      desc 'Authentication key ID'

      # Make sure we have a string, casting to int first also strips whitespace
      munge do |value|
        Integer(value).to_s
      end
    end

    newproperty(:algorithm) do
      desc 'Hash algorithm [md5|sha1|sha256]'

      newvalues(:md5, :sha1, :sha256)
    end

    newproperty(:mode) do
      desc 'Password mode [0 (plain) | 7 (encrypted)]'

      munge { |v| Integer(v) }
    end

    newproperty(:password) do
      desc 'Password text'

      validate do |value|
        raise "value #{value.inspect} is invalid, must be a String." unless
        value.is_a? String
        super(value)
      end
    end
  end
else
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'ntp_auth_key',
    docs: 'Specify an NTP auth key',
    features: ['remote_resource'],
    attributes: {
      ensure:       {
        type:       'Enum[present, absent]',
        desc:       'Whether this ntp server should be present or absent on the target system.',
        default:    'present',
      },
      name:         {
        type:      'String',
        desc:      'The keyname',
        behaviour: :namevar,
      },
      algorithm:    {
        type:      'String',
        desc:      'Algorithm eg. md5',
      },
      key:          {
        type:      'String',
        desc:      'The key',
      },
      encryption_type: {
        type:      'Integer',
        desc:      'The encryption type',
      },
    },
  )
end

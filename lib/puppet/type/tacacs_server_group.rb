require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_resource_api
  Puppet::Type.newtype(:tacacs_server_group) do
    @doc = 'Configure a tacacs server group'

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

    newproperty(:servers, array_matching: :all) do
      desc 'Array of servers associated with this group'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end

      def should_to_s(new_value = @should)
        self.class.format_value_for_display(new_value)
      end

      def is_to_s(current_value = @is)
        self.class.format_value_for_display(current_value)
      end
    end
  end
else
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'tacacs_server_group',
    docs: 'Configure a tacacs server group',
    features: ['remote_resource'],
    attributes: {
      ensure:      {
        type:    'Enum[present, absent]',
        desc:    'Whether this network interface should be present or absent on the target system.',
        default: 'present',
      },
      name:         {
        type:      'String',
        desc:      'The name of the tacacs server group',
        behaviour: :namevar,
      },
      # Comma separated string of servers associated with this group
      servers: {
        type:      'Optional[String]',
        desc:      'String of servers associated with this group',
      },
    },
  )
end

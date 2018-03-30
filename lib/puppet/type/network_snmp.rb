require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_resource_api
  Puppet::Type.newtype(:network_snmp) do
    @doc = 'Manage snmp location, contact and enable SNMP on the device'

    apply_to_all

    newparam(:name, namevar: true) do
      desc 'The name of the Puppet resource, not used to manage the device'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:enable) do
      desc 'Enable or disable SNMP functionality [true|false]'
      newvalues(:true, :false)
    end

    newproperty(:contact) do
      desc 'The contact name for this device'
      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:location) do
      desc 'The location of this device'
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
    name: 'network_snmp',
    docs: 'Manage snmp location, contact and enable SNMP on the device',
    features: ['remote_resource'],
    attributes: {
      ensure:      {
        type:    'Enum[present, absent]',
        desc:    'Whether the SNMP location and contact should be present or absent on the target system.',
        default: 'present',
      },
      name:     {
        type:   'String',
        desc:   'This defaults to default',
        behaviour: :namevar,
      },
      enable:    {
        type:   'Boolean',
        desc:   'Enable or disable SNMP functionality [true|false]',
      },
      contact:    {
        type:   'String',
        desc:   'The contact name for this device',
      },
      location:    {
        type:   'String',
        desc:   'The location of this device',
      },
    },
  )
end

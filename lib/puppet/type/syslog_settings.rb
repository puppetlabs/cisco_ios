require_relative '../../puppet_x/puppetlabs/netdev_stdlib/check'
if PuppetX::NetdevStdlib::Check.use_old_netdev_type
  Puppet::Type.newtype(:syslog_settings) do
    @doc = 'Configure global syslog settings'

    apply_to_all

    newparam(:name, namevar: true) do
      desc 'Resource name, not used to configure the device'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:enable) do
      desc 'Enable or disable syslog logging [true|false]'
      newvalues(:true, :false)
    end

    newproperty(:console) do
      desc "Console logging severity level [0-7] or 'unset'"

      validate do |value|
        if value.to_s.match('^[0-7]$') || value == 'unset' then super(value)
        else raise "value #{value.inspect} is invalid, must be 0-7 or 'unset'"
        end
      end
    end

    newproperty(:monitor) do
      desc "Monitor (terminal) logging severity level [0-7] or 'unset'"

      validate do |value|
        if value.to_s.match('^[0-7]$') || value == 'unset' then super(value)
        else raise "value #{value.inspect} is invalid, must be 0-7 or 'unset'"
        end
      end
    end

    newproperty(:source_interface, array_matching: :all) do
      desc 'Source interface to send syslog data from, e.g. "ethernet 2/1" (array of strings for multiple)'

      validate do |value|
        if value.is_a? String then super(value)
        else raise "value #{value.inspect} is invalid, must be a String."
        end
      end
    end

    newproperty(:time_stamp_units) do
      desc 'The unit to log time values in'
      newvalues(:seconds, :milliseconds)
    end

    newproperty(:vrf, array_matching: :all) do
      desc 'The VRF associated with source_interface (array of strings for multiple).'

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
    name: 'syslog_settings',
    docs: 'Configure a remote syslog server for logging',
    features: ['remote_resource'],
    attributes: {
      name:     {
        type:   'String',
        desc:   'This defaults to default',
        behaviour: :namevar,
      },
      enable:    {
        type:   'Optional[Boolean]',
        desc:   'Enable or disable syslog logging [true|false]',
      },
      console:    {
        type:   'Optional[Integer]',
        desc:   "Console logging severity level [0-7] or 'unset'",
      },
      monitor:    {
        type:   'Optional[Integer]',
        desc:   "Monitor (terminal) logging severity level [0-7] or 'unset'",
      },
      source_interface:      {
        type:    'Optional[Array[String]]',
        desc:    'Source interface to send syslog data from, e.g. "ethernet 2/1"',
      },
      time_stamp_units:      {
        type:    'Optional[Enum["seconds", "milliseconds"]]',
        desc:    'The unit to log time values in',
      },
      vrf:    {
        type:   'Optional[Array[String]]',
        desc:   'vrf',
      },
    },
  )
end

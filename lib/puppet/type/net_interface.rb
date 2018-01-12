Puppet::Type.newtype(:net_interface) do
  @doc = 'Specify an Interface'

  apply_to_all
  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the interface'
    isnamevar
    validate do |value|
      if value.is_a? String then super(value)
      else fail "value #{value.inspect} is invalid, must be a String."
      end
    end
  end

  newproperty(:description) do
    desc 'Description of the interface'

    validate do |value|
      if value.is_a? String then super(value)
      else fail "value #{value.inspect} is invalid, must be a String."
      end
    end
  end

end

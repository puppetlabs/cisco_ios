require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Execute and arbitary command against the cicso_ios device with or without a check for idempotency
class Puppet::Provider::IosConfig::CiscoIos
  def get(_context)
    new_instance = [{ name: 'default' }]
    new_instance
  end

  # We use canonicalize here to check for idempotency as these are dynamic resources
  def canonicalize(context, resources)
    resources.each do |resource|
      # We strip leading and trailing whitespace to help ensure valid commands are sent
      resource[:command].strip!
      next unless resource[:idempotent_regex]
      output = context.device.run_command_enable_mode('show running-config')
      idempotent_regex = if resource[:idempotent_regex_options]
                           # Gather array of regex options, make sure they are unique, map them to Regexp constants and bitwise or them
                           Regexp.new(resource[:idempotent_regex], resource[:idempotent_regex_options].uniq.map { |x| Regexp.const_get(x.upcase) }.reduce(:|))
                         else
                           Regexp.new(resource[:idempotent_regex])
                         end
      match = if resource[:negate_idempotent_regex]
                output !~ idempotent_regex
              else
                output =~ idempotent_regex
              end
      # We have matched our idempotency criteria - do not update type
      # This is done by setting the type back to the default value so that Puppet knows it is in desired state
      resource.delete(:command) if match
    end
    resources
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      update(context, name, should)
    end
  end

  def update(context, name, should)
    # command mode is only conf_t for now.
    context.updating(name) do
      context.device.run_command_conf_t_mode(should[:command])
    end
  end
end

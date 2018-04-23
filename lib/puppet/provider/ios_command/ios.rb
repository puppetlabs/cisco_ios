require_relative '../../util/network_device/cisco_ios/device'
require_relative '../../../puppet_x/puppetlabs/cisco_ios/utility'

# Execute and arbitary command against the cicso_ios device with or without a check for idempotency
class Puppet::Provider::IosCommand::IosCommand
  def get(_context)
    new_instance_fields = []
    new_instance = {}
    new_instance[:name] = 'This resource only works with apply or "puppet device -t"'
    new_instance_fields << new_instance
    new_instance_fields
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      update(context, name, should)
    end
  end

  def update(context, name, should)
    run_command = false
    if should[:idempotent_regex].nil?
      run_command = true
    else
      # run the show_all command then run the regex
      output = context.device.run_command_enable_mode('show running-config')
      match = if should[:negate_idempotent_check]
                output !~ %r{#{should[:idempotent_regex]}}
              else
                output =~ %r{#{should[:idempotent_regex]}}
              end
      run_command = match.nil?
    end
    if run_command
      # command mode is only conf_t for now.
      context.updating(name) do
        context.device.run_command_conf_t_mode(should[:command])
      end
    end
  end
end

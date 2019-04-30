#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# Bolt task for saving the running config for a Cisco Ios switch
class ConfigSave < TaskHelper
  def task(_params, **_kwargs)
    unless Puppet.settings.global_defaults_initialized?
      Puppet.initialize_settings
    end

    rtn = context.transport.running_config_save
    {
      status: 'success',
      results: "running-config saved to startup-config: #{rtn}",
    }
  end
end

if $PROGRAM_NAME == __FILE__
  ConfigSave.run
end

#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('cisco_ios')

result = {}

unless Puppet.settings.global_defaults_initialized?
  Puppet.initialize_settings
end

begin
  rtn = task.transport.running_config_save
  result[:status]  = 'success'
  result[:results] = "running-config saved to startup-config: #{rtn}"
rescue StandardError => e
  result[:_error] = {
    msg: e.message,
    kind: 'puppetlabs/cisco_ios',
    details: {
      class: e.class.to_s,
      backtrace: e.backtrace,
    },
  }
end

puts result.to_json

#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('cisco_ios')

unless Puppet.settings.global_defaults_initialized?
  Puppet.initialize_settings
end

begin
  results = task.transport.run_command_enable_mode(task.params['command'])
  if task.params['raw']
    puts results
  else
    result = {}
    result[:success] = 'success'
    result[:results] = results.to_s
    puts result.to_json
  end
  exit 0
rescue StandardError => e
  result = {}
  result[:_error] = {
    msg: e.message,
    kind: 'puppetlabs/cisco_ios',
    details: {
      class: e.class.to_s,
      backtrace: e.backtrace,
    },
  }
  puts result
  exit 1
end

#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('cisco_ios')

CONFIG_LINE_HEADER_CUTOFF = 20
CONFIG_LINE_ENDING_ID = 'end'.freeze

result = {}

unless Puppet.settings.global_defaults_initialized?
  Puppet.initialize_settings
end

VALID_CISCO_HEADERS = ['show running-config', 'Building configuration', 'Current configuration'].freeze

def config_to_restore(raw_config_output)
  header_match_count = 0
  line = 0
  start_line = nil
  end_line = nil

  raw_config_output.each do |current_line|
    header_match_count += 1 if VALID_CISCO_HEADERS.any? { |vch| current_line.start_with? vch }
    start_line = (line + 1) if (header_match_count == 3) && (current_line.start_with? 'version')
    end_line = line if current_line.start_with? CONFIG_LINE_ENDING_ID
    break if start_line && end_line
    # If we haven't found the headers by line 20, let's exit as this doesn't seem to be a valid Cisco
    # backup config retrieved using 'show running-config'
    if line >= CONFIG_LINE_HEADER_CUTOFF && header_match_count < 3
      raise "Did not detect the following expected headers expected from a valid Cisco backup after processing #{CONFIG_LINE_HEADER_CUTOFF} lines:\n" +
            VALID_CISCO_HEADERS.join("\n")
    end
    line += 1
  end

  raise "Could not determine end of config (was expecting '#{CONFIG_LINE_ENDING_ID}')" unless end_line
  raw_config_output[start_line..end_line].map { |l| l.strip }
end

begin
  config_to_restore = config_to_restore(File.readlines(task.params['backup_location']))
  task.transport.restore_config_conf_t_mode(config_to_restore)

  result = {
    last_config_change: '',
  }
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

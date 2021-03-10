# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'tempfile'
require 'securerandom'

SNMP_SERVER_CONTACT = "Acceptance Test Runner #{SecureRandom.hex}".freeze
SNMP_SERVER_CONTACT_VERIFY_CMD = 'show run | inc snmp-server contact'.freeze

def create_snmp_server_contact_config
  new_config_file_path = new_tempfile
  File.open(new_config_file_path, 'wb') do |file|
    file.write("snmp-server contact #{SNMP_SERVER_CONTACT}\n")
    file.write("end\n")
  end
  new_config_file_path
end

def snmp_server_contact_set
  output, status = Open3.capture2e(bolt_task_command('cli_command',
                                                     "command=\"#{SNMP_SERVER_CONTACT_VERIFY_CMD}\"",
                                                     'raw=false'))
  if status.success?
    output.split("\n").each do |line|
      return true if line.include? SNMP_SERVER_CONTACT_VERIFY_CMD
    end
  end
  false
end

describe 'bolt task to backup / restore config' do
  before(:all) do
    unless ENV['SKIP_STARTUP_RESTORE']
      # Restore the running config back to the startup config
      _output, status = Open3.capture2e(bolt_task_command('restore_startup'))
      raise 'Error restoring startup config on target' unless status.success?
    end
  end

  it 'can backup a running config' do
    backup_location = new_tempfile
    _output, status = Open3.capture2e(bolt_task_command('backup_config', "backup_location=#{backup_location}"))
    expect(status.success?).to be true
    expect(File.empty?(backup_location)).to be false
  end

  it 'can restore a config' do
    # Create a simple config that sets the 'snmp server contact' parameter
    snmp_server_contact_config = create_snmp_server_contact_config
    _output, status = Open3.capture2e(bolt_task_command('restore_config', "backup_location=#{snmp_server_contact_config}"))
    expect(status.success?).to be true

    # Query the 'snmp server contact' parameter and ensure it has been set to the expected value
    expect(snmp_server_contact_set).to be true
  end
end

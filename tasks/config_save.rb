#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'puppet'
require 'puppet/util/network_device/config'
require 'timeout'

def require_module_file(file)
  require "#{Puppet[:plugindest]}/#{file}"
end

# PARAMETERS: JSON object from STDIN with the following fields:
#
# - target: a required string parameter.
# - noop: an optional boolean metaparameter, will set params['_noop'].

# Read parameters, set defaults, and validate values.

def read_parameters
  params = read_stdin
  return_error("Parameter 'target' contains illegal characters") unless safe_string?(params['target'])
  params
end

# Read parameters as JSON from STDIN.

def read_stdin
  params = {}
  begin
    Timeout.timeout(3) do
      params = JSON.parse(STDIN.read)
    end
  rescue Timeout::Error
    return_error('Cannot read parameters as JSON from STDIN')
  end
  params
end

# Validate strings. While handled externally, validate internally for defense in depth.

def safe_string?(param)
  return true unless param
  (param =~ %r{^[A-Za-z0-9._-]+$}) != nil
end

# Return an error and exit.

def return_error(message)
  result = {}
  result[:_error] = {
    msg:     message,
    kind:    'puppetlabs/cisco_ios',
    details: {},
  }
  puts result.to_json
  exit 1
end

# Return a result and exit.

def return_success(message)
  result = {}
  result[:status]  = 'success'
  result[:results] = message
  puts result.to_json
  exit 0
end

# Execute the task.

params = read_parameters

# Allow this task to access configuration settings, such as: Puppet[:environment].

Puppet.initialize_settings

# Identify the target device and its URL.

devices = Puppet::Util::NetworkDevice::Config.devices.dup
devices.select! { |key, _value| key == params['target'] }
if devices.empty?
  return_error("device conf error: unable to find target device #{params['target']} in #{Puppet[:deviceconfig]}")
end
target_device_url = URI.parse(devices[params['target']].url).to_s
if target_device_url.empty?
  return_error("device conf error: unable to find URL for target device #{params['target']} in #{Puppet[:deviceconfig]}")
end

# Honor the 'noop' parameter.

if params['_noop'] == true
  return_success("noop: true, target: #{params['target']}")
end

# Save.

begin
  require_module_file('puppet/util/network_device/cisco_ios/device')
  cisco_ios_device = Puppet::Util::NetworkDevice::Cisco_ios::Device.new(target_device_url)
  result = cisco_ios_device.running_config_save
  return_success("running-config saved to startup-config: #{result}")
rescue StandardError => e
  config_save_error = e.message
  return_error(config_save_error)
end

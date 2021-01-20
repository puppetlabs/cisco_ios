require 'open3'
require 'json'
require 'yaml'

if ENV['ABS_RESOURCE_HOSTS']
  puts "Using preconfigured ABS_RESOURCE_HOSTS: #{ENV['ABS_RESOURCE_HOSTS']}"
  hosts = JSON.parse(ENV['ABS_RESOURCE_HOSTS'])
  device_ip = hosts[0]['hostname']
else
  puts "Using DEVICE_IP from environment: #{ENV['DEVICE_IP']}"
  device_ip = ENV['DEVICE_IP']
end

device_user = ENV['DEVICE_USER']
device_password = ENV['DEVICE_PASSWORD']
device_enable_password = ENV['DEVICE_ENABLE_PASSWORD']

if device_ip.nil? || device_user.nil? || device_password.nil? || device_ip.empty? || device_user.empty? || device_password.empty?
  warning = <<-EOS
  DEVICE_IP DEVICE_USER DEVICE_PASSWORD environment variables need to be set eg:
  export DEVICE_IP=1.1.1.1
  export DEVICE_USER=admin
  export DEVICE_PASSWORD=password
  export DEVICE_ENABLE_PASSWORD=password
  EOS
  abort warning
end

def make_site_pp(pp)
  @file = Tempfile.new('site.pp')
  @file.write(pp)
  @file.close
end

COMMON_ARGS = '--modulepath spec/fixtures/modules --deviceconfig spec/fixtures/acceptance-device.conf --target sut'.freeze

def run_device(options = { allow_changes: true, allow_warnings: false, allow_errors: false })
  output, _status = Open3.capture2e("bundle exec puppet device --apply #{@file.path} #{COMMON_ARGS} --verbose --trace --debug")

  unless options[:allow_changes]
    expect(output).not_to match(%r{^(\e.*?m)?Notice: /Stage\[main\]})
  end

  unless options[:allow_errors]
    expect(output).not_to match %r{^(\e.*?m)?Error:}
  end

  unless options[:allow_warnings]
    expect(output).not_to match %r{^(\e.*?m)?Warning:}
  end

  output
end

def run_resource(resource_type, resource_title = nil, verbose = true)
  verbose_args = verbose ? '--verbose --trace --debug' : ''
  output, _status = Open3.capture2e("bundle exec puppet device --resource #{resource_type} #{resource_title} #{COMMON_ARGS} #{verbose_args}")
  output
end

def device_model
  fact['hardwaremodel'][%r{(\d\d\d\d)}, 1]
end

def fact
  output, _status = Open3.capture2e("bundle exec puppet device #{COMMON_ARGS} --facts")
  JSON.parse(output)['values']
end

class XeCheck
  attr_reader :xe_version_tested
  attr_reader :device_is_xe
  @xe_version_tested = false
  @device_is_xe = false

  def self.device_xe?
    return @device_is_xe if @xe_version_tested

    pp = <<-EOS
      ios_config { "show version ios XE":
        command => 'do show version | include IOS-XE Software',
        idempotent_regex => 'IOS-XE Software',
        idempotent_regex_options => ['ignorecase'],
      }
    EOS
    make_site_pp(pp)
    result = run_device(allow_changes: true, allow_warnings: true, allow_errors: true)
    @xe_version_tested = true
    @device_is_xe = (result =~ %r{(?:include IOS-XE Software).*(IOS-XE Software,)})
  end
end

def bolt_task_command(task, *opts)
  "BOLT_GEM=true bundle exec bolt task run cisco_ios::#{task} --modulepath spec/fixtures/modules --targets sut " \
  "--inventoryfile spec/fixtures/inventory.yml #{opts.join(' ')}".strip
end

def new_tempfile
  (@tempfiles ||= []) << Tempfile.new
  @tempfiles.last.path
end

RSpec.configure do |c|
  c.before :suite do
    system('rake spec_prep')
    c.add_setting :host, default: device_ip
    c.add_setting :user, default: device_user
    c.add_setting :password, default: device_password
    c.add_setting :enable_password, default: device_enable_password

    File.open('spec/fixtures/acceptance-credentials.conf', 'w') do |file|
      file.puts <<CREDENTIALS
host: #{RSpec.configuration.host}
user: #{RSpec.configuration.user}
password: #{RSpec.configuration.password}
enable_password: #{RSpec.configuration.enable_password}
CREDENTIALS
    end

    File.open('spec/fixtures/acceptance-device.conf', 'w') do |file|
      file.puts <<DEVICE
[sut]
type cisco_ios
url file://#{Dir.getwd}/spec/fixtures/acceptance-credentials.conf
DEVICE
    end

    File.open('spec/fixtures/inventory.yml', 'w') do |file|
      file.puts <<CREDENTIALS
---
version: 2
groups:
- name: #{RSpec.configuration.host.split('.')[0]}
  targets:
  - uri: #{RSpec.configuration.host}
    alias: sut
    config:
      transport: remote
      remote:
        remote-transport: cisco_ios
        user: #{RSpec.configuration.user}
        password: #{RSpec.configuration.password}
        enable_password: #{RSpec.configuration.enable_password}
CREDENTIALS
    end

    # do not provision if forbidden
    unless ENV['BEAKER_provision'] == 'no'
      # reset the device to it's startup-config
      result = Open3.capture2e('BOLT_GEM=true bundle exec bolt task run cisco_ios::restore_startup --modulepath spec/fixtures/modules --targets sut --inventoryfile spec/fixtures/inventory.yml')
      # result = Open3.capture2e("bundle exec bolt task show --modulepath ../")
      puts result

      # set pre-requisites, aaa new-model and enable secret such that we don't get locked out of enable mode
      # Common Vlan used in tests
      vrf = ['2960', '3560', '4503'].include?(device_model) ? '' : <<-EOS
        vrf { 'Test-Vrf':
           ensure => 'present',
        }

        vrf { 'Temp-Vrf':
           ensure => 'present',
        }
      EOS

      pp = <<-EOS
        ios_config { "enable password":
          command => 'enable secret #{device_enable_password}'
        }
        ios_config { "enable aaa":
          command => 'aaa new-model'
        }
        network_interface { 'Vlan42':
          enable => true,
          description => 'vlan42',
        }
        network_vlan { "42":
          shutdown => true,
          ensure => present,
        }
        network_interface { 'Vlan43':
          enable => true,
          description => 'vlan43',
        }
        network_vlan { "43":
          shutdown => true,
          ensure => present,
        }
        tacacs_server { '192.1.1.1':
          ensure => 'present',
          hostname => '192.1.1.1',
          key => 'testkey1',
          key_format => 0,
        }
        #{vrf}
      EOS
      make_site_pp(pp)
      run_device(allow_changes: true)
    end
  end
  c.after :suite do
    unless ENV['SKIP_STARTUP_RESTORE']
      # Restore the running config back to the startup config after the suite has completed
      _output, status = Open3.capture2e(bolt_task_command('restore_startup'))
      raise 'Error restoring startup config on target' unless status.success?
    end
  end
end

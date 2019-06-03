require 'open3'
require 'json'
require 'yaml'

cisco_host = YAML.safe_load(File.read('hosts.yaml'))
if !cisco_host.nil?
  _, cisco_host_value = cisco_host['HOSTS'].first
  device_ip = cisco_host_value['DEVICE_IP'].to_s
  device_user = cisco_host_value['DEVICE_USER'].to_s
  device_password = cisco_host_value['DEVICE_PASSWORD'].to_s
  device_enable_password = cisco_host_value['DEVICE_ENABLE_PASSWORD'].to_s
else
  device_ip = ENV['DEVICE_IP']
  device_user = ENV['DEVICE_USER']
  device_password = ENV['DEVICE_PASSWORD']
  device_enable_password = ENV['DEVICE_ENABLE_PASSWORD']
end

if device_ip.nil? || device_user.nil? || device_password.nil?
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

def run_device(options = { allow_changes: true })
  result = Open3.capture2e("bundle exec puppet device --apply #{@file.path} #{COMMON_ARGS}")
  if options[:allow_changes] == false
    expect(result[0]).not_to match(%r{^Notice: /Stage\[main\]})
  end
  expect(result[0]).not_to match %r{Error:}
  expect(result[0]).not_to match %r{Warning:}
end

def run_resource(resource_type, resource_title = nil)
  result = if resource_title
             Open3.capture2e("bundle exec puppet device --resource #{resource_type} #{resource_title} #{COMMON_ARGS} --verbose --trace")
           else
             Open3.capture2e("bundle exec puppet device --resource #{resource_type} #{COMMON_ARGS} --verbose --trace")
           end
  result[0]
end

def device_model
  fact['hardwaremodel'][%r{(\d\d\d\d)}, 1]
end

def fact
  result = Open3.capture2e("bundle exec puppet device #{COMMON_ARGS} --facts")
  JSON.parse(result[0])['values']
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
    # set pre-requisites, aaa new-model and enable secret such that we don't get locked out of enable mode
    pp = <<-EOS
    ios_config { "enable password":
      command => 'enable secret #{device_enable_password}'
    }
    ios_config { "enable aaa":
      command => 'aaa new-model'
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
  end
end

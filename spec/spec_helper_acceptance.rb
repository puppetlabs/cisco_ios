require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

$device_hostname = 'target'
$device_ip = ENV['DEVICE_IP']
$device_user = ENV['DEVICE_USER']
$device_password = ENV['DEVICE_PASSWORD']
$device_enable_password = ENV['DEVICE_ENABLE_PASSWORD']

if $device_ip.nil? || $device_user.nil? || $device_password.nil?
  warning = <<-EOS
DEVICE_IP DEVICE_USER DEVICE_PASSWORD envirnonment variables need to be set eg:
export DEVICE_IP=10.0.77.15
export DEVICE_USER=admin
export DEVICE_PASSWORD=bayda.dune.inca.nymph
export DEVICE_ENABLE_PASSWORD=bayda.dune.inca.nymph
EOS
  abort warning
end

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

def beaker_opts
  @env ||= {
    debug: true,
    trace: true,
    environment: {
      'DEVICE_IP' => ENV['DEVICE_IP'],
      'DEVICE_USER' => ENV['DEVICE_USER'],
      'DEVICE_PASSWORD' => ENV['DEVICE_PASSWORD'],
      'DEVICE_ENABLE_PASSWORD' => ENV['DEVICE_ENABLE_PASSWORD'],
    },
  }
end

def device_facts_ok(max_retries)
  1.upto(max_retries) do |retries|
    on master, puppet('device', '-v', '--user', 'root', '--server', master.to_s), acceptable_exit_codes: [0, 1] do |result|
      return if result.stdout =~ %r{Notice: (Finished|Applied) catalog}

      counter = 10 * retries
      logger.debug "Unable to get a successful catalog run, Sleeping #{counter} seconds for retry #{retries}"
      sleep counter
    end
  end
  raise Exception, 'Could not get a successful catalog run.'
end

def make_site_pp(pp)
  base_path = '/etc/puppetlabs/code/environments/production/'
  path = File.join(base_path, 'manifests')
  on master, "mkdir -p #{path}"
  create_remote_file(master, File.join(path, 'site.pp'), pp)
  if ENV['PUPPET_INSTALL_TYPE'] == 'foss'
    on master, "chown -R #{master['user']}:#{master['group']} #{path}"
    on master, "chmod -R 0755 #{path}"
    on master, "service #{master['puppetservice']} restart"
    wait_for_master(3)
  end
end

def run_device(options = { allow_changes: true })
  acceptable_exit_codes = if options[:allow_changes] == false
                            0
                          else
                            [0, 2]
                          end
  on(default, puppet('device', '--verbose', '--trace'), acceptable_exit_codes: acceptable_exit_codes) do |result|
    # on(default, puppet('device','--verbose','--color','false','--user','root','--trace','--server',master.to_s), { :acceptable_exit_codes => acceptable_exit_codes }) do |result|
    if options[:allow_changes] == false
      expect(result.stdout).not_to match(%r{^Notice: /Stage\[main\]})
    end
    expect(result.stderr).not_to match(%r{^Error:})
    expect(result.stderr).not_to match(%r{^Warning:})
  end
end

def run_resource(resource_type, resource_title = nil)
  options = { ENV: {
    'FACTER_url' => "file:///#{default[:puppetpath]}/credentials.yaml",
  } }
  if resource_title
    on(master, puppet('resource', resource_type, resource_title, '--trace', options), acceptable_exit_codes: 0).stdout
  else
    on(master, puppet('resource', resource_type, '--trace', options), acceptable_exit_codes: 0).stdout
  end
end

def device_model
  fact('hardwaremodel')
end

RSpec.configure do |c|
  c.before :suite do
    unless ENV['BEAKER_TESTMODE'] == 'local'
      unless ENV['BEAKER_provision'] == 'no'

        hosts.each do |host|
          # java needed by puppet-resource_api on the puppet server
          on(host, 'yum install -y vim java')
          on(host, '/opt/puppetlabs/puppet/bin/gem install pry')
          # set rich data to true for puppet master and agent
          on(host, "sed -i '/.main.$/a rich_data = true' /etc/puppetlabs/puppet/puppet.conf")
          on(host, 'service pe-puppetserver restart', acceptable_exit_codes: [0, 1])
          on host, puppet('plugin', 'download', '--server', host.to_s)
        end
      end

      proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      hosts.each do |host|
        device_conf = <<-EOS
[#{$device_hostname}]
type cisco_ios
url file:///#{default[:puppetpath]}/credentials.yaml
EOS
        create_remote_file(default, File.join(default[:puppetpath], 'device.conf'), device_conf)

        credentials_yaml = <<-EOS
        default: {
  node: {
    address: #{$device_ip}
    port: 22
    username: #{$device_user}
    password: #{$device_password}
    enable_password: #{$device_enable_password}
  }
}
EOS
        create_remote_file(default, File.join(default[:puppetpath], 'credentials.yaml'), credentials_yaml)

        on(host, "echo #{$device_ip} #{$device_hostname} >> /etc/hosts")

        # install puppet-resource_api on to the server
        on(host, 'puppetserver gem install puppet-resource_api --no-ri --no-rdoc')
        apply_manifest('include cisco_ios')
        on host, puppet('plugin', 'download', '--server', host.to_s)
        on host, puppet('device', '-v', '--waitforcert', '0', '--user', 'root', '--server', host.to_s), acceptable_exit_codes: [0, 1]
        on host, puppet('cert', 'sign', '--all'), acceptable_exit_codes: [0, 24]
        on host, puppet('plugin', 'download', '--server', host.to_s)
        on host, puppet('device', '-d', '--user', 'root'), acceptable_exit_codes: [0, 1]
        # restart the server after installing puppet-resource_api
        on(host, 'systemctl restart  pe-puppetserver.service')
      end
    end
  end
end

require 'puppet/util/network_device/cisco/device'

if ENV['COVERAGE'] == 'yes'
  require 'simplecov'
  require 'simplecov-console'
  require 'codecov'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::Codecov,
  ]
  SimpleCov.start do
    track_files 'lib/**/*.rb'

    add_filter '/spec'

    # do not track vendored files
    add_filter '/vendor'
    add_filter '/.vendor'

    # do not track gitignored files
    # this adds about 4 seconds to the coverage check
    # this could definitely be optimized
    add_filter do |f|
      # system returns true if exit status is 0, which with git-check-ignore means file is ignored
      system("git check-ignore --quiet #{f.filename}")
    end
  end
end

RSpec.configure do |c|
  c.before :each do
    # rubocop:disable RSpec/MessageChain
    allow(Puppet::Util::NetworkDevice::Cisco_ios::Device).to receive_message_chain(:transport, :facts)
      .and_return('operatingsystem' => 'cisco_ios', 'operatingsystemrelease' => '12.2(58)SE2', 'hardwaremodel' => 'WS-C6509S-48FPS-L', 'serialnumber' => 'FOC1609Y2LY')
    # rubocop:enable RSpec/MessageChain
  end
end

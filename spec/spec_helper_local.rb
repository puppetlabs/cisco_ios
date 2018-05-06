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

shared_examples 'resources parsed from cli' do
  context 'Read tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it "Read: #{test_name}" do
        fake_device(test['device'])
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
      end
    end
  end
end

shared_examples 'commands created from instance' do
  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        expect(described_class.commands_from_instance(test['instance'])).to eq test['commands']
      end
    end
  end
end

def fake_device(friendly_name)
  @utility = PuppetX::CiscoIOS::Utility
  hardware_model = case friendly_name
                   when '2960'
                     'WS-C2960S-48FPS-L'
                   when '3750'
                     'WS-C3750G-24T'
                   when '4507r'
                     'WS-C4507R'
                   when '4948'
                     'WS-C4948'
                   when '6503'
                     'WS-C6503-E'
                   else
                     raise 'fake_device() device not found, check spec/spec_helper_local.rb or test_data.yaml' unless friendly_name.nil?
                     # default
                     ''
                   end
  @utility.facts('hardwaremodel' => hardware_model)
end

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
        fake_device(test['device'],test['family'])
        expect(described_class.instances_from_cli(test['cli'])).to eq test['expectations']
      end
    end
  end
end

shared_examples 'a noop canonicalizer' do
  context 'canonicalize is called' do
    let(:resources) do
      {
        name:   'foo',
        ensure: 'present',
        foo:    'bar',
      }
    end
    let(:provider) { described_class.new }

    it 'returns the same resource' do
      expect(provider.canonicalize(anything, resources)[:name].object_id).to eq(resources[:name].object_id)
      expect(provider.canonicalize(anything, resources)[:ensure].object_id).to eq(resources[:ensure].object_id)
      expect(provider.canonicalize(anything, resources)[:foo].object_id).to eq(resources[:foo].object_id)
    end

    it 'returns unmodified resource' do
      expect(provider.canonicalize(anything, resources)).to eq(name: 'foo', ensure: 'present', foo: 'bar')
    end
  end
end

shared_examples 'device safe instance' do
  context 'device_safe_instance is called' do
    load_test_data['default']['device_safe_tests'].each do |test_name, test|
      it test_name.to_s do
        utility = fake_device(test['device'],test['family'])
        require 'pry'; binding.pry
        if test['returned_instance'].nil?
          expect { utility.device_safe_instance(test['instance'], described_class.commands_hash) }.to raise_error(%r{.*})
        else
          expect(utility.device_safe_instance(test['instance'], described_class.commands_hash)).to eq test['returned_instance']
        end
      end
    end
  end
end

shared_examples 'commands created from instance' do
  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'],test['family'])
        if test['commands'].size.zero?
          expect { described_class.commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          expect(described_class.commands_from_instance(test['instance'])).to eq test['commands']
        end
      end
    end
  end
end

def fake_device(friendly_name, family_name=nil)
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
  family = fake_family(family_name)
  @utility.facts({'hardwaremodel' => hardware_model ,'os' => {'family' => family}})
  @utility
end

def fake_family(family_name)
  @utility = PuppetX::CiscoIOS::Utility
  if family_name.nil?
    family = 'foo Software'
  else
    family = family_name
  end
  family
end

# only a short selection for spot-checks
def server_os
  {
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['8'],
      },
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['7'],
      },
    ],
  }
end

# only a short selection for spot-checks
def proxy_os
  {
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['8'],
      },
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['7'],
      },
      {
        'operatingsystem'        => 'Windows',
        'operatingsystemrelease' => ['2008 R2', '2012 R2', '10'],
      },
    ],
  }
end

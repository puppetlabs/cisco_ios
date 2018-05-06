require 'puppet_x'
require 'pry'
require 'spec_helper'
require 'puppet_x/puppetlabs/cisco_ios/utility'

RSpec.describe PuppetX::CiscoIOS::Utility do # rubocop:disable RSpec/FilePath
  let(:utility) { described_class }

  describe 'value_foraged_from_command_hash' do
    it 'default key hits' do
      command_hash = { 'get_values' => { 'default' => 'show interfaces <name> switchport' } }
      result = utility.value_foraged_from_command_hash(command_hash, 'get_values')
      expect(result).to eq 'show interfaces <name> switchport'
    end
    it 'device specific key hits 6503' do
      utility.facts('hardwaremodel' => 'WS-C6503S-48FPS-L')
      command_hash = { 'get_values' => { 'default' => 'show interfaces <name> switchport', '6503' => '6503 show interfaces <name> switchport' } }
      result = utility.value_foraged_from_command_hash(command_hash, 'get_values')
      expect(result).to eq '6503 show interfaces <name> switchport'
    end
    it 'device specific key hits 6503, not 2960' do
      utility.facts('hardwaremodel' => 'WS-C6503S-48FPS-L')
      command_hash = { 'get_values' => { 'default' => 'show interfaces <name> switchport', '2960' => '2960 show interfaces <name> switchport', '6503' => '6503 show interfaces <name> switchport' } }
      result = utility.value_foraged_from_command_hash(command_hash, 'get_values')
      expect(result).to eq '6503 show interfaces <name> switchport'
    end
    it 'key does not exist' do
      command_hash = { 'get_values' => { 'default' => 'show interfaces <name> switchport' } }
      expect { utility.value_foraged_from_command_hash(command_hash, 'wrong_key') }.to raise_error(%r{This key})
    end
  end

  describe 'attribute_value_foraged_from_command_hash' do
    it 'default key hits' do
      command_hash = { 'attributes' => { 'mtu' => { 'default' => { 'get_value' => 'mtu (?<mtu>\S*)' } } } }
      result = utility.attribute_value_foraged_from_command_hash(command_hash, 'mtu', 'get_value', false)
      expect(result).to eq 'mtu (?<mtu>\S*)'
    end
    it 'default key misses, attribute_can_be_nil false' do
      command_hash = { 'attributes' => { 'mtu' => { 'default' => { 'get_value' => 'mtu (?<mtu>\S*)' } } } }
      expect { utility.attribute_value_foraged_from_command_hash(command_hash, 'mtu', 'wrong_key', false) }.to raise_error(%r{This key})
    end
    it 'default key misses, attribute_can_be_nil true' do
      command_hash = { 'attributes' => { 'mtu' => { 'default' => { 'get_value' => 'mtu (?<mtu>\S*)' } } } }
      result = utility.attribute_value_foraged_from_command_hash(command_hash, 'mtu', 'wrong_key', true)
      expect(result).to eq nil
    end
    it 'device specific key hits 6503' do
      utility.facts('hardwaremodel' => 'WS-C6503S-48FPS-L')
      command_hash = { 'attributes' => { 'mtu' => { 'default' => { 'get_value' => 'mtu (?<mtu>\S*)' }, '6503' => { 'get_value' => '6503 mtu (?<mtu>\S*)' } } } }
      result = utility.attribute_value_foraged_from_command_hash(command_hash, 'mtu', 'get_value', false)
      expect(result).to eq '6503 mtu (?<mtu>\S*)'
    end
    it 'device specific key hits 6503, not 2960' do
      utility.facts('hardwaremodel' => 'WS-C6503S-48FPS-L')
      command_hash = { 'attributes' => { 'mtu' => { 'default' => { 'get_value' => 'mtu (?<mtu>\S*)' }, '6503' => { 'get_value' => '6503 mtu (?<mtu>\S*)' }, '2960' => { 'get_value' => '2960 mtu (?<mtu>\S*)' } } } } # rubocop:disable Metrics/LineLength
      result = utility.attribute_value_foraged_from_command_hash(command_hash, 'mtu', 'get_value', false)
      expect(result).to eq '6503 mtu (?<mtu>\S*)'
    end
  end

  describe 'get_interface_names' do
    it 'value does exist' do
      command_hash = { 'get_values' => { 'default' => 'show interfaces <name> switchport' },
                       'get_interfaces_command' => { 'default' => 'show running-config | include ^interface' } }
      result = utility.get_interface_names(command_hash)
      expect(result).to eq 'show running-config | include ^interface'
    end
    it 'value does not exist' do
      command_hash = { 'get_values' => { 'default' => 'show interfaces <name> switchport' } }
      expect { utility.get_interface_names(command_hash) }.to raise_error(%r{This key})
    end
  end

  describe 'get_values' do
    it 'value does exist' do
      command_hash = { 'get_values' => { 'default' => 'show interfaces <name> switchport' },
                       'get_interfaces_command' => { 'default' => 'show running-config | include ^interface' } }
      result = utility.get_values(command_hash)
      expect(result).to eq 'show interfaces <name> switchport'
    end
    it 'value does not exist' do
      command_hash = { 'get_interfaces_command' => { 'default' => 'show running-config | include ^interface' } }
      expect { utility.get_values(command_hash) }.to raise_error(%r{This key})
    end
  end

  describe 'get_instances' do
    it 'value does exist' do
      command_hash = { 'get_instances' => { 'default' => 'show interfaces <name> switchport' },
                       'get_interfaces_command' => { 'default' => 'show running-config | include ^interface' } }
      result = utility.get_instances(command_hash)
      expect(result).to eq 'show interfaces <name> switchport'
    end
    it 'value does not exist' do
      command_hash = { 'get_interfaces_command' => { 'default' => 'show running-config | include ^interface' } }
      expect { utility.get_instances(command_hash) }.to raise_error(%r{This key})
    end
  end

  describe 'convert_speed_int_to_modelled_value' do
    it '10 becomes 10m' do
      result = utility.convert_speed_int_to_modelled_value('10')
      expect(result).to eq '10m'
    end
    it '100 becomes 100m' do
      result = utility.convert_speed_int_to_modelled_value('100')
      expect(result).to eq '100m'
    end
    it '1000 becomes 1g' do
      result = utility.convert_speed_int_to_modelled_value('1000')
      expect(result).to eq '1g'
    end
    it '1111 becomes 1111' do
      result = utility.convert_speed_int_to_modelled_value('1111')
      expect(result).to eq '1111'
    end
  end

  describe 'convert_modelled_speed_value_to_int' do
    it '10m becomes 10' do
      result = utility.convert_modelled_speed_value_to_int('10m')
      expect(result).to eq '10'
    end
    it '100m becomes 100' do
      result = utility.convert_modelled_speed_value_to_int('100m')
      expect(result).to eq '100'
    end
    it '1g becomes 1000' do
      result = utility.convert_modelled_speed_value_to_int('1g')
      expect(result).to eq '1000'
    end
    it '1111 becomes 1111' do
      result = utility.convert_modelled_speed_value_to_int('1111')
      expect(result).to eq '1111'
    end
  end
end

require 'puppet_x'
require 'spec_helper'
require 'puppet_x/puppetlabs/cisco_ios/utility'

RSpec.describe PuppetX::CiscoIOS::Utility do # rubocop:disable RSpec/FilePath
  let(:utility) { described_class }

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

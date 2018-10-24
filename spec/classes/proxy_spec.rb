require 'spec_helper'

describe 'cisco_ios::proxy' do
  on_supported_os(proxy_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end

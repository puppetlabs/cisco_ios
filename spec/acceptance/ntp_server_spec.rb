require 'spec_helper_acceptance'

describe 'should change an ntp_server' do
  it 'change the values of said ntp_server' do
    pp = <<-EOS
ntp_server { '1.2.3.4':
  key    => '42',
  ensure => 'present',
}
EOS
    make_site_pp(pp)
    run_device(options={:allow_changes => true})
    # Are we idempotent
    run_device(options={:allow_changes => false})
    # Check puppet resource
    result = run_resource('ntp_server', '1.2.3.4')
    expect(result).to match(/key.* => '42',/)
  end
end

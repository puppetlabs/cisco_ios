require 'spec_helper_acceptance'

describe 'ios_session_id' do
  it 'apply session_id common' do
    pp = <<-EOS
    ios_config { "enable aaa":
      command => 'aaa new-model'
    }
    ios_aaa_session_id { 'default':
      session_id_type => 'common',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_session_id', 'default')
    expect(result).to match(%r{session_id_type.*common})
  end

  it 'apply session_id unique' do
    pp = <<-EOS
     ios_aaa_session_id { 'default':
      session_id_type => 'unique',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('ios_aaa_session_id', 'default')
    expect(result).to match(%r{session_id_type.*unique})
  end
end

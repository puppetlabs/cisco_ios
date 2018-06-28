# NOTE - these tests are disabled as being potentially destructive to logins and hence connectivity
# They are kept commented out as a reference. They have been tested manually and are still tested as unit tests.
#
# --------------------------------------------------------------------------------------------------------------
#
# require 'spec_helper_acceptance'
#
# describe 'ios_aaa_new_model' do
#   existing_enabled = false
#
#   before(:all) do
#     result = run_resource('ios_aaa_new_model', 'default')
#     if result =~ %r{enable.*true}
#       existing_enabled = true
#     end
#
#     # Set to known values
#     pp = <<-EOS
#     ios_aaa_new_model { "default":
#       enable => false,
#     }
#     EOS
#     make_site_pp(pp)
#     run_device(allow_changes: true)
#   end
#
#   it 'enable new model' do
#     pp = <<-EOS
#     ios_aaa_new_model { "default":
#       enable => true,
#     }
#     EOS
#     make_site_pp(pp)
#     run_device(allow_changes: true)
#     # Are we idempotent
#     run_device(allow_changes: false)
#     # Check puppet resource
#     result = run_resource('ios_aaa_new_model', 'default')
#     expect(result).to match(%r{default.*})
#     expect(result).to match(%r{enable.*true})
#   end
#
#   it 'disable new model' do
#     pp = <<-EOS
#     ios_aaa_new_model { "default":
#       enable => false,
#     }
#     EOS
#     make_site_pp(pp)
#     run_device(allow_changes: true)
#     # Are we idempotent
#     run_device(allow_changes: false)
#     # Check puppet resource
#     result = run_resource('ios_aaa_new_model', 'default')
#     expect(result).to match(%r{default.*})
#     expect(result).to match(%r{enable.*false})
#   end
#
#   after(:all) do
#     # Set to previous value
#     pp = <<-EOS
#     ios_aaa_new_model { "default":
#       enable => #{existing_enabled},
#     }
#     EOS
#     make_site_pp(pp)
#     run_device(allow_changes: true)
#   end
# end

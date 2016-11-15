# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Bugra Barin

require 'testup/testcase'

# module Sketchup::Licensing
# http://www.sketchup.com/intl/developer/docs/ourdoc/licensing
#
# Licensing tests are not repeatable unless we find a way to mock the licensing
# internals. So, just doing API example and parameter tests.
class TC_Sketchup_Licensing < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end

  # ========================================================================== #
  # method Sketchup::Licensing.get_extension_license
  # http://www.sketchup.com/intl/developer/docs/ourdoc/licensing#get_extension_license

  def test_get_extension_license_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    if ext_lic.licensed?
       puts "Extension is licensed."
    end
  end

  def test_get_extension_license_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      Sketchup::Licensing.get_extension_license
    end
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    assert_raises ArgumentError do
      Sketchup::Licensing.get_extension_license(ext_id, 0)
    end
  end

  def test_get_extension_license_incorrect_type_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises TypeError do
      Sketchup::Licensing.get_extension_license(1)
    end
    assert_raises TypeError do
      Sketchup::Licensing.get_extension_license(nil)
    end
  end

end # class

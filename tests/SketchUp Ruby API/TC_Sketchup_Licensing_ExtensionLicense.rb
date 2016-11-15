# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Bugra Barin

require 'testup/testcase'

# class Sketchup::Licensing::ExtensionLicense
# http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense
#
# Licensing tests are not repeatable unless we find a way to mock the licensing
# internals. So, just doing API example and parameter tests.
class TC_Sketchup_Licensing_ExtensionLicense < TestUp::TestCase

  def setup
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    @ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
  end

  def teardown
    # ...
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.licensed?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#licensed?

  def test_licensed_Query_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    if ext_lic.licensed?
       puts "Extension is licensed."
    end
  end

  def test_licensed_Query_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      @ext_lic.licensed?("")
    end
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.state
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#state

  def test_state_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    if ext_lic.state == Sketchup::Licensing::TRIAL_EXPIRED
       puts "Trial period has expired."
    end
  end

  def test_state_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      @ext_lic.state("")
    end
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.days_remaining
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#days_remaining

  def test_days_remaining_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    if ext_lic.days_remaining != 0
       puts "The license will expire in #{ext_lic.days_remaining} days."
    end
    # Just repeating this so that it always gets tested
    puts "The license will expire in #{ext_lic.days_remaining} days."
  end

  def test_days_remaining_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      @ext_lic.days_remaining("")
    end
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.error_description
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#error_description

  def test_error_description_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    if !ext_lic.licensed?
       puts ext_lic.error_description
    end
  end

  def test_error_description_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      @ext_lic.error_description("")
    end
  end

end # class

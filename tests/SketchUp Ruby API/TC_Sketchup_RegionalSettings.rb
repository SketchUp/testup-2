# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen

require 'testup/testcase'

# module Sketchup::RegionalSettings
# http://www.sketchup.com/intl/developer/docs/ourdoc/locale
class TC_Sketchup_RegionalSettings < TestUp::TestCase

  # Technically this can be other values, but this is what 99.99% of locale
  # settings. (Data pulled from thin air...)
  EXPECTED_DECIMAL_SEPARATORS = ['.', ','].freeze
  EXPECTED_LIST_SEPARATORS    = [',', ';'].freeze


  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::RegionalSettings.decimal_separator
  # http://www.sketchup.com/intl/developer/docs/ourdoc/locale#decimal_separator

  def test_decimal_separator_api_example
    skip("Implemented in SU2016 M1") if Sketchup.version.to_i < 16
    # Format a Float using the user's locale settings.
    # Ruby's Float.to_s always use period as decimal separator.
    formatted = 0.123.to_s.tr('.', Sketchup::RegionalSettings.decimal_separator)
  end

  def test_decimal_separator
    result = Sketchup::RegionalSettings.decimal_separator
    assert_kind_of(String, result)
    assert_equal(1, result.size)
    assert_includes(EXPECTED_DECIMAL_SEPARATORS, result)
  end

  def test_decimal_separator_incorrect_number_of_arguments
    skip("Implemented in SU2016 M1") if Sketchup.version.to_i < 16
    assert_raises ArgumentError do
      Sketchup::RegionalSettings.decimal_separator(1)
    end
  end


  # ========================================================================== #
  # method Sketchup::RegionalSettings.list_separator
  # http://www.sketchup.com/intl/developer/docs/ourdoc/locale#list_separator

  def test_list_separator_api_example
    skip("Implemented in SU2016 M1") if Sketchup.version.to_i < 16
    # Format a CSV list in user's locale:
    decimal = Sketchup::RegionalSettings.decimal_separator
    list = Sketchup::RegionalSettings.list_separator
    row = [3.14, 1.618, 2.718]
    csv = row.map { |value| value.to_s.tr('.', decimal) }.join(list)
  end

  def test_list_separator
    result = Sketchup::RegionalSettings.list_separator
    assert_kind_of(String, result)
    assert_equal(1, result.size)
    assert_includes(EXPECTED_LIST_SEPARATORS, result)
  end

  def test_list_separator_incorrect_number_of_arguments
    skip("Implemented in SU2016 M1") if Sketchup.version.to_i < 16
    assert_raises ArgumentError do
      Sketchup::RegionalSettings.list_separator(1)
    end
  end


end # class

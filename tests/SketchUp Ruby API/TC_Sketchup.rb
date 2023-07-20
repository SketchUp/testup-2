# Copyright:: Copyright 2014-2019 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"
require_relative "utils/length"


# module Sketchup
class TC_Sketchup < TestUp::TestCase

  include TestUp::SketchUpTests::Length

  def self.setup_testcase
    discard_all_models
  end

  def setup
    # ...
  end

  def teardown
    # ...
  end


  def assert_boolean(value)
    assert(value.is_a?(TrueClass) || value.is_a?(FalseClass))
  end

  def get_test_case_file(filename)
    File.join(__dir__, File.basename(__FILE__, '.*'), filename)
  end

  def enable_manual_tests?
    ENV.include?('TESTUP_MANUAL_TESTS')
  end


  # ========================================================================== #
  # method Sketchup.signed_in?

  def test_signed_in_Query
    skip('Added in SU2019.3') if Sketchup.version.to_f < 19.3
    # Since this related to UI dialogs there is limited testing that can be done
    # via these Ruby tests. Manual testing needs to be done.
    result = Sketchup.signed_in?
    assert_boolean(result)
    assert_equal(0, Sketchup.method(:signed_in?).arity)
  end


  # ========================================================================== #
  # method Sketchup.sign_in

  def test_sign_in
    skip('Added in SU2019.3') if Sketchup.version.to_f < 19.3
    # Since this related to UI dialogs there is limited testing that can be done
    # via these Ruby tests. Manual testing needs to be done.
    sign_in_method = Sketchup.method(:sign_in)
    assert_equal(-1, sign_in_method.arity)
  end


  # ========================================================================== #
  # method Sketchup.format_length

  def test_format_length_custom_precision
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Millimeter
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch, 4)
    assert_kind_of(String, result)
    assert_unit(%[406.4000 mm], result)
  end

  def test_format_length_custom_precision_strip_trailing_zeros
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Millimeter
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch, -4)
    assert_kind_of(String, result)
    assert_unit(%[406.4 mm], result)
  end

  def test_format_length_custom_precision_rounding
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Millimeter
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(12.3456789.mm, 4)
    assert_kind_of(String, result)
    assert_unit(%[12.3457 mm], result)
  end

  def test_format_length_decimal_inches
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch)
    assert_kind_of(String, result)
    assert_unit(%[16.00"], result)
  end

  def test_format_length_architectural_inches
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Architectural
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch)
    assert_kind_of(String, result)
    assert_unit(%[1' 4"], result)
  end

  def test_format_length_engineering_inches
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Engineering
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch)
    assert_kind_of(String, result)
    assert_unit(%[~ 1.33'], result)
  end

  def test_format_length_fractional_inches
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Fractional
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch)
    assert_kind_of(String, result)
    assert_unit(%[16"], result)
  end

  def test_format_length_mm
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Millimeter
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch)
    assert_kind_of(String, result)
    assert_unit(%[406.40 mm], result)
  end

  def test_format_length_m
    unit_options = Sketchup.active_model.options['UnitsOptions']
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Meter
    unit_options['LengthPrecision'] = 2
    result = Sketchup.format_length(16.inch)
    assert_kind_of(String, result)
    assert_unit(%[~ 0.41 m], result)
  end

  def test_format_length_invalid_arguments_nil
    assert_raises(TypeError) do
      Sketchup.format_length(nil)
    end
  end

  def test_format_length_invalid_arguments_string
    assert_raises(TypeError) do
      Sketchup.format_length("123")
    end
  end

  def test_format_length_wrong_number_of_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.format_length
    end
  end

  def test_format_length_wrong_number_of_arguments_three
    skip('Bug: The method ignores extra arguments.')
    assert_raises(ArgumentError) do
      Sketchup.format_length(123, 2, 456)
    end
  end


  # ========================================================================== #
  # method Sketchup.format_area

  def test_format_area_decimal_m
    unit_options = Sketchup.active_model.options['UnitsOptions']
    # Make sure Length is a different unit.
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Millimeter
    unit_options['LengthPrecision'] = 2
    unit_options['AreaUnit'] = Length::SquareMeter
    result = Sketchup.format_area(3300.mm * 4400.mm)
    assert_kind_of(String, result)
    assert_unit(%[14.52 m²], result)
  end

  def test_format_area_decimal_feet
    unit_options = Sketchup.active_model.options['UnitsOptions']
    # Make sure Length is a different unit.
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    unit_options['AreaUnit'] = Length::SquareFeet
    result = Sketchup.format_area(3300.mm * 4400.mm)
    assert_kind_of(String, result)
    assert_unit(%[156.29 ft²], result)
  end

  def test_format_area_architectural_feet
    unit_options = Sketchup.active_model.options['UnitsOptions']
    # Make sure Length is a different unit.
    unit_options['LengthFormat'] = Length::Architectural
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    unit_options['AreaUnit'] = Length::SquareFeet
    result = Sketchup.format_area(3300.mm * 4400.mm)
    assert_kind_of(String, result)
    # Architectural units always format in feet and inches
    assert_unit(%[156.29 ft²], result)
  end

  def test_format_area_engineering_feet
    unit_options = Sketchup.active_model.options['UnitsOptions']
    # Make sure Length is a different unit.
    unit_options['LengthFormat'] = Length::Engineering
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    unit_options['AreaUnit'] = Length::SquareFeet
    result = Sketchup.format_area(3300.mm * 4400.mm)
    assert_kind_of(String, result)
    # Fractional units always format in feet
    assert_unit(%[156.29 ft²], result)
  end

  def test_format_area_fractional_feet
    unit_options = Sketchup.active_model.options['UnitsOptions']
    # Make sure Length is a different unit.
    unit_options['LengthFormat'] = Length::Fractional
    unit_options['LengthUnit'] = Length::Inches
    unit_options['LengthPrecision'] = 2
    unit_options['AreaUnit'] = Length::SquareFeet
    result = Sketchup.format_area(3300.mm * 4400.mm)
    assert_kind_of(String, result)
    # Fractional units always format in inches
    assert_unit(%[22506.05 in²], result)
  end

  def test_format_area_invalid_arguments_nil
    assert_raises(TypeError) do
      Sketchup.format_area(nil)
    end
  end

  def test_format_area_invalid_arguments_string
    assert_raises(TypeError) do
      Sketchup.format_area("123")
    end
  end

  def test_format_area_wrong_number_of_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.format_area
    end
  end

  def test_format_area_wrong_number_of_arguments_two
    assert_raises(ArgumentError) do
      Sketchup.format_area(123, 456)
    end
  end


  # ========================================================================== #
  # method Sketchup.format_volume

  def test_format_volume
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    unit_options = Sketchup.active_model.options['UnitsOptions']
    # Make sure Length is a different unit.
    unit_options['LengthFormat'] = Length::Decimal
    unit_options['LengthUnit'] = Length::Millimeter
    unit_options['LengthPrecision'] = 2
    unit_options['VolumeUnit'] = Length::CubicMeter
    result = Sketchup.format_volume(3300.mm * 4400.mm * 5500.mm)
    assert_kind_of(String, result)
    assert_unit(%[79.86 m³], result)
  end

  def test_format_volume_invalid_arguments_nil
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    assert_raises(TypeError) do
      Sketchup.format_volume(nil)
    end
  end

  def test_format_volume_invalid_arguments_string
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    assert_raises(TypeError) do
      Sketchup.format_volume("123")
    end
  end

  def test_format_volume_wrong_number_of_arguments_zero
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    assert_raises(ArgumentError) do
      Sketchup.format_volume
    end
  end

  def test_format_volume_wrong_number_of_arguments_two
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    assert_raises(ArgumentError) do
      Sketchup.format_volume(123, 456)
    end
  end


  # ========================================================================== #
  # method Sketchup.debug_mode?

  def test_debug_mode_Query_api_example
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16
    debug_mode = Sketchup.debug_mode?
  end

  def test_debug_mode_Query
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16
    original_mode = Sketchup.debug_mode?

    Sketchup.debug_mode = true
    assert_equal(true, Sketchup.debug_mode?)

    Sketchup.debug_mode = false
    assert_equal(false, Sketchup.debug_mode?)
  ensure
    Sketchup.debug_mode = original_mode
  end

  def test_debug_mode_Query_incorrect_number_of_arguments
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16
    assert_raises ArgumentError do
      Sketchup.debug_mode?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup.is_64bit?

  def test_is_64bit_Query_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    # For backward compatibility, check for the existence of the method
    # and load 32bit binaries for SketchUp versions that do not have this
    # method.
    if Sketchup.respond_to?(:is_64bit?) && Sketchup.is_64bit?
      # Load 64bit binaries.
    else
      # Load 32bit binaries.
    end
  end

  def test_is_64bit_Query
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    pointer_size = ['a'].pack('P').size * 8
    expected = pointer_size == 64
    result = Sketchup.is_64bit?
    assert_equal(expected, result)
  end

  def test_is_64bit_Query_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      Sketchup.is_64bit?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup.platform

  def test_platform
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    result = Sketchup.platform
    assert_kind_of(Symbol, result)
    if windows?
      assert_equal(:platform_win, result)
    else
      assert_equal(:platform_osx, result)
    end
  end

  def test_template
    result = Sketchup.template
    assert(result != "", "Template is blank")
    assert(result.downcase.end_with?(".skp"), "Template is not a SKP file")
  end

  def test_template_Set
    # Get the current template
    orig_template = Sketchup.template

    begin
      # Get a different template from the Templates folder
      template_dir = Sketchup.get_resource_path("Templates")
      new_template = ""
      Dir.entries(template_dir).each do |template|
        next if !template.downcase.end_with?('.skp')
        next if orig_template.downcase.end_with?(template.downcase)
        new_template = File.join(template_dir, template)
        break
      end

      assert(new_template != "", "Could not find any templates.")

      # Set the default template and verify it set properly
      Sketchup.template = new_template
      new_default = Sketchup.template
      assert_equal(new_template, new_default, "Default template did not save properly.")

    ensure
      Sketchup.template = orig_template
    end
  end


  # ========================================================================== #
  # method Sketchup.open_file

  def test_open_file_success
    open_new_model # Ensure we haven't already opened a model
    filename = get_test_case_file('skp-v6.skp')
    result = Sketchup.open_file(filename)
    assert(result)
    assert_equal(filename, File.expand_path(Sketchup.active_model.path))
  ensure
    close_active_model
  end

  def test_open_file_failure
    skip('Failures display modal dialoges :(') unless enable_manual_tests?
    open_new_model # Ensure we haven't already opened a model
    result = Sketchup.open_file('fake-filename.skp')
    refute(result)
  ensure
    close_active_model
  end

  def test_open_file_invalid_argument_nil
    assert_raises(TypeError) do
      Sketchup.open_file(nil)
    end
  end

  def test_open_file_invalid_argument_numeric
    assert_raises(TypeError) do
      Sketchup.open_file(123)
    end
  end

  def test_open_file_incorrect_number_of_arguments_too_few
    assert_raises(ArgumentError) do
      Sketchup.open_file
    end
  end

  def test_open_file_incorrect_number_of_arguments_too_many
    filename = get_test_case_file('skp-v6.skp')
    assert_raises ArgumentError do
      Sketchup.open_file(filename, 123)
    end
  end

  def test_open_file_with_status_success
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    open_new_model # Ensure we haven't already opened a model
    filename = get_test_case_file('skp-v6.skp')
    status = Sketchup.open_file(filename, with_status: true)
    assert_equal(Sketchup::Model::LOAD_STATUS_SUCCESS, status)
    assert_equal(filename, File.expand_path(Sketchup.active_model.path))
  ensure
    close_active_model
  end

  def test_open_file_warn_on_deprecated_overload
    skip("Changed in SU2021.0") if Sketchup.version.to_i < 21
    filename = get_test_case_file('skp-v6.skp')
    assert_output(nil, /Deprecated overload, use with_status: true overload instead/) do
      Sketchup.open_file(filename)
    end
  ensure
    close_active_model
  end

  def test_open_file_legacy_overload_should_not_open_soft_block
    skip("Changed in SU2021.0") if Sketchup.version.to_i < 21
    filename = get_test_case_file('skp-vff-soft-block.skp')
    status = Sketchup.open_file(filename)
    refute(status, "Should not open soft blocked file")
    refute_equal(filename, File.expand_path(Sketchup.active_model.path))
  ensure
    close_active_model
  end

  def test_open_file_with_status_success_more_recent
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    skip('Soft-block display modal dialoges :(') unless enable_manual_tests?
    open_new_model # Ensure we haven't already opened a model
    filename = get_test_case_file('skp-vff-soft-block.skp')
    status = Sketchup.open_file(filename, with_status: true)
    assert_equal(Sketchup::Model::LOAD_STATUS_SUCCESS_MORE_RECENT, status)
    assert_equal(filename, File.expand_path(Sketchup.active_model.path))
  ensure
    close_active_model
  end

  def test_open_file_with_status_failure
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    skip('Failures display modal dialoges :(') unless enable_manual_tests?
    filename = get_test_case_file('skp-vff-hard-block.skp')
    status = Sketchup.open_file(filename, with_status: true)
    refute(status)
    refute_equal(filename, File.expand_path(Sketchup.active_model.path))
  end


  # ========================================================================== #
  # method Sketchup.resize_viewport

  # Successful cases tasted manually with SKEXT3295.rb.

  def test_resize_viewport_invalid_argument_nil
    skip("Added in SU2023.0") if Sketchup.version.to_f < 23.0
    assert_raises(TypeError) do
      Sketchup.resize_viewport(nil, 3048, 2870)
    end
  end

  def test_resize_viewport_invalid_argument_numeric
    skip("Added in SU2023.0") if Sketchup.version.to_f < 23.0

    assert_raises(TypeError) do
      Sketchup.resize_viewport(3000, 3048, 2870)
    end

    assert_raises(TypeError) do
      Sketchup.resize_viewport(Sketchup.active_model, Sketchup::Face, 2870)
    end

    assert_raises(TypeError) do
      Sketchup.resize_viewport(Sketchup.active_model, 3048, Sketchup::Face)
    end
  end

  def test_resize_viewport_incorrect_number_of_arguments_too_few
    skip("Added in SU2023.0") if Sketchup.version.to_f < 23.0
    assert_raises(ArgumentError) do
      Sketchup.resize_viewport
    end
  end

  def test_resize_viewport_incorrect_number_of_arguments_too_many
    skip("Added in SU2023.0") if Sketchup.version.to_f < 23.0
    assert_raises ArgumentError do
      Sketchup.resize_viewport(Sketchup.active_model, 3084, 4502, 3056)
    end
  end


end # class

# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Yogesh Biyani
require "testup/testcase"

class TC_String < TestUp::TestCase

  def setup
    # ...
    model = Sketchup.active_model
    model.options['UnitsOptions']['LengthFormat'] = Length::Architectural
  end

  def teardown
    # ...
  end

  # Takes a length string with period decimal separator and converts it into the
  # system locale separator.
  def get_locale_string(string)
    string.tr('.', Sketchup::RegionalSettings.decimal_separator)
  end

  def test_to_l
    output = '12"'.to_l
    assert_equal(12, output)
    assert_kind_of(Length, output)

  end

  def test_to_l_empty_string
    output = ''.to_l
    assert_equal(0, output)
    assert_kind_of(Length, output)

  end

  def test_to_l_nil_string
    assert_raises(ArgumentError) do
      '12"'.to_l(nil)
    end
  end


  def test_to_l_garbage_string
    assert_raises(ArgumentError) do
      'abcded"'.to_l
    end
  end


  def test_string_250cm
    model = Sketchup.active_model
    a_string = get_locale_string("250cm")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(98.4251, output)
  end

  def test_string_minus250cm
    model = Sketchup.active_model
    a_string = get_locale_string("-250cm")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(-98.4251, output)
  end

  def test_string_250dot5123cm
    model = Sketchup.active_model
    a_string = get_locale_string("250.5123cm")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(98.626889764, output)
  end

  def test_string_minus250dot5123cm
    model = Sketchup.active_model
    a_string = get_locale_string("-250.5123cm")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(-98.626889764, output)
  end


  def test_string_1feet
    model = Sketchup.active_model
    a_string = get_locale_string("1'")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(12, output)
  end

  def test_string_minus1feet
    model = Sketchup.active_model
    a_string = get_locale_string("-1'")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(-12, output)
  end

  def test_string_12feet
    model = Sketchup.active_model
    a_string = get_locale_string("12'")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(144, output)
  end

  def test_string_minus12feet
    model = Sketchup.active_model
    a_string = get_locale_string("-12'")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(-144, output)
  end

  def test_string_10meters
    model = Sketchup.active_model
    a_string = get_locale_string("10m")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(393.701, output)
  end

  def test_string_minus10meters
    model = Sketchup.active_model
    a_string = get_locale_string("-10m")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(-393.701, output)
  end

  def test_string_25dot40mm
    model = Sketchup.active_model
    a_string = get_locale_string("25.40mm")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(1, output)
  end

  def test_string_minus25dot40mm
    model = Sketchup.active_model
    a_string = get_locale_string("-25.40mm")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(-1, output)
  end

  def test_string_123dot45678inch
    model = Sketchup.active_model
    a_string = get_locale_string("123.45678in")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(123.45678, output)
  end

  def test_string_minus123dot45678inch
    model = Sketchup.active_model
    a_string = get_locale_string("-123.45678in")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(-123.45678, output)
  end

  def test_string_approx10inch
    model = Sketchup.active_model
    a_string = get_locale_string("~10'")
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(120, output)
  end

  def test_string_12feet_6inches
    model = Sketchup.active_model
    a_string = get_locale_string(%(12'6"))
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(150, output)
  end

  def test_string_leading_spaces
    model = Sketchup.active_model
    a_string = get_locale_string('  123.456"')
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(123.456, output)
  end

  def test_string_half_inch
    model = Sketchup.active_model
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    a_string = get_locale_string('1/2"')
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(0.5, output)
  end

  def test_string_half_meter
    model = Sketchup.active_model
    model.options['UnitsOptions']['LengthFormat'] = Length::Decimal
    model.options['UnitsOptions']['LengthUnit'] = Length::Meter
    a_string = get_locale_string('1/2')
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(19.685, output)
  end

  def test_string_half_meter_decimal
    model = Sketchup.active_model
    model.options['UnitsOptions']['LengthFormat'] = Length::Decimal
    model.options['UnitsOptions']['LengthUnit'] = Length::Meter
    model.options['UnitsOptions']['LengthPrecision'] = 3
    a_string = get_locale_string('0.5')
    output = a_string.to_l
    assert_kind_of(Length, output)
    assert_equal(19.685, output)
  end

end


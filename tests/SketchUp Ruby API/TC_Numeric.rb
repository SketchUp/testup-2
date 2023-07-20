# Copyright 2018 Trimble Inc. All Rights Reserved.
# License:: The MIT License (MIT)
# Author: jinyi@sketchup.com (Jin Yi)


require "testup/testcase"

class TC_Numeric < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    # ...
  end

  def teardown
    # ...
  end

  def test_cm
    start_with_empty_model
    cm = 12.7
    inches = cm.cm
    assert_equal(5, inches)
    assert_kind_of(Length, inches)
  end

  def test_cm_invalid_parameters
    start_with_empty_model
    cm = 12.7
    assert_raises(ArgumentError) do
      cm.cm(nil)
    end
  end

  def test_degrees
    start_with_empty_model
    degrees = 90
    radians = degrees.degrees
    assert_equal(1.570796326794897, radians)
    assert_kind_of(Float, radians)
  end

  def test_degrees_invalid_parameters
    start_with_empty_model
    degrees = 90
    assert_raises(ArgumentError) do
      degrees.degrees(nil)
    end
  end

  def test_feet
    start_with_empty_model
    feet = 1
    inches = feet.feet
    assert_equal(12, inches)
    assert_kind_of(Length, inches)
  end

  def test_feet_invalid_parameters
    start_with_empty_model
    feet = 1
    assert_raises(ArgumentError) do
      feet.feet(nil)
    end
  end

  def test_inch
    start_with_empty_model
    num = 12
    length = num.inch
    assert_equal(12, length)
    assert_kind_of(Length, length)
  end

  def test_inch_invalid_parameters
    start_with_empty_model
    num = 12
    assert_raises(ArgumentError) do
      num.inch(nil)
    end
  end

  def test_km
    start_with_empty_model
    km = 1
    inches = km.km
    assert_equal(39370.07874015748, inches)
    assert_kind_of(Length, inches)
  end

  def test_km_invalid_parameters
    start_with_empty_model
    km = 1
    assert_raises(ArgumentError) do
      km.km(nil)
    end
  end

  def test_m
    start_with_empty_model
    m = 1
    inches = m.m
    assert_equal(39.37007874015748, inches)
    assert_kind_of(Length, inches)
  end

  def test_m_invalid_parameters
    start_with_empty_model
    m = 1
    assert_raises(ArgumentError) do
      m.m(nil)
    end
  end

  def test_mile
    start_with_empty_model
    miles = 1
    inches = miles.mile
    assert_equal(63360, inches)
    assert_kind_of(Length, inches)
  end

  def test_mile_invalid_parameters
    start_with_empty_model
    miles = 1
    assert_raises(ArgumentError) do
      miles.mile(nil)
    end
  end

  def test_mm
    start_with_empty_model
    num = 10
    mm = num.mm
    assert_equal(0.3937007874015748, mm)
    assert_kind_of(Length, mm)
  end

  def test_mm_invalid_parameters
    start_with_empty_model
    num = 10
    assert_raises(ArgumentError) do
      num.mm(nil)
    end
  end

  def test_radians
    start_with_empty_model
    radians = Math::PI/2
    degrees = radians.radians
    assert_equal(90, degrees)
    assert_kind_of(Float, degrees)
  end

  def test_radians_invalid_parameters
    start_with_empty_model
    radians = 1.5707963267949
    assert_raises(ArgumentError) do
      radians.radians(nil)
    end
  end

  def test_to_cm
    start_with_empty_model
    inches = 1
    cm = inches.to_cm
    assert_equal(2.54, cm)
    assert_kind_of(Float, cm)
  end

  def test_to_cm_invalid_parameters
    start_with_empty_model
    inches = 1
    assert_raises(ArgumentError) do
      inches.to_cm(nil)
    end
  end

  def test_to_feet
    start_with_empty_model
    inches = 24
    feet = inches.to_feet
    assert_equal(2, feet)
    assert_kind_of(Float, feet)
  end

  def test_to_feet_invalid_parameters
    start_with_empty_model
    inches = 24
    assert_raises(ArgumentError) do
      inches.to_feet(nil)
    end
  end

  def test_to_inch
    start_with_empty_model
    value = 19
    inches = value.to_inch
    assert_equal(19, inches)
    assert_kind_of(Float, inches)
  end

  def test_to_inch_invalid_parameters
    start_with_empty_model
    value = 19
    assert_raises(ArgumentError) do
      value.to_inch(nil)
    end
  end

  def test_to_l
    start_with_empty_model
    num = 12
    length = num.to_l
    assert_equal(12, length)
    assert_kind_of(Length, length)
  end

  def test_to_l_invalid_parameters
    start_with_empty_model
    num = 12
    assert_raises(ArgumentError) do
      num.to_l(nil)
    end
  end

  def test_to_m
    start_with_empty_model
    inches = 12
    meters = inches.to_cm
    assert_equal(30.48, meters)
    assert_kind_of(Float, meters)
  end

  def test_to_m_invalid_parameters
    start_with_empty_model
    inches = 12
    assert_raises(ArgumentError) do
      inches.to_cm(nil)
    end
  end

  def test_to_mile
    start_with_empty_model
    inches = 10000
    miles = inches.to_mile
    assert_equal(0.15782828282828282, miles)
    assert_kind_of(Float, miles)
  end

  def test_to_mile_invalid_parameters
    start_with_empty_model
    inches = 10000
    assert_raises(ArgumentError) do
      inches.to_mile(nil)
    end
  end

  def test_to_mm
    start_with_empty_model
    inches = 1
    mm = inches.to_mm
    assert_equal(25.4, mm)
    assert_kind_of(Float, mm)
  end

  def test_to_mm_invalid_parameters
    start_with_empty_model
    inches = 1
    assert_raises(ArgumentError) do
      inches.to_mm(nil)
    end
  end

  def test_to_yard
    start_with_empty_model
    inches = 10000
    yards = inches.to_yard
    assert_equal(277.77777777777777, yards)
    assert_kind_of(Float, yards)
  end

  def test_to_yard_invalid_parameters
    start_with_empty_model
    inches = 10000
    assert_raises(ArgumentError) do
      inches.to_yard(nil)
    end
  end

  def test_yard
    start_with_empty_model
    yards = 1.to_l
    inches = yards.yard
    assert_equal(36, inches)
    assert_kind_of(Length, inches)
  end

  def test_yard_invalid_parameters
    start_with_empty_model
    yards = 1.to_l
    assert_raises(ArgumentError) do
      yards.yard(nil)
    end
  end

  def test_to_km
    start_with_empty_model
    inches = 99
    km = inches.to_km
    assert_equal(0.0025146, km)
    assert_kind_of(Float, km)
  end

  def test_to_km_invalid_parameters
    start_with_empty_model
    inches = 1
    assert_raises(ArgumentError) do
      inches.to_km(nil)
    end
  end
end

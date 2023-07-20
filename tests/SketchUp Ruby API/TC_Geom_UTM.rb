# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi


require "testup/testcase"


# module Geom::UTM
class TC_Geom_UTM < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    # ...
  end

  def teardown
    # ...
  end

  def test_initialize_example
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal([13, "T", 475849.37521, 4429682.73749], utm.to_a) 
  end

  def test_initialize_utm
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    utm2 = Geom::UTM.new(utm)
    assert_kind_of(Geom::UTM, utm2)
    assert_equal(utm.to_a, utm2.to_a)
  end

  def test_intitialize_negative_values
    # this isn't a valid a UTM mapping, however we do not throw any errors
    utm = Geom::UTM.new(-13, "T", -475849.37521, -4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(-13 T -475849.37521 -4429682.73749)", utm.to_s)
  end

  def test_initialize
    utm = Geom::UTM.new
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(0 A 0.00000 0.00000)", utm.to_s)
  end

  def test_initialize_array
    utm = Geom::UTM.new([13, "T", 475849.37521, 4429682.73749])
    assert_kind_of(Geom::UTM, utm)
    assert_equal([13, "T", 475849.37521, 4429682.73749], utm.to_a)
  end

  def test_initialize_too_few_arguments
    assert_raises(ArgumentError) do 
      Geom::UTM.new(13, "T", 475849.37521)
    end

    assert_raises(ArgumentError) do
      Geom::UTM.new(13, "T")
    end

    assert_raises(TypeError) do
      Geom::UTM.new(13)
    end
  end

  def test_initialize_too_many_arguments
    assert_raises(ArgumentError) do 
      Geom::UTM.new(13, "T", 475849.37521, 4429682.73749, 123)
    end
  end

  def test_initialize_invalid_arguments
    assert_raises(TypeError) do 
      Geom::UTM.new(13, 1, 475849.37521, 4429682.73749)
    end

    assert_raises(TypeError) do
      Geom::UTM.new(13, "T", "475849.37521", 4429682.73749)
    end

    assert_raises(TypeError) do 
      Geom::UTM.new(13, "T", 475849.37521, "4429682.73749")
    end

    assert_raises(TypeError) do 
      Geom::UTM.new("13", "T", 475849.37521, 4429682.73749)
    end

    assert_raises(TypeError) do 
      Geom::UTM.new(nil)
    end
  end

  def test_initialize_out_of_range_zone_number
    # The valid zones are: 1-60. Other zones do not exist.
    utm = Geom::UTM.new(61, "T", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(61 T 475849.37521 4429682.73749)", utm.to_s)

    utm = Geom::UTM.new(0, "T", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(0 T 475849.37521 4429682.73749)", utm.to_s)

    utm = Geom::UTM.new(-1, "T", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(-1 T 475849.37521 4429682.73749)", utm.to_s)
  end

  def test_initalize_out_of_range_zone_letter
    # Zone letters are through C-X. Ommiting I and O.
    # sketchup sees the below Zone Letters as valid.
    utm = Geom::UTM.new(13, "A", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 A 475849.37521 4429682.73749)", utm.to_s)
    
    utm = Geom::UTM.new(13, "B", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 B 475849.37521 4429682.73749)", utm.to_s)

    utm = Geom::UTM.new(13, "Y", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 Y 475849.37521 4429682.73749)", utm.to_s)

    utm = Geom::UTM.new(13, "Z", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 Z 475849.37521 4429682.73749)", utm.to_s)

    utm = Geom::UTM.new(13, "I", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 I 475849.37521 4429682.73749)", utm.to_s)

    utm = Geom::UTM.new(13, "O", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 O 475849.37521 4429682.73749)", utm.to_s)
  end

  def test_initialize_out_of_range_x
    # Negative x coord is invalid.
    utm = Geom::UTM.new(13, "T", -475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 T -475849.37521 4429682.73749)", utm.to_s)
  end

  def test_initialize_out_of_range_y 
    # Negative y coord is invalid.
    utm = Geom::UTM.new(13, "T", 475849.37521, -4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    assert_equal("UTM(13 T 475849.37521 -4429682.73749)", utm.to_s)
  end  

  def test_initialize_valid_zone_number
    # these tests are meant to keep existing behavior even though
    # the numbers provided are not according to UTM specs
    utm = Geom::UTM.new(0, "T", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)

    utm2 = Geom::UTM.new(61, "T", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm2)
  end

  def test_initialize_valid_zone_letters
    # these tests are meant to keep existing behavior even though
    # the zone letters provided are not according to UTM specs
    utm = Geom::UTM.new(13, "I", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    utm = Geom::UTM.new(13, "A", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    utm = Geom::UTM.new(13, "B", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    utm = Geom::UTM.new(13, "Y", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    utm = Geom::UTM.new(13, "Z", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    utm = Geom::UTM.new(13, "I", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
    utm = Geom::UTM.new(13, "O", 475849.37521, 4429682.73749)
    assert_kind_of(Geom::UTM, utm)
  end

  def test_to_a
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    utm_array = utm.to_a
    assert_kind_of(Array, utm_array)
    assert_equal([13, "T", 475849.37521, 4429682.73749], utm_array)
  end

  def test_to_a_too_many_arguments
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    assert_raises(ArgumentError) do 
      utm.to_a(nil)
    end
  end

  def test_to_latlong
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    utm_latlong = utm.to_latlong
    assert_kind_of(Geom::LatLong, utm_latlong)
    assert_equal([40.01700297974308, -105.2829977182344], utm_latlong.to_a)
  end

  def test_to_latlong_invalid_arguments
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    assert_raises(ArgumentError) do
      utm.to_latlong(nil)
    end
  end

  def test_to_s
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    utm_string = utm.to_s
    assert_kind_of(String, utm_string)
    assert_equal("UTM(13 T 475849.37521 4429682.73749)", utm_string)
  end

  def test_to_s_too_many_arguments
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    assert_raises(ArgumentError) do
      utm.to_s(nil)
    end
  end

  def test_x
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    x = utm.x
    assert_kind_of(Float, x)
    assert_equal(475849.37521, x)
  end

  def test_x_too_many_arguments
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    assert_raises(ArgumentError) do
      utm.x(nil)
    end
  end

  def test_y
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    y = utm.y
    assert_kind_of(Float, y)
    assert_equal(4429682.73749, y)
  end

  def test_y_invalid_arguments
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    assert_raises(ArgumentError) do
      utm.y(nil)
    end
  end

  def test_zone_letter
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    letter = utm.zone_letter
    assert_kind_of(String, letter)
    assert_equal("T", letter)
  end

  def test_zone_letter_too_many_arguments
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    assert_raises(ArgumentError) do
      utm.zone_letter(nil)
    end
  end

  def test_zone_number
    utm = Geom::UTM.new(13, "T", 475849.37521, 4429682.73749)
    num = utm.zone_number
    assert_kind_of(Integer, num)
    assert_equal(13, num)
  end
end # class

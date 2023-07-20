# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi


require "testup/testcase"


# module Geom::LatLong
class TC_Geom_LatLong < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    # ...
  end

  def teardown
    # ...
  end

  def test_initialize
    latlong = Geom::LatLong.new
    assert_kind_of(Geom::LatLong, latlong)
  end

  def test_initialize_array
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    assert_kind_of(Geom::LatLong, latlong)
  end

  def test_initialize_float
    latlong = Geom::LatLong.new(40.0, 105.0)
    assert_kind_of(Geom::LatLong, latlong)
  end

  def test_initialize_latlong
    latlong = Geom::LatLong.new(40.0, 105.0)
    assert_kind_of(Geom::LatLong, latlong)

    from_latlong = Geom::LatLong.new(latlong)
    assert_kind_of(Geom::LatLong, from_latlong)
  end

  def test_initialize_invalid_arguments    
    assert_raises(ArgumentError) do 
      Geom::LatLong.new(nil)
    end

    assert_raises(ArgumentError) do
      Geom::LatLong.new("SketchUp")
    end

    assert_raises(ArgumentError) do
      Geom::LatLong.new([0])
    end 

    assert_raises(ArgumentError) do
      Geom::LatLong.new([0, 1, 2])
    end

    assert_raises(ArgumentError) do
      Geom::LatLong.new(1)
    end

    assert_raises(TypeError) do
      Geom::LatLong.new([1, 2], [1, 2])
    end
  end

  def test_initialize_too_many_arguments
    assert_raises(ArgumentError) do
      Geom::LatLong.new(1, 2, 3)
    end
  end

  class Chocolate < Geom::LatLong; end
  def test_subclass
    snickers = Chocolate.new
    assert_kind_of(Geom::LatLong, snickers)
  end

  def test_latitude_floats
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    latitude = latlong.latitude
    assert_equal(ll[0], latitude)
    assert_kind_of(Float, latitude)
  end

  def test_latitude_integers
    latlong = Geom::LatLong.new(123, 1.23)
    latitude = latlong.latitude
    assert_equal(123, latitude)
    assert_kind_of(Float, latitude)
  end

  def test_latitude_too_many_arguments
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    assert_raises(ArgumentError) do
      latlong.latitude(nil)
    end
  end

  def test_longitude_floats
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    longitude = latlong.longitude
    assert_equal(ll[1], longitude)
    assert_kind_of(Float, longitude)
  end

  def test_longitude_integers
    latlong = Geom::LatLong.new(123, 1.23)
    longitude = latlong.longitude
    assert_equal(1.23, longitude)
    assert_kind_of(Float, longitude)
  end

  def test_longitude_too_many_arguments
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    assert_raises(ArgumentError) do
      latlong.longitude(nil)
    end
  end

  def test_to_a
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    latlong_array = latlong.to_a
    assert_kind_of(Array, latlong_array)
    assert_equal(ll[0], latlong_array[0])
    assert_equal(ll[1], latlong_array[1])
    assert_kind_of(Float, ll[0])
    assert_kind_of(Float, ll[1])
  end

  def test_to_a_too_many_arguments
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    assert_raises(ArgumentError) do
      latlong.to_a(nil)
    end
  end

  def test_to_s
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    latlong_string = latlong.to_s
    assert_kind_of(String, latlong_string)
    assert_equal("LatLong(40.01700N, 105.28300E)", latlong_string)
  end

  def test_to_s_too_many_arguments
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    assert_raises(ArgumentError) do 
      latlong.to_s(nil)
    end
  end

  def test_to_utm
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    latlong_utm = latlong.to_utm
    assert_kind_of(Geom::UTM, latlong_utm)
    utm = Geom::UTM.new(48, "T", 524150.8205633243, 4429682.4074293105)
    assert_equal(utm.to_a, latlong_utm.to_a)
  end

  def test_to_utm_too_many_arguments
    ll = [40.01700, 105.28300]
    latlong = Geom::LatLong.new(ll)
    assert_raises(ArgumentError) do 
      latlong.to_utm(nil)
    end
  end
end # class

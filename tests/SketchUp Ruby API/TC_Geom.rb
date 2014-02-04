# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# module Geom
# http://www.sketchup.com/intl/developer/docs/ourdoc/geom
class TC_Geom < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # module Geom
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom

  def test_introduction_api_example_1
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    line = [Geom::Point3d.new(0, 0, 0), Geom::Point3d.new(0, 0, 100)]
  end

  def test_introduction_api_example_2
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    plane = [0, 0, 1, 0]
  end


  # ========================================================================== #
  # method Geom.closest_points
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#closest_points

  def test_closest_points_api_example
    line1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    line2 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 100)]
    # 0,0,0 on each line should be closest because both lines start from
    # that point.
    points = Geom.closest_points(line1, line2)
  end

  def test_closest_points_lines_intersecting
    line1 = [Geom::Point3d.new(0, 1, 0), Geom::Vector3d.new(2, 1, 0)]
    line2 = [Geom::Point3d.new(1, 0, 0), Geom::Vector3d.new(1, 2, 0)]
    expected = Geom::Point3d.new(2, 2, 0)

    result = Geom.closest_points(line1, line2)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(expected, result[0], "Line 1")
    assert_equal(expected, result[1], "Line 2")
  end

  def test_closest_points_lines_not_intersecting
    line1 = [Geom::Point3d.new(0, 1, 0), Geom::Vector3d.new(2, 1, 3)]
    line2 = [Geom::Point3d.new(1, 0, 0), Geom::Vector3d.new(1, 2, 3)]
    expected1 = Geom::Point3d.new(2, 2, 3)
    expected2 = Geom::Point3d.new(2, 2, 3)

    result = Geom.closest_points(line1, line2)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(expected1, result[0], "Line 1")
    assert_equal(expected2, result[1], "Line 2")
  end

  def test_closest_points_lines_parallell
    line1 = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]
    line2 = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 5)]
    expected1 = Geom::Point3d.new(1, 2, 3)
    expected2 = Geom::Point3d.new(1, 2, 3)

    result = Geom.closest_points(line1, line2)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(expected1, result[0], "Line 1")
    assert_equal(expected2, result[1], "Line 2")
  end

  def test_closest_points_invalid_line_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]
    line_with_nil = [Geom::Point3d.new(1, 2, 3), nil]
    line_with_string = [Geom::Point3d.new(1, 2, 3), "Hello!"]
    line_with_number = [Geom::Point3d.new(1, 2, 3), 123]

    assert_raises(ArgumentError, "Array with nil") do
      result = Geom.closest_points(valid_line, line_with_nil)
    end

    assert_raises(ArgumentError, "Array with string") do
      result = Geom.closest_points(valid_line, line_with_string)
    end

    assert_raises(ArgumentError, "Array with number") do
      result = Geom.closest_points(valid_line, line_with_number)
    end
  end

  def test_closest_points_invalid_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(TypeError, "Argument with nil") do
      result = Geom.closest_points(valid_line, nil)
    end

    assert_raises(TypeError, "Argument with string") do
      result = Geom.closest_points(valid_line, "Cheese!")
    end

    assert_raises(TypeError, "Argument with number") do
      result = Geom.closest_points(valid_line, 123)
    end
  end

  def test_closest_points_incorrect_number_of_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(ArgumentError, "No arguments") do
      result = Geom.closest_points(valid_line)
    end

    assert_raises(ArgumentError, "One argument") do
      result = Geom.closest_points(valid_line)
    end

    assert_raises(ArgumentError, "Three arguments") do
      result = Geom.closest_points(valid_line, valid_line, valid_line)
    end
  end


end # class

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


  def get_2d_polygon
    [
      Geom::Point3d.new(2, 2, 0),
      Geom::Point3d.new(10, 2, 0),
      Geom::Point3d.new(5, 5, 0),
      Geom::Point3d.new(10, 10, 0),
      Geom::Point3d.new(2, 10, 0)
    ]
  end


  # ========================================================================== #
  # module Geom
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom

  def test_introduction_api_example_1
    line1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    line2 = [Geom::Point3d.new(0, 0, 0), Geom::Point3d.new(0, 0, 100)]
  end

  def test_introduction_api_example_2
    plane1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    plane2 = [0, 0, 1, 0]
  end


  # ========================================================================== #
  # method Geom.closest_points
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#closest_points

  def test_closest_points_api_example
    line1 = [Geom::Point3d.new(0, 2, 0), Geom::Vector3d.new(1, 0, 0)]
    line2 = [Geom::Point3d.new(3, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    # This will return a point Point3d(3, 2, 0).
    points = Geom.closest_points(line1, line2)
  end

  def test_closest_points_lines_intersecting
    line1 = [Geom::Point3d.new(0, 2, 0), Geom::Vector3d.new(1, 0, 0)]
    line2 = [Geom::Point3d.new(3, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    expected = Geom::Point3d.new(3, 2, 0)

    result = Geom.closest_points(line1, line2)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(expected, result[0], "Line 1")
    assert_equal(expected, result[1], "Line 2")
  end

  def test_closest_points_lines_not_intersecting
    line1 = [Geom::Point3d.new(0, 2, 0), Geom::Vector3d.new(1, 0, 0)]
    line2 = [Geom::Point3d.new(3, 0, 5), Geom::Vector3d.new(0, 1, 0)]
    expected1 = Geom::Point3d.new(3, 2, 0)
    expected2 = Geom::Point3d.new(3, 2, 5)

    result = Geom.closest_points(line1, line2)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(expected1, result[0], "Line 1")
    assert_equal(expected2, result[1], "Line 2")
  end

  def test_closest_points_lines_parallell
    line1 = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 0, 0)]
    line2 = [Geom::Point3d.new(2, 2, 3), Geom::Vector3d.new(1, 0, 0)]
    expected1 = Geom::Point3d.new(1, 2, 3)
    expected2 = Geom::Point3d.new(1, 2, 3)

    result = Geom.closest_points(line1, line2)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(expected1, result[0], "Line 1")
    assert_equal(expected2, result[1], "Line 2")
  end

  def test_closest_points_lines_colinear
    line1 = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 0, 0)]
    line2 = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 0, 0)]
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
      Geom.closest_points(valid_line, line_with_nil)
    end

    assert_raises(ArgumentError, "Array with string") do
      Geom.closest_points(valid_line, line_with_string)
    end

    assert_raises(ArgumentError, "Array with number") do
      Geom.closest_points(valid_line, line_with_number)
    end
  end

  def test_closest_points_invalid_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(TypeError, "Argument with nil") do
      Geom.closest_points(valid_line, nil)
    end

    assert_raises(TypeError, "Argument with string") do
      Geom.closest_points(valid_line, "Cheese!")
    end

    assert_raises(TypeError, "Argument with number") do
      Geom.closest_points(valid_line, 123)
    end
  end

  def test_closest_points_incorrect_number_of_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(ArgumentError, "No arguments") do
      Geom.closest_points()
    end

    assert_raises(ArgumentError, "One argument") do
      Geom.closest_points(valid_line)
    end

    assert_raises(ArgumentError, "Three arguments") do
      Geom.closest_points(valid_line, valid_line, valid_line)
    end
  end


  # ========================================================================== #
  # method Geom.fit_plane_to_points
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#fit_plane_to_points

  def test_fit_plane_to_points_api_example
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(10, 10, 10)
    point3 = Geom::Point3d.new(25, 25, 25)
    plane = Geom.fit_plane_to_points(point1, point2, point3)
  end

  def test_fit_plane_to_points_point_cloud
    point1 = Geom::Point3d.new(20, 10, 30)
    point2 = Geom::Point3d.new(60, 30, 20)
    point3 = Geom::Point3d.new(40, 60, 30)
    point4 = Geom::Point3d.new(35, 35, 60)
    point5 = Geom::Point3d.new(15, 20, 10)

    result = Geom.fit_plane_to_points(point1, point2, point3, point4, point5)
    a, b, c, d = result
    assert_in_delta( 0.9072822708402576,   a, SKETCHUP_FLOAT_TOLERANCE, 'A')
    assert_in_delta(-0.4204478816088999,   b, SKETCHUP_FLOAT_TOLERANCE, 'B')
    assert_in_delta( 0.007903155669340222, c, SKETCHUP_FLOAT_TOLERANCE, 'C')
    assert_in_delta(-18.05080754877307,    d, SKETCHUP_FLOAT_TOLERANCE, 'D')
  end

  def test_fit_plane_to_points_three_points
    # XY Plane
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(60, 30, 0)
    point3 = Geom::Point3d.new(25, 60, 0)

    result = Geom.fit_plane_to_points(point1, point2, point3)
    assert_equal([0.0, 0.0, 1.0, 0.0], result)

    result = Geom.fit_plane_to_points(point1, point3, point2)
    assert_equal([0.0, 0.0, -1.0, 0.0], result)

    # YX Plane
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(0, 60, 30)
    point3 = Geom::Point3d.new(0, 25, 60)

    result = Geom.fit_plane_to_points(point1, point2, point3)
    assert_equal([1.0, 0.0, 0.0, 0.0], result)

    result = Geom.fit_plane_to_points(point1, point3, point2)
    assert_equal([-1.0, 0.0, 0.0, 0.0], result)

    # XZ Plane
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(25, 0, 60)
    point3 = Geom::Point3d.new(60, 0, 30)

    result = Geom.fit_plane_to_points(point1, point2, point3)
    assert_equal([0.0, 1.0, 0.0, 0.0], result)

    result = Geom.fit_plane_to_points(point1, point3, point2)
    assert_equal([0.0, -1.0, 0.0, 0.0], result)
  end

  def test_fit_plane_to_points_identical_points
    point1 = Geom::Point3d.new(10, 0, 0)
    point2 = Geom::Point3d.new(10, 0, 0)
    point3 = Geom::Point3d.new(10, 0, 0)

    # SketchUp doesn't raise any errors, just return a default plane.
    result = Geom.fit_plane_to_points(point1, point2, point3)
    assert_equal([0.0, 0.0, 1.0, 0.0], result)
  end

  def test_fit_plane_to_points_colinear_points
    point1 = Geom::Point3d.new(10, 0, 0)
    point2 = Geom::Point3d.new(25, 0, 0)
    point3 = Geom::Point3d.new(60, 0, 0)

    # SketchUp doesn't raise any errors, just return a default plane.
    result = Geom.fit_plane_to_points(point1, point2, point3)
    assert_equal([0.0, 0.0, 1.0, 0.0], result)
  end

  def test_fit_plane_to_points_invalid_arguments
    assert_raises(ArgumentError, "Arguments with nil") do
      Geom.fit_plane_to_points(nil, nil, nil)
    end

    assert_raises(ArgumentError, "Arguments with string") do
      Geom.fit_plane_to_points("Lorem", "Ipsum", "Dolor")
    end

    assert_raises(ArgumentError, "Arguments with number") do
      Geom.fit_plane_to_points(123, 456, 789)
    end
  end

  def test_fit_plane_to_points_invalid_arguments_in_array
    assert_raises(ArgumentError, "Arguments with nil") do
      Geom.fit_plane_to_points([nil, nil, nil])
    end

    assert_raises(ArgumentError, "Arguments with string") do
      Geom.fit_plane_to_points(["Lorem", "Ipsum", "Dolor"])
    end

    assert_raises(ArgumentError, "Arguments with number") do
      Geom.fit_plane_to_points([123, 456, 789])
    end
  end

  def test_fit_plane_to_points_incorrect_number_of_arguments
    point1 = Geom::Point3d.new(10, 10, 10)
    point2 = Geom::Point3d.new(25, 25, 25)

    assert_raises(ArgumentError, "No arguments") do
      Geom.fit_plane_to_points()
    end

    assert_raises(ArgumentError, "Two arguments") do
      Geom.fit_plane_to_points(point1, point2)
    end
  end

  def test_fit_plane_to_points_incorrect_number_of_arguments_in_array
    point1 = Geom::Point3d.new(10, 10, 10)
    point2 = Geom::Point3d.new(25, 25, 25)

    assert_raises(ArgumentError, "No arguments") do
      Geom.fit_plane_to_points([])
    end

    assert_raises(TypeError, "One argument") do
      Geom.fit_plane_to_points([point1])
    end

    assert_raises(ArgumentError, "Two arguments") do
      Geom.fit_plane_to_points([point1, point2])
    end
  end


  # ========================================================================== #
  # method Geom.intersect_line_line
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#intersect_line_line

  def test_intersect_line_line_api_example
    # Defines a line parallell to the Y axis, offset 20 units.
    line1 = [Geom::Point3d.new(20, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    # Defines a line parallell to the X axis, offset 10 units.
    line2 = [Geom::Point3d.new(0, 10, 0), Geom::Point3d.new(20, 10, 0)]
    # This will return a point Point3d(20, 10, 0).
    point = Geom.intersect_line_line(line1, line2)
  end

  def test_intersect_line_line
    line1 = [Geom::Point3d.new(20, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    line2 = [Geom::Point3d.new(0, 10, 0), Geom::Point3d.new(20, 10, 0)]

    result = Geom.intersect_line_line(line1, line2)
    expect = Geom::Point3d.new(20, 10, 0)
    assert_equal(expect, result)
  end

  def test_intersect_line_line_not_intersecting
    line1 = [Geom::Point3d.new(10, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    line2 = [Geom::Point3d.new(0, 10, 5), Geom::Point3d.new(20, 10, 5)]

    result = Geom.intersect_line_line(line1, line2)
    assert_nil(result)
  end

  def test_intersect_line_line_colinear
    line1 = [Geom::Point3d.new(10, 0, 0), Geom::Vector3d.new(1, 0, 0)]
    line2 = [Geom::Point3d.new(20, 0, 0), Geom::Point3d.new(10, 0, 0)]

    result = Geom.intersect_line_line(line1, line2)
    assert_nil(result)
  end

  def test_intersect_line_line_invalid_line_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]
    line_with_nil = [Geom::Point3d.new(1, 2, 3), nil]
    line_with_string = [Geom::Point3d.new(1, 2, 3), "Hello!"]
    line_with_number = [Geom::Point3d.new(1, 2, 3), 123]

    assert_raises(ArgumentError, "Array with nil") do
      Geom.intersect_line_line(valid_line, line_with_nil)
    end

    assert_raises(ArgumentError, "Array with string") do
      Geom.intersect_line_line(valid_line, line_with_string)
    end

    assert_raises(ArgumentError, "Array with number") do
      Geom.intersect_line_line(valid_line, line_with_number)
    end
  end

  def test_intersect_line_line_invalid_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(TypeError, "Argument with nil") do
      Geom.intersect_line_line(valid_line, nil)
    end

    assert_raises(TypeError, "Argument with string") do
      Geom.intersect_line_line(valid_line, "Cheese!")
    end

    assert_raises(TypeError, "Argument with number") do
      Geom.intersect_line_line(valid_line, 123)
    end
  end

  def test_intersect_line_line_incorrect_number_of_arguments
    valid_line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(ArgumentError, "No arguments") do
      Geom.intersect_line_line()
    end

    assert_raises(ArgumentError, "One argument") do
      Geom.intersect_line_line(valid_line)
    end

    assert_raises(ArgumentError, "Three arguments") do
      Geom.intersect_line_line(valid_line, valid_line, valid_line)
    end
  end


  # ========================================================================== #
  # method Geom.intersect_line_plane
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#intersect_line_plane

  def test_intersect_line_plane_api_example
    # Defines a line parallell to the X axis, offset 20 units.
    line = [Geom::Point3d.new(-10, 20, 0), Geom::Vector3d.new(1, 0, 0)]
    # Defines a plane with it's normal parallel to the x axis.
    plane = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]
    # This will return a point Point3d(10, 20, 0).
    point = Geom.intersect_line_plane(line, plane)
  end

  def test_intersect_line_plane
    line = [Geom::Point3d.new(-10, 20, 0), Geom::Vector3d.new(1, 0, 0)]
    plane = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]

    result = Geom.intersect_line_plane(line, plane)
    expect = Geom::Point3d.new(10, 20, 0)
    assert_equal(expect, result)
  end

  def test_intersect_line_plane_not_intersecting
    line = [Geom::Point3d.new(-10, 20, 0), Geom::Vector3d.new(0, 1, 0)]
    plane = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]

    result = Geom.intersect_line_plane(line, plane)
    assert_nil(result)
  end

  def test_intersect_line_plane_line_on_plane
    line = [Geom::Point3d.new(10, 20, 0), Geom::Vector3d.new(0, 1, 0)]
    plane = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]

    result = Geom.intersect_line_plane(line, plane)
    assert_nil(result)
  end

  def test_intersect_line_plane_invalid_line_arguments
    line_with_nil = [Geom::Point3d.new(1, 2, 3), nil]
    line_with_string = [Geom::Point3d.new(1, 2, 3), "Hello!"]
    line_with_number = [Geom::Point3d.new(1, 2, 3), 123]
    plane = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]

    assert_raises(ArgumentError, "Array with nil") do
      Geom.intersect_line_plane(line_with_nil, plane)
    end

    assert_raises(ArgumentError, "Array with string") do
      Geom.intersect_line_plane(line_with_string, plane)
    end

    assert_raises(ArgumentError, "Array with number") do
      Geom.intersect_line_plane(line_with_number, plane)
    end
  end

  def test_intersect_line_plane_invalid_plane_arguments
    line = [Geom::Point3d.new(-10, 20, 0), Geom::Vector3d.new(1, 0, 0)]
    plane_with_nil = [Geom::Point3d.new(1, 2, 3), nil]
    plane_with_string = [Geom::Point3d.new(1, 2, 3), "Hello!"]
    plane_with_number = [Geom::Point3d.new(1, 2, 3), 123]

    assert_raises(ArgumentError, "Array with nil") do
      Geom.intersect_line_plane(line, plane_with_nil)
    end

    assert_raises(ArgumentError, "Array with string") do
      Geom.intersect_line_plane(line, plane_with_string)
    end

    assert_raises(ArgumentError, "Array with number") do
      Geom.intersect_line_plane(line, plane_with_number)
    end
  end

  def test_intersect_line_plane_invalid_arguments
    line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]
    plane = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]

    assert_raises(TypeError, "Plane argument with nil") do
      Geom.intersect_line_plane(line, nil)
    end

    assert_raises(TypeError, "Line argument with nil") do
      Geom.intersect_line_plane(nil, plane)
    end

    assert_raises(TypeError, "Plane argument with string") do
      Geom.intersect_line_plane(line, "Cheese!")
    end

    assert_raises(TypeError, "Line argument with string") do
      Geom.intersect_line_plane("Cheese!", plane)
    end

    assert_raises(TypeError, "Plane argument with number") do
      Geom.intersect_line_plane(line, 123)
    end

    assert_raises(TypeError, "Line argument with number") do
      Geom.intersect_line_plane(123, plane)
    end
  end

  def test_intersect_line_plane_incorrect_number_of_arguments
    line = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]
    plane = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]

    assert_raises(ArgumentError, "No arguments") do
      Geom.intersect_line_plane()
    end

    assert_raises(ArgumentError, "One argument") do
      Geom.intersect_line_plane(line)
    end

    assert_raises(ArgumentError, "Three arguments") do
      Geom.intersect_line_plane(line, plane, line)
    end
  end


  # ========================================================================== #
  # method Geom.intersect_plane_plane
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#intersect_plane_plane

  def test_intersect_plane_plane_api_example
    # Defines a plane with it's normal parallel to the x axis.
    plane1 = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]
    # Defines a plane with it's normal parallel to the y axis.
    plane2 = [Geom::Point3d.new(0, 20 ,0), Geom::Vector3d.new(0, 1, 0)]
    # This will return a line [Point3d(10, 20, 0), Vector3d(0, 0, 1)].
    line = Geom.intersect_plane_plane(plane1, plane2)
  end

  def test_intersect_plane_plane
    plane1 = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]
    plane2 = [Geom::Point3d.new(0, 20 ,0), Geom::Vector3d.new(0, 1, 0)]

    result = Geom.intersect_plane_plane(plane1, plane2)
    expect = [Geom::Point3d.new(10, 20, 0), Geom::Vector3d.new(0, 0, 1)]
    assert_equal(expect, result)
  end

  def test_intersect_plane_plane_not_intersecting
    plane1 = [Geom::Point3d.new(10, 0 ,0), Geom::Vector3d.new(1, 0, 0)]
    plane2 = [Geom::Point3d.new(20, 0 ,0), Geom::Vector3d.new(1, 0, 0)]

    result = Geom.intersect_plane_plane(plane1, plane2)
    assert_nil(result)
  end

  def test_intersect_plane_plane_coplanar
    plane1 = [Geom::Point3d.new(10, 10, 0), Geom::Vector3d.new(1, 0, 0)]
    plane2 = [Geom::Point3d.new(10, 20, 0), Geom::Vector3d.new(1, 0, 0)]

    result = Geom.intersect_plane_plane(plane1, plane2)
    assert_nil(result)
  end

  def test_intersect_plane_plane_invalid_plane_arguments
    valid_plane = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]
    plane_with_nil = [Geom::Point3d.new(1, 2, 3), nil]
    plane_with_string = [Geom::Point3d.new(1, 2, 3), "Hello!"]
    plane_with_number = [Geom::Point3d.new(1, 2, 3), 123]

    assert_raises(ArgumentError, "Array with nil") do
      Geom.intersect_plane_plane(valid_plane, plane_with_nil)
    end

    assert_raises(ArgumentError, "Array with string") do
      Geom.intersect_plane_plane(valid_plane, plane_with_string)
    end

    assert_raises(ArgumentError, "Array with number") do
      Geom.intersect_plane_plane(valid_plane, plane_with_number)
    end
  end

  def test_intersect_plane_plane_invalid_arguments
    plane = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(TypeError, "Argument with nil") do
      Geom.intersect_plane_plane(plane, nil)
    end

    assert_raises(TypeError, "Argument with string") do
      Geom.intersect_plane_plane(plane, "Cheese!")
    end

    assert_raises(TypeError, "Argument with number") do
      Geom.intersect_plane_plane(plane, 123)
    end
  end

  def test_intersect_plane_plane_incorrect_number_of_arguments
    plane = [Geom::Point3d.new(1, 2, 3), Geom::Vector3d.new(1, 2, 4)]

    assert_raises(ArgumentError, "No arguments") do
      Geom.intersect_plane_plane()
    end

    assert_raises(ArgumentError, "One argument") do
      Geom.intersect_plane_plane(plane)
    end

    assert_raises(ArgumentError, "Three arguments") do
      Geom.intersect_plane_plane(plane, plane, plane)
    end
  end


  # ========================================================================== #
  # method Geom.linear_combination
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#linear_combination

  def test_linear_combination_api_example
    point1 = Geom::Point3d.new(1, 1, 1)
    point2 = Geom::Point3d.new(10, 10, 10)
    # Gets the point on the line segment connecting point1 and point2 that is
    # 3/4 the way from point1 to point2: Point3d(7.75, 7.75, 7.75).
    point = Geom.linear_combination(0.25, point1, 0.75, point2)
  end

  def test_linear_combination_with_points
    point1 = Geom::Point3d.new(1, 1, 1)
    point2 = Geom::Point3d.new(10, 10, 10)

    result = Geom.linear_combination(0.25, point1, 0.75, point2)
    expect = Geom::Point3d.new(7.75, 7.75, 7.75)
  end

  def test_linear_combination_with_vectors
    vector1 = Geom::Vector3d.new(1, 1, 1)
    vector2 = Geom::Vector3d.new(10, 10, 10)

    result = Geom.linear_combination(0.25, vector1, 0.75, vector2)
    expect = Geom::Vector3d.new(7.75, 7.75, 7.75)
  end

  def test_linear_combination_with_integer_weights
    point1 = Geom::Point3d.new(2, 0, 0)
    point2 = Geom::Point3d.new(0, 6, 0)

    result = Geom.linear_combination(4, point1, 10, point2)
    expect = Geom::Point3d.new(8, 60, 0)
  end

  def test_linear_combination_incorrect_mix_of_points_and_vectors
    point = Geom::Point3d.new(1, 1, 1)
    vector = Geom::Vector3d.new(10, 10, 10)

    assert_raises(ArgumentError) do
      Geom.linear_combination(0.25, point, 0.75, vector)
    end

    assert_raises(ArgumentError) do
      Geom.linear_combination(0.25, vector, 0.75, point)
    end
  end

  def test_linear_combination_invalid_nil_arguments
    point1 = Geom::Point3d.new(1, 1, 1)
    point2 = Geom::Point3d.new(10, 10, 10)

    assert_raises(ArgumentError, "1. argument with nil") do
      Geom.intersect_plane_plane(nil, point1, 0.5, point2)
    end

    assert_raises(ArgumentError, "2. argument with nil") do
      Geom.intersect_plane_plane(0.5, nil, 0.5, point2)
    end

    assert_raises(ArgumentError, "3. argument with nil") do
      Geom.intersect_plane_plane(0.5, point1, nil, point2)
    end

    assert_raises(ArgumentError, "4. argument with nil") do
      Geom.intersect_plane_plane(0.5, point1, 0.5, nil)
    end
  end

  def test_linear_combination_invalid_string_arguments
    point1 = Geom::Point3d.new(1, 1, 1)
    point2 = Geom::Point3d.new(10, 10, 10)

    assert_raises(ArgumentError, "1. argument with string") do
      Geom.intersect_plane_plane("Cheese!", point1, 0.5, point2)
    end

    assert_raises(ArgumentError, "2. argument with string") do
      Geom.intersect_plane_plane(0.5, "Cheese!", 0.5, point2)
    end

    assert_raises(ArgumentError, "3. argument with string") do
      Geom.intersect_plane_plane(0.5, point1, "Cheese!", point2)
    end

    assert_raises(ArgumentError, "4. argument with string") do
      Geom.intersect_plane_plane(0.5, point1, 0.5, "Cheese!")
    end
  end

  def test_linear_combination_incorrect_number_of_arguments
    point = Geom::Point3d.new(10, 10, 10)

    assert_raises(ArgumentError, "No arguments") do
      Geom.intersect_plane_plane()
    end

    assert_raises(ArgumentError, "One argument") do
      Geom.intersect_plane_plane(0.5)
    end

    assert_raises(ArgumentError, "Two argument") do
      Geom.intersect_plane_plane(0.5)
    end

    assert_raises(ArgumentError, "Three arguments") do
      Geom.intersect_plane_plane(0.5, point, 0.5)
    end

    assert_raises(ArgumentError, "Five arguments") do
      Geom.intersect_plane_plane(0.5, point, 0.5, point, 0.5)
    end
  end


  # ========================================================================== #
  # method Geom.point_in_polygon_2D
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#point_in_polygon_2D

  def test_point_in_polygon_2D_api_example
    # Create a point that we want to check. (Note that the 3rd coordinate,
    # the z, is ignored for purposes of the check.)
    point = Geom::Point3d.new(5, 0, 10)

    # Create a series of points of a triangle we want to check against.
    triangle = []
    triangle << Geom::Point3d.new(0, 0, 0)
    triangle << Geom::Point3d.new(10, 0, 0)
    triangle << Geom::Point3d.new(0, 10, 0)

    # Test to see if our point is inside the triangle, counting hits on
    # the border as an intersection in this case.
    hits_on_border_count = true
    status = Geom.point_in_polygon_2D(point, triangle, hits_on_border_count)
  end

  def test_point_in_polygon_2D_inside_polygon
    point = Geom::Point3d.new(3, 3, 0)
    polygon = get_2d_polygon()

    result = Geom.point_in_polygon_2D(point, polygon, true)
    assert_equal(true, result)
  end

  def test_point_in_polygon_2D_outside_polygon
    point = Geom::Point3d.new(9, 5, 0)
    polygon = get_2d_polygon()

    result = Geom.point_in_polygon_2D(point, polygon, true)
    assert_equal(false, result)
  end

  def test_point_in_polygon_2D_outside_polygon_reverse
    point = Geom::Point3d.new(9, 5, 0)
    polygon = get_2d_polygon()

    result = Geom.point_in_polygon_2D(point, polygon.reverse, true)
    assert_equal(false, result)
  end

  def test_point_in_polygon_2D_on_border_should_be_true
    point = Geom::Point3d.new(4, 2, 0)
    polygon = get_2d_polygon()

    result = Geom.point_in_polygon_2D(point, polygon, true)
    assert_equal(true, result)
  end

  def test_point_in_polygon_2D_on_border_should_be_false
    point = Geom::Point3d.new(4, 2, 0)
    polygon = get_2d_polygon()

    result = Geom.point_in_polygon_2D(point, polygon, false)
    assert_equal(false, result)
  end

  def test_point_in_polygon_2D_on_border_non_boolean_values
    point = Geom::Point3d.new(4, 2, 0)
    polygon = get_2d_polygon()

    result = Geom.point_in_polygon_2D(point, polygon, nil)
    assert_equal(false, result, "Should evaluate to false")

    result = Geom.point_in_polygon_2D(point, polygon, "Cheese!")
    assert_equal(true, result, "Should evaluate to true")
  end

  def test_point_in_polygon_2D_ignore_z
    point = Geom::Point3d.new(3, 3, 200)
    polygon = get_2d_polygon()

    result = Geom.point_in_polygon_2D(point, polygon, true)
    assert_equal(true, result)
  end

  def test_point_in_polygon_invalid_nil_arguments
    point = Geom::Point3d.new(3, 3, 200)
    polygon = get_2d_polygon()

    assert_raises(ArgumentError, "1. argument with nil") do
      Geom.point_in_polygon_2D(nil, polygon, false)
    end

    assert_raises(TypeError, "2. argument with nil") do
      Geom.point_in_polygon_2D(point, nil, false)
    end
  end

  def test_point_in_polygon_invalid_string_arguments
    point = Geom::Point3d.new(3, 3, 200)
    polygon = get_2d_polygon()

    assert_raises(ArgumentError, "1. argument with string") do
      Geom.point_in_polygon_2D("Cheese!", polygon, false)
    end

    assert_raises(TypeError, "2. argument with string") do
      Geom.point_in_polygon_2D(point, "Cheese!", false)
    end
  end

  def test_point_in_polygon_invalid_polygon_arguments
    point = Geom::Point3d.new(3, 3, 200)
    polygon = get_2d_polygon()

    polygon[2] = nil
    assert_raises(ArgumentError, "Polygon with nil") do
      Geom.point_in_polygon_2D("Cheese!", polygon, false)
    end

    polygon[2] = "Cheese!"
    assert_raises(ArgumentError, "Polygon with nil") do
      Geom.point_in_polygon_2D("Cheese!", polygon, false)
    end

    polygon[2] = 123
    assert_raises(ArgumentError, "Polygon with number") do
      Geom.point_in_polygon_2D("Cheese!", polygon, false)
    end
  end

  def test_point_in_polygon_incorrect_number_of_arguments
    point = Geom::Point3d.new(3, 3, 200)
    polygon = get_2d_polygon()

    assert_raises(ArgumentError, "No arguments") do
       Geom.point_in_polygon_2D()
    end

    assert_raises(ArgumentError, "One argument") do
       Geom.point_in_polygon_2D(point)
    end

    assert_raises(ArgumentError, "Two argument") do
       Geom.point_in_polygon_2D(point, polygon)
    end

    assert_raises(ArgumentError, "Four arguments") do
       Geom.point_in_polygon_2D(point, polygon, true, 123)
    end
  end


end # class

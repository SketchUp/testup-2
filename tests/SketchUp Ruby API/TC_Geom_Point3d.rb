# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"
require_relative "utils/length"


# class Geom::Point3d
# http://www.sketchup.com/intl/developer/docs/ourdoc/point3d
class TC_Geom_Point3d < TestUp::TestCase

  include TestUp::SketchUpTests::Length

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # class Geom::Point3d
  # http://www.sketchup.com/intl/developer/docs/ourdoc/point3d

  def test_introduction_api_example
    # No arguments, creates a point at the origin [0, 0, 0]
    point1 = Geom::Point3d.new

    # Creates a point at x of 100, y of 200, z of 300.
    point2 = Geom::Point3d.new(100, 200, 300)

    # You can also create a point directly by simply assigning the x, y and z
    # values to a variable as an array:
    point3 = [100, 200, 300]
  end


  # ========================================================================== #
  # method Geom::Point3d.vector_to
  # http://www.sketchup.com/intl/developer/docs/ourdoc/point3d#vector_to

  def test_vector_to
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(4, 5, 6)
    expected1 = Geom::Vector3d.new(0, 0, 0)
    expected2 = Geom::Vector3d.new(3, 3, 3)

    output1 = point1.vector_to(point1)
    assert_equal(expected1, output1)
    assert_kind_of(Geom::Vector3d, output1)

    output2 = point1.vector_to(point2)
    assert_equal(expected2, output2)
    assert_kind_of(Geom::Vector3d, output2)
  end

  def test_vector_to_api_example
    point1 = Geom::Point3d.new(10, 10, 10)
    point2 = Geom::Point3d.new(100, 200, 300)
    # Returns Vector3d(90, 190, 290)
    vector = point1.vector_to(point2)

    point3 = [1, 1, 0]
    point4 = [3, 1, 0]
    # Returns Vector3d(2,0,0).
    point3.vector_to(point4)
  end

  def test_vector_to_point
    point1 = Geom::Point3d.new(2, 4, 5)
    point2 = Geom::Point3d.new(4, 5, 8)
    expected = Geom::Vector3d.new(2, 1, 3)

    result = point1.vector_to(point2)
    assert_equal(expected, result)
  end

  def test_vector_to_array
    point1 = Geom::Point3d.new(2, 4, 5)
    point2 = [4, 5, 8]
    expected = Geom::Vector3d.new(2, 1, 3)

    result = point1.vector_to(point2)
    assert_equal(expected, result)
  end

  def test_vector_to_inputpoint
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    point1 = Geom::Point3d.new(2, 4, 5)
    point2 = Sketchup::InputPoint.new([4, 5, 8])
    expected = Geom::Vector3d.new(2, 1, 3)

    result = point1.vector_to(point2)
    assert_equal(expected, result)
  end

  def test_vector_to_vertex
    point1 = Geom::Point3d.new(2, 4, 5)
    point2 = Geom::Point3d.new(4, 5, 8)
    vertex = Sketchup.active_model.entities.add_line(point1, point2).end
    expected = Geom::Vector3d.new(2, 1, 3)

    result = point1.vector_to(vertex)
    assert_equal(expected, result)
  end

  def test_vector_to_invalid_arguments
    point1 = Geom::Point3d.new(2, 4, 5)

    assert_raises(ArgumentError, "Argument with nil") do
      point1.vector_to(nil)
    end

    assert_raises(ArgumentError, "Argument with string") do
      point1.vector_to("Cheese!")
    end

    assert_raises(ArgumentError, "Argument with number") do
      point1.vector_to(123)
    end
  end

  def test_vector_to_incorrect_number_of_arguments
    point1 = Geom::Point3d.new(2, 4, 5)
    point2 = Geom::Point3d.new(4, 5, 8)

    assert_raises(ArgumentError, "No arguments") do
      point1.vector_to
    end

    assert_raises(ArgumentError, "Two arguments") do
      point1.vector_to(point2, point2)
    end
  end

  def test_Operator_Equal
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(1, 2, 3)

    assert(point1 == point2, 'point1 and point2 are not equivalent')
  end

  def test_Operator_Equal_tolerance
    point1 = Geom::Point3d.new(1.0001, 2, 3)
    point2 = Geom::Point3d.new(1.0002, 2, 3)

    assert(point1 == point2, 'point1 and point2 are out of tolerance range')

    point1 = Geom::Point3d.new(1.001, 2, 3)
    point2 = Geom::Point3d.new(1.002, 2, 3)

    refute(point1 == point2, 'point1 and point2 should not be the same')
  end

  def test_Operator_Get
    point1 = Geom::Point3d.new(1, 2, 3)
    one = point1[0]
    two = point1[1]
    three = point1[2]

    assert_equal(point1[0], one)
    assert_equal(point1[1], two)
    assert_equal(point1[2], three)
    assert_kind_of(Length, point1[0])

    assert_raises(IndexError, 'Accessing index out of range') do
      point1[3]
    end
  end

  def test_Operator_Get_negative_index
    point1 = Geom::Point3d.new(1, 2, 3)
    assert_raises(IndexError, 'Accessing negative index') do
      point1[-4]
    end
  end

  def test_Operator_LessThan
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(1, 1, 1)

    assert(point2 < point1, 'point2 is greater or equal to point1')
    assert_equal(false, point1 < point2)
  end

  def test_Operator_LessThan_invalid_types
    point1 = Geom::Point3d.new(1, 2, 3)
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_raises(ArgumentError, 'Comparing against nil') do
      point1 < nil
    end

    assert_raises(ArgumentError, 'Comparing against string') do
      point1 < '3, 4, 5'
    end

    assert_raises(ArgumentError, 'Comparing against numbers') do
      point1 < 1234
    end

    assert_raises(ArgumentError, 'Comparing against Vector3d') do
      point1 < vector1
    end
  end

  def test_Operator_Minus
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(1, 1, 1)

    expected = Geom::Vector3d.new(0, 1, 2)
    output = point1 - point2

    assert_kind_of(Geom::Vector3d, output)
    assert_equal(expected, output)
  end

  def test_Operator_Plus
    point1 = Geom::Point3d.new(1, 2, 3)
    vector1 = Geom::Vector3d.new(1, 1, 1)

    # We can only add Vector3d to a Point3d. The return type is a Point3d
    expected = Geom::Point3d.new(2, 3, 4)
    output = point1 + vector1
    assert_kind_of(Geom::Point3d, output)
    assert_equal(expected, output)
  end

  def test_Operator_Set
    point1 = Geom::Point3d.new(1, 2, 3)
    expected = Geom::Point3d.new(7, 8, 9)
    point1[0] = 7
    point1[1] = 8
    point1[2] = 9
    assert_equal(expected, point1)
    assert_kind_of(Geom::Point3d, point1)
  end

  def test_Operator_Set_index_out_of_range
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(IndexError, "accessing index out of range") do
      point1[3] = 4
    end
  end

  def test_Operator_Set_negative_index
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(IndexError, "accessing negative index") do
      point1[-4] = 99
    end
  end

  def test_Operator_Set_invalid_types
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(TypeError, "setting wrong data type to Object") do
      point1[0] = '4'
    end

    assert_raises(TypeError, "setting nil to Object") do
      point1[0] = nil
    end
  end

  def test_clone
    point1 = Geom::Point3d.new(1, 2, 3)
    output = point1.clone
    assert_equal(point1, output)
    assert_kind_of(Geom::Point3d, output)
  end

  def test_clone_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(ArgumentError, "Argument with nil") do
      expected = point1.clone(nil)
    end

    assert_raises(ArgumentError, "Argument with string") do
      expected = point1.clone("sketchup")
    end

    assert_raises(ArgumentError, "Argument with numbers") do
      expected = point1.clone(1234)
    end
  end

  def test_distance
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(7, 7, 7)
    output = point1.distance(point2)
    assert_equal(8.77496438739, output)
    assert_kind_of(Length, output)

    point1.set!(1, 1, 1)
    point2.set!(9, 5, 0)
    output = point1.distance(point2)
    assert_equal(9, output)
    assert_kind_of(Length, output)
  end

  def test_distance_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(7, 7, 7)

    assert_raises(ArgumentError, "passing empty argument") do
      point1.distance
    end

    assert_raises(ArgumentError, "passing two arguments") do
      point1.distance(point2, point1)
    end

    assert_raises(ArgumentError, "Argument with nil") do
      point1.distance(nil)
    end

    assert_raises(ArgumentError, "Argument with string") do
      point1.distance('sketchup')
    end
  end

  def test_distance_to_line
    point1 = Geom::Point3d.new(1, 1, 1)
    line = [Geom::Point3d.new(1, 1, 1), Geom::Point3d.new(1, 1, 1)]

    output = point1.distance_to_line(line)
    assert_equal(0, output)


    point1.set!(1, 6, 1)
    line = [Geom::Point3d.new(1, 1, 8), Geom::Point3d.new(1, 1, 6)]

    output = point1.distance_to_line(line)
    assert_equal(5, output)
  end

  def test_distance_to_line_type
    skip('Type returned from distance_to_line should be Length')
    point1 = Geom::Point3d.new(1, 1, 1)
    line = [Geom::Point3d.new(1, 1, 1), Geom::Point3d.new(1, 1, 1)]

    output = point1.distance_to_line(line)
    assert_kind_of(Length, output)
  end

  def test_distance_to_line_invalid_arguments
    point1 = Geom::Point3d.new(1, 1, 1)
    line = [Geom::Point3d.new(1, 1, 1), Geom::Point3d.new(1, 1, 1)]

    assert_raises(ArgumentError, 'passing empty argument') do
      point1.distance_to_line
    end

    assert_raises(TypeError, 'Argument with nil') do
      point1.distance_to_line(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      point1.distance_to_line('sketchup')
    end

    assert_raises(TypeError, 'Argument with 2 arguments') do
      point1.distance_to_line(line, line)
    end

    assert_raises(TypeError, 'Argument with numbers') do
      point1.distance_to_line(123)
    end
  end

  def test_distance_to_plane
    point1 = Geom::Point3d.new(99, 0, 0)
    plane = [Geom::Point3d.new(0, 0, 1), Z_AXIS]
    output = point1.distance_to_plane(plane)
    assert_equal(1, output)
  end

  def test_distance_to_plane_type
    skip('Type returned from distance_to_plane should be Length')
    point1 = Geom::Point3d.new(99, 0, 0)
    plane = [Geom::Point3d.new(0, 0, 1), Z_AXIS]
    output = point1.distance_to_plane(plane)
    assert_kind_of(Length, output)
  end

  def test_distance_to_plane_invalid_arguments
    point1 = Geom::Point3d.new(1, 1, 1)
    plane = [Geom::Point3d.new(1, 1, 1), Z_AXIS]

    assert_raises(ArgumentError, 'passing empty argument') do
      point1.distance_to_plane
    end

    assert_raises(TypeError, 'Argument with nil') do
      point1.distance_to_plane(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      point1.distance_to_plane('sketchup')
    end

    assert_raises(TypeError, 'Argument with 2 arguments') do
      point1.distance_to_plane(plane, plane)
    end

    assert_raises(TypeError, 'Argument with numbers') do
      point1.distance_to_plane(123)
    end
  end

  def test_initialize
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(4, 5, 6)
    pointCoordinates = Geom::Point3d.new(1, 2, 3)
    pointArray3d = Geom::Point3d.new([1, 2, 3])
    pointArray2d = Geom::Point3d.new([1, 2])
    pointInputPoint = Geom::Point3d.new(Sketchup::InputPoint.new(point1))
    vertex = Sketchup.active_model.entities.add_edges(point1, point2).first.start

    pointVertex = Geom::Point3d.new(vertex)

    expected = Geom::Point3d.new(1, 2, 3)
    expected2d = Geom::Point3d.new(1, 2, 0)

    assert_equal(expected, pointCoordinates, "assert failure: coordinates")
    assert_equal(expected, pointArray3d, "assert failure: array3d")
    assert_equal(expected2d, pointArray2d, "assert failure: array2d")
    assert_equal(expected, pointInputPoint, "assert failure: input_point")
    assert_equal(expected, pointVertex, "assert failure: vertex")
  end

  def test_initialize_invalid_arguments
    assert_raises(ArgumentError, "Argument with nil") do
      point1 = Geom::Point3d.new(nil)
    end

    assert_raises(ArgumentError, "Argument with string") do
      point1 = Geom::Point3d.new('sketchup')
    end

    assert_raises(ArgumentError, "Argument with 1 number") do
      point1 = Geom::Point3d.new(1)
    end
  end

  class CustomPoint < Geom::Point3d; end
  def test_initialize_subclassed
    # Making sure we created the objects correctly so it can be sub-classed.
    CustomPoint::new(12, 34, 56)
  end

  def test_inspect
    point1 = Geom::Point3d.new(1, 2, 3)
    assert_equal("Point3d(1, 2, 3)", point1.inspect)

    point1.set!(1.5, 2.5, 3.5)
    assert_equal("Point3d(1.5, 2.5, 3.5)", point1.inspect)
  end

  def test_linear_combination
    point1 = Geom::Point3d.new(2, 4, 6)
    point2 = Geom::Point3d.new(8, 10, 12)
    expected = Geom::Point3d.new(5, 7, 9)

    # linear_combination is (weight1 * point1) + (weight2 * point2)
    # 0.5 * [2, 4, 6] = [1, 2, 3] --> AxB matrix sort of stuff
    output = Geom::Point3d.linear_combination(0.5, point1, 0.5, point2)
    assert_equal(expected, output)

    expected = Geom::Point3d.new(95, 127, 159)
    output = Geom::Point3d.linear_combination(5.5, point1, 10.5, point2)
    assert_equal(expected, output)

    expected = Geom::Point3d.new(-102, -138, -174)
    output = Geom::Point3d.linear_combination(-7, point1, -11, point2)
    assert_equal(expected, output)

    assert_kind_of(Geom::Point3d, output)
  end

  def test_linear_combination_invalid_arguments
    point1 = Geom::Point3d.new(2, 4, 6)
    point2 = Geom::Point3d.new(8, 10, 12)

    assert_raises(ArgumentError, "passing empty argument") do
      Geom::Point3d.linear_combination
    end

    assert_raises(ArgumentError, "passing too many arguments") do
      Geom::Point3d.linear_combination(1, 2, 3, 4, 5)
    end

    assert_raises(TypeError, "Argument with nils") do
      Geom::Point3d.linear_combination(nil, nil, nil, nil)
    end

    assert_raises(TypeError, "Argument with strings") do
      Geom::Point3d.linear_combination("sk", "et", "ch", "up")
    end

    assert_raises(ArgumentError, "Argument with numbers") do
      Geom::Point3d.linear_combination(1, 2, 3, 4)
    end

    assert_raises(TypeError, "Argument with arrays") do
      Geom::Point3d.linear_combination([1], [2], [3], [4])
    end

    assert_raises(ArgumentError, "Argument with mixes") do
      Geom::Point3d.linear_combination(2, [2], 'sketchup', nil)
    end
  end

  def test_offset
    point1 = Geom::Point3d.new(1, 2, 3)
    vector1 = Geom::Vector3d.new(1, 1, 1)
    expected = Geom::Point3d.new(2, 3, 4)

    output = point1.offset(vector1)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point3d, output)

    expected = Geom::Point3d.new(7.35085, 8.35085, 9.35085)
    output = point1.offset(vector1, 11)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point3d, output)
  end

  def test_offset_length_zero
    # Our Document says length must not be zero, but no error is raised.
    # Current behavior: Returns the original point without any modifications
    point1 = Geom::Point3d.new(11, 21, 31)
    vector1 = Geom::Vector3d.new(1, 1, 1)
    assert_equal(point1, point1.offset(vector1, 0))
  end

  def test_offset_invalid_arguments
    # Our Document says length must not be zero, but no error is raised.
    # The expected behavior was that an error would occur. Like ArgumentError
    skip('Document says offset cannot be zero')
    point1 = Geom::Point3d.new(11, 21, 31)
    vector1 = Geom::Vector3d.new(1, 1, 1)

    assert_raises(ArgumentError, "Argument with zero") do
      point2 = point1.offset(vector1, 0)
    end
  end

  def test_offset_Bang
    point1 = Geom::Point3d.new(1, 2, 3)
    vector1 = Geom::Vector3d.new(1, 1, 1)
    expected = Geom::Point3d.new(2, 3, 4)

    output = point1.offset!(vector1)
    assert_equal(expected, output)
    assert_equal(expected, point1)
  end

  def test_offset_Bang_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(ArgumentError, "passing too many arguments") do
      point1.offset!(point1, point1)
    end

    assert_raises(ArgumentError, "passing empty argument") do
      point1.offset!
    end

    assert_raises(ArgumentError, 'Argument with nil') do
      point1.offset!(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      point1.offset!('Sketchup')
    end

    assert_raises(ArgumentError, 'Argument with point3d') do
      point1.offset!(point1)
    end
  end

  def test_on_line_Query
    point1 = Geom::Point3d.new(1, 2, 3)
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    output = point1.on_line?(line)
    refute(output)

    point1.set!([0, 0, 16])
    output = point1.on_line?(line)
    assert(output)

    point1.set!([0.0001, 0.0002, 16.0001])
    output = point1.on_line?(line)
    assert(output)
  end

  def test_on_line_Query_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    assert_raises(ArgumentError, "passing empty argument") do
      point1.on_line?
    end

    assert_raises(TypeError, "Arguments with nil") do
      point1.on_line?(nil)
    end

    assert_raises(TypeError, "Arguments with 2 arguments") do
      point1.on_line?(line, line)
    end

    assert_raises(TypeError, "Argument with number") do
      point1.on_line?(1234)
    end

    assert_raises(TypeError, "Argument with string") do
      point1.on_line?('sketchup')
    end
  end

  def test_on_plane_Query
    point1 = Geom::Point3d.new(1, 2, 3)
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    output = point1.on_plane?(plane)
    refute(output)

    point1.set!([16, 0, 0])
    output = point1.on_plane?(plane)
    assert(output)

    point1.set!([16.0001, 0.0001, 0.0004])
    output = point1.on_plane?(plane)
    assert(output)
  end

  def test_on_plane_Query_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    assert_raises(ArgumentError, "passing empty argument") do
      point1.on_plane?
    end

    assert_raises(TypeError, "Argument with nil") do
      point1.on_plane?(nil)
    end

    assert_raises(TypeError, "Argument with string") do
      point1.on_plane?('sketchup')
    end

    assert_raises(TypeError, "Argument with numbers") do
      point1.on_plane?(1234)
    end

    assert_raises(TypeError, "Argument with 2 arguments") do
      point1.on_plane?(plane, plane)
    end
  end

  def test_project_to_line
    point1 = Geom::Point3d.new(1, 1, 1)
    line = [Geom::Point3d.new(1, 2, 3), Geom::Point3d.new(2, 3, 4)]
    expected = Geom::Point3d.new(0, 1, 2)

    output = point1.project_to_line(line)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point3d, output)
  end

  def test_project_to_line_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    line = [Geom::Point3d.new(1, 2, 3), Geom::Point3d.new(2, 3, 4)]

    assert_raises(ArgumentError, 'passing empty argument') do
      point1.project_to_line
    end

    assert_raises(TypeError, 'Argument with nil') do
      point1.project_to_line(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      point1.project_to_line('sketchup')
    end

    assert_raises(TypeError, 'Argument with 2 arguments') do
      point1.project_to_line(line, line)
    end

    assert_raises(TypeError, 'Argument with number') do
      point1.project_to_line(123)
    end
  end

  def test_project_to_plane
    point1 = Geom::Point3d.new(1, 2, 3)
    plane1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    expected = Geom::Point3d.new(1, 2, 0)

    output = point1.project_to_plane(plane1)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point3d, output)

    plane2 = [Geom::Point3d.new(0, 0, 0), Z_AXIS]
    output = point1.project_to_plane(plane2)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point3d, output)
  end

  def test_project_to_plane_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    plane1 = [Geom::Point3d.new(0, 0, 0), X_AXIS]

    assert_raises(ArgumentError, "passing empty arugment") do
      point1.project_to_plane
    end

    assert_raises(TypeError, "Argument with nil ") do
      point1.project_to_plane(nil)
    end

    assert_raises(TypeError, "Argument with string") do
      point1.project_to_plane('sketchup')
    end

    assert_raises(TypeError, "Argument with number") do
      point1.project_to_plane(1234)
    end

    assert_raises(TypeError, "Argument with 2 planes") do
      point1.project_to_plane(plane1, plane1)
    end
  end

  def test_to_s
    point1 = Geom::Point3d.new(1, 2, 3)
    model = Sketchup.active_model

    model.options['UnitsOptions']['LengthFormat'] = Length::Architectural
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal(u('(1", 2", 3")'), point1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Decimal
    assert_equal(u('(1", 2", 3")'), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal(u("(0.083333', 0.166667', 0.25')"), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Millimeter
    assert_equal(u("(25.4mm, 50.8mm, 76.2mm)"), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Centimeter
    assert_equal(u("(2.54cm, 5.08cm, 7.62cm)"), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Meter
    assert_equal(u("(0.0254m, 0.0508m, 0.0762m)"), point1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Engineering
    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal(u("(0.083333', 0.166667', 0.25')"), point1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Fractional
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal(u('(1", 2", 3")'), point1.to_s)
  end

  def test_to_a
    point1 = Geom::Point3d.new(1, 2, 3)
    expected = [1.0, 2.0, 3.0]

    output = point1.to_a
    assert_equal(expected, output)
    assert_kind_of(Array, output)
    assert_kind_of(Float, output[0])

    assert_equal([0.0, 0.0, 0.0], ORIGIN.to_a)
  end

  def test_set_Bang
    point1 = Geom::Point3d.new(1, 2, 3)
    expected = Geom::Point3d.new(7, 7, 7)
    point1.set!(7, 7, 7)
    assert_equal(expected, point1)
  end

  def test_set_Bang_too_many_arguments
    # This is actually supported, extra args are ignored
    point1 = Geom::Point3d.new(1, 2, 3)
    expected = Geom::Point3d.new(7, 7, 7)
    point1.set!(7, 7, 7, 0, 1, 2)
    assert_equal(expected, point1)
  end

  def test_set_Bang_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(TypeError, "Argument with nil") do
      point1.set!(nil)
    end

    assert_raises(TypeError, "Argument type is string") do
      point1.set!('sketchup')
    end

    assert_raises(ArgumentError, "Empty argument") do
      point1.set!
    end
  end

  def test_set_Bang_too_many_arguments_ideal
    # What was actually expected was this to throw an ArgumentError since
    # we are passing in more arguments than needed for this method.
    skip('Passing too many arguments should issue error')
    point1 = Geom::Point3d.new(1, 2, 3)
    assert_raises(ArgumentError, "Argument with 5 numbers") do
      point1.set!(1, 2, 3, 4, 5)
    end
  end

  def test_transform
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(10, 10, 10)
    transform = Geom::Transformation.new(point1)
    expected = Geom::Point3d.new(11, 12, 13)

    output = point2.transform(transform)
    assert_equal(expected, output)

    vector1 = Geom::Vector3d.new(1, 0, 0)
    angle = 45.degrees
    transformRotation = Geom::Transformation.rotation(point1, vector1, angle)
    expected.set!(10, 2.70711, 13.6066)
    output = point2.transform(transformRotation)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point3d, output)
  end

  def test_transform_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(10, 10, 10)
    transform = Geom::Transformation.new(point1)

    assert_raises(ArgumentError, "passing empty argument") do
      point2.transform
    end

    assert_raises(TypeError, "Argument with nil") do
      point2.transform(nil)
    end

    assert_raises(TypeError, "Argument with string") do
      point2.transform('sketchup')
    end

    assert_raises(ArgumentError, "Argument with 2 arguments") do
      point2.transform(transform, transform)
    end
  end

  def test_transform_Bang
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(10, 10, 10)
    transform = Geom::Transformation.new(point1)
    expected = Geom::Point3d.new(11, 12, 13)

    output = point2.transform!(transform)
    assert_equal(expected, output)
    assert_equal(expected, point2)
  end

  def test_transform_Bang_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(10, 10, 10)
    transform = Geom::Transformation.new(point1)

    assert_raises(TypeError, "Argument with nil") do
      point2.transform!(nil)
    end

    assert_raises(TypeError, "Argument with string") do
      point2.transform!('sketchup')
    end

    assert_raises(ArgumentError, "Argument with 2 arguments") do
      point2.transform!(transform, transform)
    end
  end

  def test_x
    point1 = Geom::Point3d.new(1, 2, 3)

    output = point1.x
    assert_equal(1, output)
    assert_kind_of(Length, output)
  end

  def test_x_Set
    point1 = Geom::Point3d.new(1, 2, 3)
    point1.x = 123
    assert_equal(123, point1.x)
  end

  def test_x_Set_invalid_values
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(TypeError, "Value with nil") do
      point1.x = nil
    end

    assert_raises(TypeError, "Value with string") do
      point1.x = '123'
    end

    assert_raises(TypeError, "Value with array") do
      point1.x = [1, 2, 3]
    end
  end

  def test_y
    point1 = Geom::Point3d.new(1, 2, 3)
    output = point1.y
    assert_equal(2, output)
    assert_kind_of(Length, output)
  end

  def test_y_Set
    point1 = Geom::Point3d.new(1, 2, 3)
    point1.y = 123
    assert_equal(123, point1.y)
  end

  def test_y_Set_invalid_values
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(TypeError, "Value with nil") do
      point1.y = nil
    end

    assert_raises(TypeError, "Value with string") do
      point1.y = '123'
    end

    assert_raises(TypeError, "Value with array") do
      point1.y = [1, 2, 3]
    end
  end

  def test_z
    point1 = Geom::Point3d.new(1, 2, 3)
    output = point1.z
    assert_equal(3, output)
    assert_kind_of(Length, output)
  end

  def test_z_Set
    point1 = Geom::Point3d.new(1, 2, 3)
    point1.z = 123
    assert_equal(123, point1.z)
  end

  def test_z_Set_invalid_values
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(TypeError, "Value with nil") do
      point1.z = nil
    end

    assert_raises(TypeError, "Value with string") do
      point1.z = '123'
    end

    assert_raises(TypeError, "Value with array") do
      point1.z = [1, 2, 3]
    end
  end
end # class

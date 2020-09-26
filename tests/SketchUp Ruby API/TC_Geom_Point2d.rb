# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Adam Karkkainen


require "testup/testcase"
require_relative "utils/frozen"
require_relative "utils/length"


# class Geom::Point2d
class TC_Geom_Point2d < TestUp::TestCase

  include TestUp::SketchUpTests::Frozen
  include TestUp::SketchUpTests::Length

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # class Geom::Point2d
  def test_introduction_api_example
    # No arguments, creates a point at the origin [0, 0]
    point1 = Geom::Point2d.new

    # Creates a point at x of 100, y of 200.
    point2 = Geom::Point2d.new(100, 200)

    # You can also create a point directly by simply assigning the x and y
    # values to a variable as an array:
    point3 = [100, 200]
  end

  def test_vector_to_api_example
    point1 = Geom::Point2d.new(10, 10)
    point2 = Geom::Point2d.new(100, 200)
    # Returns Vector2d(90, 190)
    vector = point1.vector_to(point2)

    point3 = [1, 1]
    point4 = [3, 1]
    # Returns Vector2d(2, 0).
    point3.vector_to(point4)
  end
  # ========================================================================== #

  def test_vector_to_point
    point1 = Geom::Point2d.new(2, 4)
    point2 = Geom::Point2d.new(4, 5)
    expected1 = Geom::Vector2d.new(0, 0)
    expected2 = Geom::Vector2d.new(2, 1)

    output1 = point1.vector_to(point1)
    assert_equal(expected1, output1)
    assert_kind_of(Geom::Vector2d, output1)

    output2 = point1.vector_to(point2)
    assert_equal(expected2, output2)
    assert_kind_of(Geom::Vector2d, output2)
  end

  def test_vector_to_array
    point1 = Geom::Point2d.new(2, 4)
    point2 = [4, 5]
    expected = Geom::Vector2d.new(2, 1)

    result = point1.vector_to(point2)
    assert_equal(expected, result)
  end

  def test_vector_to_invalid_arguments
    point1 = Geom::Point2d.new(2, 4)

    assert_raises(TypeError, "Argument with nil") do
      point1.vector_to(nil)
    end

    assert_raises(TypeError, "Argument with string") do
      point1.vector_to("Cheese!")
    end

    assert_raises(TypeError, "Argument with number") do
      point1.vector_to(123)
    end
  end

  def test_vector_to_incorrect_number_of_arguments
    point1 = Geom::Point2d.new(2, 4)
    point2 = Geom::Point2d.new(4, 5)

    assert_raises(ArgumentError, "No arguments") do
      point1.vector_to
    end

    assert_raises(ArgumentError, "Two arguments") do
      point1.vector_to(point2, point2)
    end
  end

  def test_Operator_Equal
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(1, 2)

    assert(point1 == point2, 'point1 and point2 are not equivalent')
  end

  def test_Operator_Equal_tolerance
    point1 = Geom::Point2d.new(1.0001, 2)
    point2 = Geom::Point2d.new(1.0002, 2)

    assert(point1 == point2, 'point1 and point2 are out of tolerance range')

    point1 = Geom::Point2d.new(1.001, 2)
    point2 = Geom::Point2d.new(1.002, 2)

    refute(point1 == point2, 'point1 and point2 should not be the same')
  end

  def test_Operator_Get
    point1 = Geom::Point2d.new(1, 2)
    one = point1[0]
    two = point1[1]

    assert_equal(point1[0], one)
    assert_equal(point1[1], two)
    assert_kind_of(Length, point1[0])

    assert_raises(IndexError, 'Accessing index out of range') do
      point1[2]
    end
  end

  def test_Operator_Get_negative_index
    point1 = Geom::Point2d.new(1, 2)
    assert_equal(1, point1[-2])
    assert_equal(2, point1[-1])
  end

  def test_Operator_Get_negative_index_out_of_range
    point1 = Geom::Point2d.new(1, 2)
    assert_raises(IndexError, 'Accessing negative index') do
      point1[-3]
    end
  end

  def test_Operator_Minus
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(1, 1)

    expected = Geom::Vector2d.new(0, 1)
    output = point1 - point2

    assert_kind_of(Geom::Vector2d, output)
    assert_equal(expected, output)
  end

  def test_Operator_Plus
    point1 = Geom::Point2d.new(1, 2)
    vector1 = Geom::Vector2d.new(1, 1)

    # We can only add Vector2d to a Point2d. The return type is a Point2d
    expected = Geom::Point2d.new(2, 3)
    output = point1 + vector1
    assert_kind_of(Geom::Point2d, output)
    assert_equal(expected, output)
  end

  def test_Operator_Set
    point1 = Geom::Point2d.new(1, 2)
    expected = Geom::Point2d.new(7, 8)
    point1[0] = 7
    point1[1] = 8
    assert_equal(expected, point1)
    assert_kind_of(Geom::Point2d, point1)
  end

  def test_Operator_Set_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Point2d') do
      ORIGIN_2D[0] = 1
    end

    assert_raises(FROZEN_ERROR, 'set frozen Geom::Point2d') do
      ORIGIN_2D[1] = 1
    end
  end

  def test_Operator_Set_negative_index
    point1 = Geom::Point2d.new(1, 2)
    point1[-1] = 3
    point1[-2] = 5
    assert_equal(5, point1[0])
    assert_equal(3, point1[1])
  end

  def test_Operator_Set_index_out_of_range
    point1 = Geom::Point2d.new(1, 2)

    assert_raises(IndexError, "accessing index out of range") do
      point1[2] = 4
    end
  end

  def test_Operator_Set_negative_index_out_of_range
    point1 = Geom::Point2d.new(1, 2)

    assert_raises(IndexError, "accessing negative index") do
      point1[-3] = 99
    end
  end

  def test_Operator_Set_invalid_types
    point1 = Geom::Point2d.new(1, 2)

    assert_raises(TypeError, "setting string to index 0") do
      point1[0] = '4'
    end

    assert_raises(TypeError, "setting string to index 0") do
      point1[1] = '4'
    end

    assert_raises(TypeError, "setting nil index 1") do
      point1[0] = nil
    end

    assert_raises(TypeError, "setting nil index 1") do
      point1[1] = nil
    end
  end

  def test_clone
    point1 = Geom::Point2d.new(1, 2)
    output = point1.clone
    assert_equal(point1, output)
    assert_kind_of(Geom::Point2d, output)
    refute(output.object_id == point1.object_id)
  end

  def test_clone_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)

    assert_raises(ArgumentError, "Argument with nil") do
      point1.clone(nil)
    end

    assert_raises(ArgumentError, "Argument with string") do
      point1.clone("sketchup")
    end

    assert_raises(ArgumentError, "Argument with numbers") do
      point1.clone(1234)
    end
  end

  def test_distance
    point1 = Geom::Point2d.new(4, 3)
    point2 = Geom::Point2d.new(7, 7)
    output = point1.distance(point2)
    assert_equal(5, output)
    assert_kind_of(Length, output)

    point1.set!(1, 5)
    point2.set!(9, 5)
    output = point1.distance(point2)
    assert_equal(8, output)
    assert_kind_of(Length, output)
  end

  def test_distance_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(7, 7)

    assert_raises(ArgumentError, "passing empty argument") do
      point1.distance
    end

    assert_raises(TypeError, "Argument with nil") do
      point1.distance(nil)
    end

    assert_raises(TypeError, "Argument with string") do
      point1.distance('sketchup')
    end

    assert_raises(ArgumentError, "passing two arguments") do
      point1.distance(point2, point1)
    end
  end

  def test_initialize
    pointCoordinates = Geom::Point2d.new(1, 2)
    pointArray2d = Geom::Point2d.new([1, 2])
    pointLengths = Geom::Point2d.new(1.to_l, 2.to_l)
    pointFloats = Geom::Point2d.new(1.234, 2.345)

    expected = Geom::Point2d.new(1, 2)

    assert_equal(expected, pointCoordinates, "assert failure: coordinates")
    assert_equal(expected, pointArray2d, "assert failure: array2d")
    assert_equal(expected, pointLengths, "assert failure: lengths")
    assert_equal(1.234, pointFloats[0], "assert failure: floats")
    assert_equal(2.345, pointFloats[1], "assert failure: floats")
  end

  def test_initialize_invalid_arguments
    assert_raises(TypeError, "Argument with nil") do
      Geom::Point2d.new(nil)
    end

    assert_raises(TypeError, "Argument with string") do
      Geom::Point2d.new('sketchup')
    end

    assert_raises(TypeError, "Argument with 1 number") do
      Geom::Point2d.new(1)
    end
  end

  class CustomPoint < Geom::Point2d; end
  def test_initialize_subclassed
    # Making sure we created the objects correctly so it can be sub-classed.
    point = CustomPoint::new(12, 34)
    assert_kind_of(CustomPoint, point)
    assert_kind_of(Geom::Point2d, point)
    assert_equal(12, point.x)
    assert_equal(34, point.y)
  end

  def test_inspect
    point1 = Geom::Point2d.new(1, 2)
    assert_equal("Point2d(1, 2)", point1.inspect)

    point1.set!(1.5, 2.5)
    assert_equal("Point2d(1.5, 2.5)", point1.inspect)
  end

  def test_offset
    point1 = Geom::Point2d.new(1, 2)
    vector1 = Geom::Vector2d.new(1, 1)
    expected = Geom::Point2d.new(2, 3)

    output = point1.offset(vector1)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point2d, output)

    expected = Geom::Point2d.new(8.77817, 9.77817)
    output = point1.offset(vector1, 11)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point2d, output)
  end

  def test_offset_invalid_arguments
    point1 = Geom::Point2d.new(11, 21)
    vector1 = Geom::Vector2d.new(1, 1)

    assert_raises(ArgumentError, "Argument with zero") do
      point2 = point1.offset(vector1, 0)
    end
  end

  def test_offset_Bang
    point1 = Geom::Point2d.new(1, 2)
    vector1 = Geom::Vector2d.new(1, 1)
    expected = Geom::Point2d.new(2, 3)

    output = point1.offset!(vector1)
    assert_equal(expected, output)
    assert_equal(expected, point1)
  end

  def test_offset_Bang_frozen
    vector1 = Geom::Vector2d.new(1, 1)
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Point2d') do
      ORIGIN_2D.offset!(vector1)
    end
  end

  def test_offset_Bang_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)

    assert_raises(TypeError, "passing too many arguments") do
      point1.offset!(point1, point1)
    end

    assert_raises(ArgumentError, "passing empty argument") do
      point1.offset!
    end

    assert_raises(TypeError, 'Argument with nil') do
      point1.offset!(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      point1.offset!('Sketchup')
    end

    assert_raises(TypeError, 'Argument with point2d') do
      point1.offset!(point1)
    end
  end

  def test_to_s
    point1 = Geom::Point2d.new(1, 2)
    model = Sketchup.active_model

    model.options['UnitsOptions']['LengthFormat'] = Length::Architectural
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal(u('(1", 2")'), point1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Decimal
    assert_equal(u('(1", 2")'), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal(u("(0.083333', 0.166667')"), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Millimeter
    assert_equal(u("(25.4mm, 50.8mm)"), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Centimeter
    assert_equal(u("(2.54cm, 5.08cm)"), point1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Meter
    assert_equal(u("(0.0254m, 0.0508m)"), point1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Engineering
    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal(u("(0.083333', 0.166667')"), point1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Fractional
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal(u('(1", 2")'), point1.to_s)
  end

  def test_to_a
    point1 = Geom::Point2d.new(1, 2)
    expected = [1.0, 2.0]

    output = point1.to_a
    assert_equal(expected, output)
    assert_kind_of(Array, output)
    assert_kind_of(Float, output[0])

    assert_equal([0.0, 0.0], ORIGIN_2D.to_a)
  end

  def test_set_Bang
    point1 = Geom::Point2d.new(1, 2)
    expected = Geom::Point2d.new(7, 7)
    point1.set!(7, 7)
    assert_equal(expected, point1)
  end

  def test_set_Bang_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Point2d') do
      ORIGIN_2D.set!(1, 2)
    end
  end

  def test_set_Bang_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)

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

  def test_set_Bang_too_many_arguments
    point1 = Geom::Point2d.new(1, 2)
    assert_raises(ArgumentError, "Argument with 3 numbers") do
      point1.set!(1, 2, 3)
    end
  end

  def test_transform
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(10, 10)
    transform = Geom::Transformation2d.translation(point1)
    expected = Geom::Point2d.new(11, 12)

    output = point2.transform(transform)
    assert_equal(expected, output)

    angle = 45.degrees
    transformRotation = Geom::Transformation2d.rotation(point1, angle)
    expected.set!(1.70711, 14.0208)
    output = point2.transform(transformRotation)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point2d, output)
  end

  def test_transform_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(10, 10)
    transform = Geom::Transformation2d.translation(point1)

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
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(10, 10)
    transform = Geom::Transformation2d.translation(point1)
    expected = Geom::Point2d.new(11, 12)

    output = point2.transform!(transform)
    assert_equal(expected, output)
    assert_equal(expected, point2)
  end

  def test_transform_Bang_frozen
    transform = Geom::Transformation2d.new
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Point2d') do
      ORIGIN_2D.transform!(transform)
    end
  end

  def test_transform_Bang_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(10, 10)
    transform = Geom::Transformation2d.translation(point1)

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
    point1 = Geom::Point2d.new(1, 2)

    output = point1.x
    assert_equal(1, output)
    assert_kind_of(Length, output)
  end

  def test_x_Set
    point1 = Geom::Point2d.new(1, 2)
    point1.x = 123
    assert_equal(123, point1.x)
    assert_kind_of(Length, point1.x)

    point1.x = 12.3
    assert_equal(12.3, point1.x)
    assert_kind_of(Length, point1.x)

    point1.x = 12.3.to_l
    assert_equal(12.3, point1.x)
    assert_kind_of(Length, point1.x)
  end

  def test_x_Set_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Point2d') do
      ORIGIN_2D.x = 1
    end
  end

  def test_x_Set_invalid_values
    point1 = Geom::Point2d.new(1, 2)

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
    point1 = Geom::Point2d.new(1, 2)
    output = point1.y
    assert_equal(2, output)
    assert_kind_of(Length, output)
  end

  def test_y_Set
    point1 = Geom::Point2d.new(1, 2)
    point1.y = 123
    assert_equal(123, point1.y)
    assert_kind_of(Length, point1.y)

    point1.y = 12.3
    assert_equal(12.3, point1.y)
    assert_kind_of(Length, point1.y)

    point1.y = 12.3.to_l
    assert_equal(12.3, point1.y)
    assert_kind_of(Length, point1.y)
  end

  def test_y_Set_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Point2d') do
      ORIGIN_2D.y = 1
    end
  end

  def test_y_Set_invalid_values
    point1 = Geom::Point2d.new(1, 2)

    assert_raises(TypeError, "Value with nil") do
      point1.y = nil
    end

    assert_raises(TypeError, "Value with string") do
      point1.y = '123'
    end

    assert_raises(TypeError, "Value with array") do
      point1.y = [1, 2]
    end
  end
end # class

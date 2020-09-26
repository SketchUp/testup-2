# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Adam Karkkainen


require "testup/testcase"
require_relative "utils/frozen"


# class Geom::Vector2d
class TC_Geom_Vector2d < TestUp::TestCase

  include TestUp::SketchUpTests::Frozen

  def setup
    # ...
  end

  def teardown
    # ...
  end

  # Copied from mathutils.cpp
  # TODO(thomthom): Move this to a reusable helper mix-in.
  DivideByZeroTol = 1.0e-10

  def assert_equal_tol(expected, actual, tol = DivideByZeroTol)
    assert_in_delta(expected, actual, tol)
  end


  def test_Operator_Equal
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(1, 2)

    assert(vector1 == vector2, 'vector1 and vector2 are not equivalent')
  end

  def test_Operator_Equal_tolerance
    vector1 = Geom::Vector2d.new(1.0001, 2)
    vector2 = Geom::Vector2d.new(1.0002, 2)

    assert(vector1 == vector2, 'vector1 and vector2 are out of tolerance range')

    vector1 = Geom::Vector2d.new(1.001, 2)
    vector2 = Geom::Vector2d.new(1.002, 2)

    refute(vector1 == vector2, 'vector1 and vector2 should not be the same')
  end

  def test_Operator_Get
    vector1 = Geom::Vector2d.new(1, 2)

    assert_equal(1, vector1[0])
    assert_equal(2, vector1[1])
    assert_equal(1, vector1[-2])
    assert_equal(2, vector1[-1])
  end

  def test_Operator_Get_index_out_of_range
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(IndexError, 'accessing index out of range') do
      vector1[3]
    end

    assert_raises(IndexError, 'accessing index out of range') do
      vector1[-3]
    end
  end

  def test_Operator_Minus
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(7, 11)
    expected = Geom::Vector2d.new(6, 9)
    output = vector2 - vector1
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector2d, output)

    output = vector2 - [1, 2]
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector2d, output)
  end

  def test_Operator_Minus_invalid_types
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'subtracting string from a Vector2d object') do
      vector1 - 'sketchup'
    end

    assert_raises(TypeError, 'subtracting nil from a Vector2d object') do
      vector1 - nil
    end

    assert_raises(TypeError, 'subtracting number from a Vector2d') do
      vector1 - 33
    end

    assert_raises(TypeError, 'subtracting Point2d from a Vector2d') do
      vector1 - Geom::Point2d.new(5, 6)
    end
  end

  def test_Operator_Modulo
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)

    output = vector1 % vector2
    assert_equal(14, output)
    assert_kind_of(Float, output)

    output = vector1 % [4, 5]
    assert_equal(14, output)
    assert_kind_of(Float, output)
  end

  def test_Operator_Modulo_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument witn nil') do
      vector1 % nil
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1 % 'sketchup'
    end

    assert_raises(TypeError, 'Argument with number') do
      vector1 % 1234
    end

    assert_raises(TypeError, 'Argument with Point2d') do
      vector1 % Geom::Point2d.new(4, 5)
    end
  end

  def test_Operator_Multiply
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)
    expected = -3
    output = vector1 * vector2
    assert_equal(expected, output)
    assert_kind_of(Float, output)

    output = vector1 * [4, 5]
    assert_equal(expected, output)
    assert_kind_of(Float, output)
    assert_equal(0, vector1 * vector1)
  end

  def test_Operator_Multiply_invalid_types
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'multiplying with string') do
      vector1 * 'sketchup'
    end

    assert_raises(TypeError, 'multiplying with nil') do
      vector1 * nil
    end

    assert_raises(TypeError, 'multiplying with number') do
      vector1 * 1234
    end

    assert_raises(TypeError, 'multiplying with Point2d') do
      vector1 * Geom::Point2d.new(4, 5)
    end
  end

  def test_Operator_Plus
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)

    expected = Geom::Vector2d.new(5, 7)
    output = vector1 + vector2
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector2d, output)

    output = vector1 + [4, 5]
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector2d, output)
  end

  def test_Operator_Plus_invalid_types
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'adding with string') do
      vector1 + 'sketchup'
    end

    assert_raises(TypeError, 'adding with nil') do
      vector1 + nil
    end

    assert_raises(TypeError, 'adding with number') do
      vector1 + 1234
    end

    assert_raises(TypeError, 'multiplying with Point2d') do
      vector1 + Geom::Point2d.new(4, 5)
    end
  end

  def test_Operator_Set
    vector1 = Geom::Vector2d.new(1, 2)
    vector1[0] = 4
    vector1[1] = 5
    assert_equal(4, vector1[0])
    assert_equal(5, vector1[1])

    vector1[0] = 4.2
    vector1[1] = 5.1
    assert_equal(4.2, vector1[0])
    assert_equal(5.1, vector1[1])

    vector1[0] = 1.23.to_l
    vector1[1] = 2.34.to_l
    assert_equal(1.23, vector1[0])
    assert_equal(2.34, vector1[1])

    vector1[-2] = 7
    vector1[-1] = 8
    assert_equal(7, vector1[-2])
    assert_equal(8, vector1[-1])
  end

  def test_Operator_Set_frozen
    vector1 = Geom::Vector2d.new(1, 2)
    vector1.freeze
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      vector1[0] = 4
    end
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      vector1[1] = 5
    end
  end

  def test_Operator_Set_invalid_types
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'set element with string') do
      vector1[0] = 'sketchup'
    end

    assert_raises(TypeError, 'set element with nil') do
      vector1[0] = nil
    end

    assert_raises(TypeError, 'set element with array') do
      vector1[0] = [1]
    end

    assert_raises(TypeError, 'set element with Point2d') do
      vector1[0] = Geom::Point2d.new(1, 2)
    end
  end

  def test_angle_between
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)
    angle = vector1.angle_between(vector2)
    assert_equal(0.21109333322274632, angle)

    vector1.set!(-1, -1)
    vector2.set!(1, 1)
    angle = vector1.angle_between(vector2)
    #float > double inaccuracy is causing rounding issues
    assert_equal_tol(Math::PI, angle, 0.0000001)
    assert_kind_of(Float, angle)

    # testing possible zero length vectors
    zero_vector = Geom::Vector2d.new(0, 0)
    assert(0, vector1.angle_between([0, 0]))
    assert(0, vector1.angle_between(zero_vector))
    assert(0, zero_vector.angle_between(vector1))
    assert(0, zero_vector.angle_between(zero_vector))
  end

  def test_angle_between_cw_ccw
    assert_equal_tol(1.3734007669450157, Y_AXIS_2D.angle_between([5, 1]))
    assert_equal_tol(1.3734007669450157, Y_AXIS_2D.angle_between([-5, 1]))
  end

  def test_angle_between_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.angle_between(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.angle_between('sketchup')
    end

    assert_raises(TypeError, 'Argument with number') do
      vector1.angle_between(1234)
    end

    assert_raises(ArgumentError, 'Argument with 2 arguments') do
      vector1.angle_between(vector2, vector2)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.angle_between()
    end
  end

  def test_clone
    vector1 = Geom::Vector2d.new(1, 2)
    cloned_vector1 = vector1.clone
    assert_equal(vector1, cloned_vector1)
    assert_kind_of(Geom::Vector2d, cloned_vector1)
    refute(vector1.object_id == cloned_vector1.object_id)
  end

  def test_clone_frozen
    cloned_vector = Y_AXIS_2D.clone
    assert_equal(Y_AXIS_2D, cloned_vector)
    assert_kind_of(Geom::Vector2d, cloned_vector)
    refute(Y_AXIS_2D.object_id == cloned_vector.object_id)
    refute(cloned_vector.frozen?)
  end

  def test_clone_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.clone(nil)
    end
  end

  def test_cross
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)
    expected = -3

    output = vector1.cross(vector2)
    assert_equal(expected, output)

    output = vector1.cross([4, 5])
    assert_equal(expected, output)
  end

  def test_cross_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with string') do
      vector1.cross('sketchup')
    end

    assert_raises(TypeError, 'Argument with nil') do
      vector1.cross(nil)
    end

    assert_raises(TypeError, 'Argument with number') do
      vector1.cross(1234)
    end

    assert_raises(TypeError, 'Argument with Point2d') do
      vector1.cross(ORIGIN_2D)
    end

    assert_raises(ArgumentError, 'too many arguments') do
      vector1.cross(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.cross
    end
  end

  def test_dot
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)

    output = vector1.dot(vector2)
    assert_equal(14, output)

    output = vector1.dot([4, 5])
    assert_equal(14, output)
  end

  def test_dot_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.dot(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.dot('sketchup')
    end

    assert_raises(TypeError, 'Argument with number') do
      vector1.dot(1234)
    end

    assert_raises(TypeError, 'Argument with Point2d') do
      vector1.dot(Geom::Point2d.new(4, 5))
    end

    assert_raises(ArgumentError, 'too many arguments') do
      vector1.dot(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.dot
    end
  end

  def test_initialize
    vector1 = Geom::Vector2d.new(1, 2)

    assert_equal(Geom::Vector2d.new(1, 2), vector1)
    assert_kind_of(Geom::Vector2d, vector1)

    vector2 = Geom::Vector2d.new(4, 5)
    vector1 = Geom::Vector2d.new(vector2)
    assert_equal(vector2, vector1)
    assert_kind_of(Geom::Vector2d, vector1)

    vector1 = Geom::Vector2d.new([1, 2])
    assert_equal(Geom::Vector2d.new(1, 2), vector1)
    assert_kind_of(Geom::Vector2d, vector1)

    vector1 = Geom::Vector2d.new(1.23, 2.34)
    assert_equal(1.23, vector1[0])
    assert_equal(2.34, vector1[1])
    assert_kind_of(Geom::Vector2d, vector1)

    vector1 = Geom::Vector2d.new(3.45.to_l, 1.23.to_l)
    assert_equal(3.45, vector1[0])
    assert_equal(1.23, vector1[1])
    assert_kind_of(Geom::Vector2d, vector1)
  end

  def test_initialize_invalid_arguments
    assert_raises(TypeError, 'Argument with nil') do
      vector1 = Geom::Vector2d.new(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1 = Geom::Vector2d.new('1, 2')
    end

    assert_raises(TypeError, 'Argument with 2 nils') do
      vector1 = Geom::Vector2d.new(nil, nil)
    end

    assert_raises(TypeError, 'Argument with 1 number') do
      vector1 = Geom::Vector2d.new(1)
    end

    assert_raises(ArgumentError, 'Argument with 3 numbers') do
      vector1 = Geom::Vector2d.new(1, 2, 3)
    end

    assert_raises(ArgumentError, 'Argument with array with size 3') do
      vector1 = Geom::Vector2d.new([1, 2, 3])
    end

    assert_raises(TypeError, 'Argument with Point2d') do
      vector1 = Geom::Vector2d.new(Geom::Point2d.new(1, 2))
    end
  end

  def test_initialize_empty_argument
    vector1 = Geom::Vector2d.new
    assert_equal(0, vector1.x)
    assert_equal(0, vector1.y)
    refute(vector1.valid?)
  end

  class CustomVector < Geom::Vector2d; end
  def test_initialize_subclassed
    # Making sure we created the objects correctly so it can be sub-classed.
    vec = CustomVector::new(12, 34)
    assert_kind_of(CustomVector, vec)
    assert_kind_of(Geom::Vector2d, vec)
  end

  def test_inspect
    vector1 = Geom::Vector2d.new(1, 2)
    assert_equal('Vector2d(1, 2)', vector1.inspect)
    vector1 = Geom::Vector2d.new(1.1234, 2.1234)
    assert_equal('Vector2d(1.1234, 2.1234)', vector1.inspect)
  end

  def test_inspect_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.inspect(nil)
    end
  end

  def test_length
    vector1 = Geom::Vector2d.new(3, 4)
    assert_equal(5, vector1.length)
    assert_kind_of(Length, vector1.length)
  end

  def test_length_invalid_arguments
    vector1 = Geom::Vector2d.new(3, 4)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.length(nil)
    end

    assert_raises(ArgumentError, 'Setting 0 Length') do
      vector1.length = 0
    end
  end

  def test_length_Set
    vector1 = Geom::Vector2d.new(3, 4)

    vector1.length = 10.to_l
    assert_equal(10, vector1.length)
    assert_equal(6, vector1[0])
    assert_equal(8, vector1[1])
    assert_kind_of(Length, vector1.length)
    vector1.length = 5.0
    assert_equal(5, vector1.length)
    assert_equal(3, vector1[0])
    assert_equal(4, vector1[1])
  end

  def test_length_Set_zero_vector
    vector1 = Geom::Vector2d.new(0, 0)
    assert_raises(ArgumentError, 'set length on zero length vector') do
      vector1.length = 1
    end
  end

  def test_length_Set_zero_length
    vector1 = Geom::Vector2d.new(1, 0)
    assert_raises(ArgumentError, 'set zero length on vector') do
      vector1.length = 0
    end
  end

  def test_length_Set_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      Y_AXIS_2D.length = 10
    end
  end

  def test_length_Set_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'setting with nil') do
      vector1.length = nil
    end

    assert_raises(TypeError, 'setting with string') do
      vector1.length = 'sketchup'
    end

    assert_raises(TypeError, 'setting with Array') do
      vector1.length = [1]
    end
  end

  def test_normalize
    vector1 = Geom::Vector2d.new(1, 2)
    expected = Geom::Vector2d.new(0.447214, 0.894427)
    vector2 = vector1.normalize
    assert_equal(expected, vector2)
    refute_equal(expected, vector1)
    assert(vector2.unit_vector?)
    refute(vector1.unit_vector?)
    assert_kind_of(Geom::Vector2d, vector2)
  end

  def test_normalize_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.normalize(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.normalize('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with numbers') do
      vector1.normalize(1234)
    end

    assert_raises(ArgumentError, 'Argument with Vector2d') do
      vector1.normalize(vector1)
    end
  end

  def test_normalize_Bang
    vector1 = Geom::Vector2d.new(1, 2)
    expected = Geom::Vector2d.new(0.447214, 0.894427)
    vector1.normalize!
    assert(vector1.unit_vector?)
    assert_equal(expected, vector1)
    assert_kind_of(Geom::Vector2d, vector1)
  end

  def test_normalize_Bang_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      Y_AXIS_2D.normalize!
    end
  end

  def test_normalize_Bang_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.normalize!(nil)
    end
  end

  def test_parallel_Query
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)
    refute(vector1.parallel?(vector2))

    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(2, 4)
    assert(vector1.parallel?(vector2))
  end

  def test_parallel_Query_with_tolerance
    vector1 = Geom::Vector2d.new(1.01, 2)
    vector2 = Geom::Vector2d.new(2, 4)
    refute(vector1.parallel?(vector2))

    vector1.set!(1, 2.01)
    vector2 = Geom::Vector2d.new(2, 4)
    refute(vector1.parallel?(vector2))
  end

  def test_parallel_Query_invalid_parameters
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(2, 4)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.parallel?(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.parallel?('sketchup')
    end

    assert_raises(TypeError, 'Argument with numbers') do
      vector1.parallel?(1234)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.parallel?
    end

    assert_raises(ArgumentError, "multiple arguments") do
      vector1.parallel?(vector2, vector2)
    end
  end

  def test_perpendicular_Query
    vector1 = Geom::Vector2d.new(0, 2)
    vector2 = Geom::Vector2d.new(-2, 0)
    assert(vector1.perpendicular?(vector2))

    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(2, -1)
    assert(vector1.perpendicular?(vector2))

    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(4, 5)
    refute(vector1.perpendicular?(vector2))
  end

  def test_perpendicular_Query_with_tolerance
    vector1 = Geom::Vector2d.new(0.01, 2)
    vector2 = Geom::Vector2d.new(-2, 0)
    refute(vector1.perpendicular?(vector2))

    vector1.set!(0, 2)
    vector2.set!(-2, 0.01)
    refute(vector1.perpendicular?(vector2))
  end

  def test_perpendicular_Query_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.perpendicular?(nil)
    end

    assert_raises(ArgumentError, 'multiple arguments') do
      vector1.perpendicular?(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.perpendicular?
    end
  end

  def test_reverse
    vector1 = Geom::Vector2d.new(1, 2)
    output = vector1.reverse
    assert_equal(Geom::Vector2d.new(-1, -2), output)
    refute(output == vector1)
    assert_equal(1, vector1[0])
    assert_equal(2, vector1[1])
    assert_kind_of(Geom::Vector2d, output)
  end

  def test_reverse_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.reverse(nil)
    end
  end

  def test_reverse_Bang
    vector1 = Geom::Vector2d.new(1, 2)
    vector1.reverse!
    assert_equal(Geom::Vector2d.new(-1, -2), vector1)
    assert_kind_of(Geom::Vector2d, vector1)
    assert_equal(Geom::Vector2d.new(1, 2), vector1.reverse!)
  end

  def test_reverse_Bang_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      Y_AXIS_2D.reverse!
    end
  end

  def test_reverse_Bang_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.reverse!(nil)
    end
  end

  def test_same_direction_Query
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(2, 4)
    assert(vector1.same_direction?(vector2))
    assert(vector1.same_direction?([2, 4]))

    vector2 = Geom::Vector2d.new(3, 4)
    refute(vector1.same_direction?(vector2))
  end

  def test_same_direction_Query_tolerance
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(2.01, 4.01)
    assert(vector1.same_direction?(vector2))

    # our tolerance seems to be =< 0.013
    vector2 = Geom::Vector2d.new(2.014, 4.014)
    refute(vector1.same_direction?(vector2))
  end

  def test_same_direction_Query_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.same_direction?(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.same_direction?('sketchup')
    end

    assert_raises(TypeError, 'Argument with numbers') do
      vector1.same_direction?(1234)
    end

    assert_raises(ArgumentError, 'too many arguments') do
      vector1.same_direction?(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.same_direction?
    end
  end

  def test_set_Bang
    vector1 = Geom::Vector2d.new(1, 2)

    vector1.set!([4, 5])
    assert(Geom::Vector2d.new(4, 5), vector1)
    assert_kind_of(Geom::Vector2d, vector1)

    vector2 = Geom::Vector2d.new(11, 12)
    vector1.set!(vector2)
    assert_equal(vector2, vector1)
    assert_kind_of(Geom::Vector2d, vector1)

    vector1.set!(89, 123)
    assert_equal(Geom::Vector2d.new(89, 123), vector1)
    assert_kind_of(Geom::Vector2d, vector1)

    vector1.set!(1.23, 2.34)
    assert_equal(Geom::Vector2d.new(1.23, 2.34), vector1)
    assert_kind_of(Geom::Vector2d, vector1)

    vector1.set!(4.56.to_l, 1.23.to_l)
    assert_equal(Geom::Vector2d.new(4.56, 1.23), vector1)
    assert_kind_of(Geom::Vector2d, vector1)
  end

  def test_set_Bang_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      Y_AXIS_2D.set!(2, 3)
    end
  end

  def test_set_Bang_too_many_arguments
    vector1 = Geom::Vector2d.new(1, 2)
    expected = Geom::Vector2d.new(7, 7)
    assert_raises(ArgumentError) do
      vector1.set!(7, 7, 1, 2)
    end
  end

  def test_set_Bang_too_many_arguments_vectors
    # Expected behavior was that it would error out but nothing is caught.
    # Current behavior is that it uses the first argument to set the vector.
    vector1 = Geom::Vector2d.new(1, 2)
    vector2 = Geom::Vector2d.new(101, 102)
    vector3 = Geom::Vector2d.new(301, 201)

    vector1.set!(vector2, vector3)
    assert_equal(vector2, vector1)
    refute_equal(vector3, vector1)
  end
  def test_set_Bang_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.set!(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.set!('sketchup')
    end

    assert_raises(TypeError, 'Argument with number') do
      vector1.set!(1234)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.set!
    end
  end

  def test_to_a
    vector1 = Geom::Vector2d.new(1, 2)
    assert_equal([1, 2], vector1.to_a)
    assert_kind_of(Array, vector1.to_a)
  end

  def test_to_a_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.to_a(nil)
    end
  end

  def test_to_s
    vector1 = Geom::Vector2d.new(1.1, 2.2)
    model = Sketchup.active_model

    model.options['UnitsOptions']['LengthFormat'] = Length::Architectural
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal('(1.1, 2.2)', vector1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Decimal
    assert_equal('(1.1, 2.2)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal('(1.1, 2.2)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Millimeter
    assert_equal('(1.1, 2.2)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Centimeter
    assert_equal('(1.1, 2.2)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Meter
    assert_equal('(1.1, 2.2)', vector1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Engineering
    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal('(1.1, 2.2)', vector1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Fractional
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal('(1.1, 2.2)', vector1.to_s)
  end

  def test_to_s_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.to_s(nil)
    end
  end

  def test_transform_scale_about_point
    # transformation for Vector2d does not apply translation
    # only scaling/rotating/reflecting/skewing
    vector1 = Geom::Vector2d.new(111, 222)
    point1 = Geom::Point2d.new(101, 102)
    transformation1 = Geom::Transformation2d.scaling(point1, 2)
    expected = Geom::Vector2d.new(222, 444)

    output = vector1.transform(transformation1)
    assert_equal(expected, output)
  end

  def test_transform_rotation_about_point
    vector1 = Geom::Vector2d.new(77, 88)
    point1 = Geom::Point2d.new(101, 102)
    transformation1 = Geom::Transformation2d.rotation(point1, 45.degrees)
    expected = Geom::Vector2d.new(-7.77817, 116.673)
    output = vector1.transform(transformation1)
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector2d, output)
  end

  def test_transform_flip
    vector1 = Geom::Vector2d.new(77, 88)
    transformation1 = Geom::Transformation2d.new([0, 1, 1, 0, 0, 0])
    expected = Geom::Vector2d.new(88, 77)
    assert_equal(expected, vector1.transform(transformation1))
  end

  def test_transform_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.transform(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.transform('sketchup')
    end

    transformation1 = Geom::Transformation2d.new
    assert_raises(ArgumentError, 'Argument with 2 transforms') do
      vector1.transform(transformation1, transformation1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.transform
    end
  end

  def test_transform_Bang
    vector1 = Geom::Vector2d.new(1, 2)
    point1 = Geom::Point2d.new(11, 22)
    transform = Geom::Transformation2d.scaling(point1, 2)
    expected = Geom::Vector2d.new(2, 4)

    output = vector1.transform!(transform)
    assert_equal(expected, output)
    assert_equal(expected, vector1)
    assert_kind_of(Geom::Vector2d, vector1)
  end

  def test_transform_Bang_flip
    transform1 = Geom::Transformation2d.new([0, 1, 1, 0, 0, 0])
    vector1 = Geom::Vector2d.new(77, 88)
    vector2 = vector1.clone
    expected = Geom::Vector2d.new(88, 77)
    vector1.transform!(transform1)
    assert_equal(expected, vector1)
    refute_equal(vector2, vector1)
    assert_equal(vector2, vector1.transform!(transform1))
  end

  def test_transform_Bang_frozen
    transform = Geom::Transformation2d.new
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      Y_AXIS_2D.transform!(transform)
    end
  end

  def test_transform_Bang_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.transform!(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.transform!('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with 2 transforms') do
      transformation1 = Geom::Transformation.scaling([1, 1], 2)
      vector1.transform!(transformation1, transformation1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.transform!
    end
  end

  def test_unit_vector_Query
    vector1 = Geom::Vector2d.new(1, 2)
    refute(vector1.unit_vector?)
    vector1.set!(0, 1)
    assert(vector1.unit_vector?)

    num = 1 / Math.sqrt(2)
    vector1.set!(num, -num)
    assert(vector1.unit_vector?)

    vector1 = Geom::Vector2d.new(0, 0)
    refute(vector1.unit_vector?)
  end

  def test_unit_vector_Query_with_tolerance
    num = 1 / Math.sqrt(2)
    vector1 = Geom::Vector2d.new(num + 0.01, -num)
    refute(vector1.unit_vector?)

    vector1.set!(num, -num + 0.01)
    refute(vector1.unit_vector?)

    vector1.set!(num - 0.01, -num)
    refute(vector1.unit_vector?)

    vector1.set!(num, -num - 0.01)
    refute(vector1.unit_vector?)
  end

  def test_unit_vector_Query_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.unit_vector?(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.unit_vector?('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with numbers') do
      vector1.unit_vector?(1234)
    end

    assert_raises(ArgumentError, 'Argument with Vector2d') do
      vector1.unit_vector?(vector1)
    end
  end

  def test_valid_Query
    vector1 = Geom::Vector2d.new(0, 0)
    refute(vector1.valid?)

    vector1.set!(1, 2)
    assert(vector1.valid?)

    vector1.set!(1, 2)
    vector1.length = 1.0e-10
    assert(vector1.valid?)

    vector1.set!(1, 2)
    vector1.length = 1.0e-9
    assert(vector1.valid?)
  end

  def test_valid_Query_invalid_arguments
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.valid?(nil)
    end
  end

  def test_x
    vector1 = Geom::Vector2d.new(1, 2)
    assert_equal(1, vector1.x)
    assert_kind_of(Float, vector1.x)
  end

  def test_x_Set
    vector1 = Geom::Vector2d.new(1, 2)
    vector1.x = 11
    assert_equal(11, vector1.x)

    vector1.x = 11.to_l
    assert_equal(11, vector1.x)

    vector1.x = 11.1
    assert_equal(11.1, vector1.x)
  end

  def test_x_Set_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      Y_AXIS_2D.x = 2
    end
  end

  def test_x_Set_invalid_types
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.x = nil
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.x = 'sketchup'
    end

    assert_raises(TypeError, 'Argument with Vector2d') do
      vector1.x = vector1
    end
  end

  def test_y
    vector1 = Geom::Vector2d.new(1, 2)
    assert_equal(2, vector1.y)
    assert_kind_of(Float, vector1.y)
  end

  def test_y_Set
    vector1 = Geom::Vector2d.new(1, 2)
    vector1.y = 22
    assert_equal(22, vector1.y)

    vector1.y = 22.to_l
    assert_equal(22, vector1.y)

    vector1.y = 22.2
    assert_equal(22.2, vector1.y)
  end

  def test_y_Set_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Vector2d') do
      Y_AXIS_2D.y = 2
    end
  end

  def test_y_Set_invalid_types
    vector1 = Geom::Vector2d.new(1, 2)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.y = nil
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.y = 'sketchup'
    end

    assert_raises(TypeError, 'Argument with Vector2d') do
      vector1.y = vector1
    end
  end
end

# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi


require "testup/testcase"


# class Geom::Vector3d
class TC_Geom_Vector3d < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

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
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(1, 2, 3)

    assert(vector1 == vector2, 'vector1 and vector2 are not equivalent')
  end

  def test_Operator_Equal_tolerance
    vector1 = Geom::Vector3d.new(1.0001, 2, 3)
    vector2 = Geom::Vector3d.new(1.0002, 2, 3)

    assert(vector1 == vector2, 'vector1 and vector2 are out of tolerance range')

    vector1 = Geom::Vector3d.new(1.001, 2, 3)
    vector2 = Geom::Vector3d.new(1.002, 2, 3)

    refute(vector1 == vector2, 'vector1 and vector2 should not be the same')
  end

  def test_Operator_Get
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_equal(1, vector1[0])
    assert_equal(2, vector1[1])
    assert_equal(3, vector1[2])
    assert_equal(1, vector1[-3])
    assert_equal(2, vector1[-2])
    assert_equal(3, vector1[-1])
  end

  def test_Operator_Get_index_out_of_range
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(IndexError, 'accessing index out of range') do
      vector1[4]
    end

    assert_raises(IndexError, 'accessing index out of range') do
      vector1[-4]
    end
  end

  def test_Operator_LessThan
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)

    assert(vector1 < vector2)
    assert(vector1 < [4, 5, 6])
    refute(vector2 < vector1)
  end

  def test_Operator_LessThan_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)
    point1 = Geom::Point3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Comparing against nil') do
      vector1 < nil
    end

    assert_raises(ArgumentError, 'Comparing against string') do
      vector1 < '3, 4, 5'
    end

    assert_raises(ArgumentError, 'Comparing against numbers') do
      vector1 < 1234
    end

    assert_raises(ArgumentError, 'Comparing against Vector3d') do
      vector1 < point1
    end
  end

  def test_Operator_Minus
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(7, 11, 13)
    expected = Geom::Vector3d.new(6, 9, 10)
    output = vector2 - vector1
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)

    output = vector2 - [1, 2, 3]
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)
  end

  def test_Operator_Minus_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'subtracting string from a Vector3d object') do
      vector1 - 'sketchup'
    end

    assert_raises(ArgumentError, 'subtracting nil from a Vector3d object') do
      vector1 - nil
    end

    assert_raises(ArgumentError, 'subtracting number from a Vector3d') do
      vector1 - 33
    end

    assert_raises(ArgumentError, 'subtracting Point3d from a Vector3d') do
      vector1 - Geom::Point3d.new(5, 6, 7)
    end
  end

  def test_Operator_Modulo
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)

    output = vector1 % vector2
    assert_equal(32, output)

    output = vector1 % [4, 5, 6]
    assert_equal(32, output)
  end

  def test_Operator_Modulo_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument witn nil') do
      vector1 % nil
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1 % 'sketchup'
    end

    assert_raises(ArgumentError, 'Argument with number') do
      vector1 % 1234
    end

    assert_raises(ArgumentError, 'Argument with Point3d') do
      vector1 % Geom::Point3d.new(4, 5, 6)
    end
  end

  def test_Operator_Multiply
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)
    expected = Geom::Vector3d.new(-3, 6, -3)
    output = vector1 * vector2
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)

    output = vector1 * [4, 5, 6]
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)
    assert_equal(Geom::Vector3d.new(0, 0, 0), vector1 * vector1)
  end

  def test_Operator_Multiply_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'multiplying with string') do
      vector1 * 'sketchup'
    end

    assert_raises(ArgumentError, 'multiplying with nil') do
      vector1 * nil
    end

    assert_raises(ArgumentError, 'multiplying with number') do
      vector1 * 1234
    end

    assert_raises(ArgumentError, 'multiplying with Point3d') do
      vector1 * Geom::Point3d.new(4, 5, 6)
    end
  end

  def test_Operator_Plus
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)

    expected = Geom::Vector3d.new(5, 7, 9)
    output = vector1 + vector2
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)

    output = vector1 + [4, 5, 6]
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)
  end

  def test_Operator_Plus_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'adding with string') do
      vector1 + 'sketchup'
    end

    assert_raises(ArgumentError, 'adding with nil') do
      vector1 + nil
    end

    assert_raises(ArgumentError, 'adding with number') do
      vector1 + 1234
    end

    assert_raises(ArgumentError, 'multiplying with Point3d') do
      vector1 + Geom::Point3d.new(4, 5, 6)
    end
  end

  def test_Operator_Set
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector1[0] = 4
    vector1[1] = 5
    vector1[2] = 6
    assert_equal(4, vector1[0])
    assert_equal(5, vector1[1])
    assert_equal(6, vector1[2])

    vector1[-3] = 7
    vector1[-2] = 8
    vector1[-1] = 9
    assert_equal(7, vector1[-3])
    assert_equal(8, vector1[-2])
    assert_equal(9, vector1[-1])
  end

  def test_Operator_Set_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(TypeError, 'set element with string') do
      vector1[0] = 'sketchup'
    end

    assert_raises(TypeError, 'set element with nil') do
      vector1[0] = nil
    end

    assert_raises(TypeError, 'set element with array') do
      vector1[0] = [1]
    end

    assert_raises(TypeError, 'set element with Point3d') do
      vector1[0] = Geom::Point3d.new(1, 2, 3)
    end
  end

  def test_angle_between
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)
    angle = vector1.angle_between(vector2)
    assert_equal(0.2257261285527342, angle)

    vector1.set!(-1, -1, -1)
    vector2.set!(1, 1, 1)
    angle = vector1.angle_between(vector2)
    assert_equal(Math::PI, angle)
    assert_kind_of(Float, angle)

    # testing possible zero length vectors
    zero_vector = Geom::Vector3d.new(0, 0 ,0)
    assert(0, vector1.angle_between([0, 0, 0]))
    assert(0, vector1.angle_between(zero_vector))
    assert(0, zero_vector.angle_between(vector1))
    assert(0, zero_vector.angle_between(zero_vector))
  end

  def test_angle_between_floating_point_precision
    vector1 = Geom::Vector3d.new(0.9274029224425325,
                                 0.37406354544062387,
                                 0.0005323696463050108)
    angle = vector1.angle_between(Z_AXIS)
    assert_equal_tol(1.5702639571234445, angle)
  end

  def test_angle_between_cw_ccw
    assert_equal_tol(1.3734007669450157, Y_AXIS.angle_between([5, 1, 0]))
    assert_equal_tol(1.3734007669450157, Y_AXIS.angle_between([-5, 1, 0]))
  end

  def test_angle_between_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.angle_between(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.angle_between('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with number') do
      vector1.angle_between(1234)
    end

    assert_raises(ArgumentError, 'Argument with 2 arguments') do
      vector1.angle_between(vector2, vector2)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.angle_between()
    end
  end

  def test_axes
    vector1 = Geom::Vector3d.new(1, 2, 3)
    axes = vector1.axes
    output_vec1 = Geom::Vector3d.new(-0.894427, 0.447214, 0)
    output_vec2 = Geom::Vector3d.new(-0.358569, -0.717137, 0.597614)
    output_vec3 = Geom::Vector3d.new(0.267261, 0.534522, 0.801784)
    expected = [output_vec1, output_vec2, output_vec3]

    assert_equal(expected, axes)
    assert_kind_of(Array, axes)
    assert(axes.all? { |axis| axis.is_a?(Geom::Vector3d) })
  end

  def test_axes_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.axes(nil)
    end
  end

  def test_clone
    vector1 = Geom::Vector3d.new(1, 2, 3)
    cloned_vector1 = vector1.clone
    assert_equal(vector1, cloned_vector1)
    assert_kind_of(Geom::Vector3d, cloned_vector1)
    refute(vector1.object_id == cloned_vector1.object_id)
  end

  def test_clone_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.clone(nil)
    end
  end

  def test_cross
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)
    expected = Geom::Vector3d.new(-3, 6, -3)

    output = vector1.cross(vector2)
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)

    output = vector1.cross([4, 5, 6])
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)
  end

  def test_cross_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.cross('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.cross(nil)
    end

    assert_raises(ArgumentError, 'Argument with number') do
      vector1.cross(1234)
    end

    assert_raises(ArgumentError, 'Argument with Point3d') do
      vector1.cross(ORIGIN)
    end

    assert_raises(ArgumentError, 'too many arguments') do
      vector1.cross(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.cross
    end
  end

  def test_dot
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)

    output = vector1.dot(vector2)
    assert_equal(32, output)

    output = vector1.dot([4, 5, 6])
    assert_equal(32, output)
  end

  def test_dot_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.dot(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.dot('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with number') do
      vector1.dot(1234)
    end

    assert_raises(ArgumentError, 'Argument with Point3d') do
      vector1.dot(Geom::Point3d.new(4, 5, 6))
    end

    assert_raises(ArgumentError, 'too many arguments') do
      vector1.dot(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.dot
    end
  end

  def test_initialize
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_equal(Geom::Vector3d.new(1, 2, 3), vector1)
    assert_kind_of(Geom::Vector3d, vector1)

    vector2 = Geom::Vector3d.new(4, 5, 6)
    vector1 = Geom::Vector3d.new(vector2)
    assert_equal(vector2, vector1)
    assert_kind_of(Geom::Vector3d, vector1)

    vector1 = Geom::Vector3d.new([1, 2, 3])
    assert_equal(Geom::Vector3d.new(1, 2, 3), vector1)
    assert_kind_of(Geom::Vector3d, vector1)
  end

  def test_initialize_invalid_arguments
    assert_raises(ArgumentError, 'Argument with nil') do
      vector1 = Geom::Vector3d.new(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1 = Geom::Vector3d.new('1, 2, 3')
    end

    assert_raises(TypeError, 'Argument with 3 nils') do
      vector1 = Geom::Vector3d.new(nil, nil, nil)
    end

    assert_raises(ArgumentError, 'Argument with 1 number') do
      vector1 = Geom::Vector3d.new(1)
    end

    assert_raises(ArgumentError, 'Argument with 4 numbers') do
      vector1 = Geom::Vector3d.new(1, 2, 3, 4)
    end

    assert_raises(ArgumentError, 'Argument with array with size 4') do
      vector1 = Geom::Vector3d.new([1, 2, 3, 4])
    end

    assert_raises(ArgumentError, 'Argument with Point3d') do
      vector1 = Geom::Vector3d.new(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_initialize_empty_argument
    vector1 = Geom::Vector3d.new
    assert_equal(0, vector1.x)
    assert_equal(0, vector1.y)
    assert_equal(0, vector1.z)
    refute(vector1.valid?)
  end

  class CustomVector < Geom::Vector3d; end
  def test_initialize_subclassed
    # Making sure we created the objects correctly so it can be sub-classed.
    CustomVector::new(12, 34, 56)
  end

  def test_inspect
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_equal('Vector3d(1, 2, 3)', vector1.inspect)
    vector1 = Geom::Vector3d.new(1.1234, 2.1234, 3.1234)
    assert_equal('Vector3d(1.1234, 2.1234, 3.1234)', vector1.inspect)
  end

  def test_inspect_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.inspect(nil)
    end
  end

  def test_length
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_equal(3.7416573867739413, vector1.length)
    assert_kind_of(Length, vector1.length)
  end

  def test_length_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.length(nil)
    end
  end

  def test_length_Set
    vector1 = Geom::Vector3d.new(1, 2, 3)

    vector1.length = 2.to_l
    assert_equal(2, vector1.length)
    assert_equal(0.5345224838248488, vector1[0])
    assert_equal(1.0690449676496976, vector1[1])
    assert_equal(1.6035674514745464, vector1[2])
    assert_kind_of(Length, vector1.length)
    vector1.length = 2.5
    assert_equal(2.5, vector1.length)
    assert_equal(0.6681531047810609, vector1[0])
    assert_equal(1.3363062095621219, vector1[1])
    assert_equal(2.004459314343183, vector1[2])
  end

  def test_length_Set_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

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

  def test_linear_combination
    vector1 = Geom::Vector3d.new(2, 4, 6)
    vector2 = Geom::Vector3d.new(8, 10, 12)
    expected = Geom::Vector3d.new(5, 7, 9)

    # linear_combination is (weight1 * vector1) + (weight2 * vector2)
    # 0.5 * [2, 4, 6] = [1, 2, 3] --> AxB matrix sort of stuff
    output = Geom::Vector3d.linear_combination(0.5, vector1, 0.5, vector2)
    assert_kind_of(Geom::Vector3d, output)
    assert_equal(expected, output)

    expected = Geom::Vector3d.new(95, 127, 159)
    output = Geom::Vector3d.linear_combination(5.5, vector1, 10.5, vector2)
    assert_kind_of(Geom::Vector3d, output)
    assert_equal(expected, output)

    expected = Geom::Vector3d.new(-102, -138, -174)
    output = Geom::Vector3d.linear_combination(-7, vector1, -11, vector2)
    assert_kind_of(Geom::Vector3d, output)
    assert_equal(expected, output)

    # another variant is x, xaxis, y, yaxis, z, zaxis
    vector1 = Geom::Vector3d.new(1, 0, 0)
    vector2 = Geom::Vector3d.new(0, 1, 0)
    vector3 = Geom::Vector3d.new(0, 0, 1)
    expected = Geom::Vector3d.new(-7, -11, 2.5)
    output = Geom::Vector3d.linear_combination(-7, vector1, -11, vector2,
                                               2.5, vector3)
    assert_kind_of(Geom::Vector3d, output)
    assert_equal(expected, output)
  end

  def test_linear_combination_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_raises(ArgumentError, "passing empty argument") do
      Geom::Vector3d.linear_combination
    end

    assert_raises(ArgumentError, "passing too many arguments") do
      Geom::Vector3d.linear_combination(2, vector1, 3, vector1, vector1)
    end

    assert_raises(TypeError, "Argument with nils") do
      Geom::Vector3d.linear_combination(nil, nil, nil, nil)
    end

    assert_raises(TypeError, "Argument with strings") do
      Geom::Vector3d.linear_combination("sk", "et", "ch", "up")
    end

    assert_raises(ArgumentError, "Argument with numbers") do
      Geom::Vector3d.linear_combination(1, 2, 3, 4)
    end

    assert_raises(TypeError, "Argument with arrays") do
      Geom::Vector3d.linear_combination([1], [2], [3], [4])
    end

    assert_raises(ArgumentError, "Argument with mixes") do
      Geom::Vector3d.linear_combination(2, [2], 'sketchup', nil)
    end
  end

  def test_normalize
    vector1 = Geom::Vector3d.new(1, 2, 3)
    expected = Geom::Vector3d.new(0.267261, 0.534522, 0.801784)
    vector1 = vector1.normalize
    assert_equal(expected, vector1)
    assert(vector1.unitvector?)
    assert_kind_of(Geom::Vector3d, vector1)
  end

  def test_normalize_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.normalize(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.normalize('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with numbers') do
      vector1.normalize(1234)
    end

    assert_raises(ArgumentError, 'Argument with Vector3d') do
      vector1.normalize(vector1)
    end
  end

  def test_normalize_Bang
    vector1 = Geom::Vector3d.new(1, 2, 3)
    expected = Geom::Vector3d.new(0.267261, 0.534522, 0.801784)
    vector1.normalize!
    assert(vector1.unitvector?)
    assert_equal(expected, vector1)
    assert_kind_of(Geom::Vector3d, vector1)
  end

  def test_normalize_Bang_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.normalize!(nil)
    end
  end

  def test_parallel_Query
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)
    refute(vector1.parallel?(vector2))

    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(2, 4, 6)
    assert(vector1.parallel?(vector2))
  end

  def test_parallel_Query_invalid_parameters
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(2, 4, 6)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.parallel?(nil)
    end

    vector3d_zero_length = Geom::Vector3d.new(0, 0, 0)
    assert_raises(ArgumentError, 'Argument with zero length vector3d') do
      vector1.parallel?(vector3d_zero_length)
    end

    assert_raises(ArgumentError, 'Testing with zero length vector3d') do
      vector3d_zero_length.parallel?(vector1)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.parallel?('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with numbers') do
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
    vector1 = Geom::Vector3d.new(0, 2, 3)
    vector2 = Geom::Vector3d.new(0, -3, 2)
    assert(vector1.perpendicular?(vector2))

    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(-8, -2, 4)
    assert(vector1.perpendicular?(vector2))

    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(4, 5, 6)
    refute(vector1.perpendicular?(vector2))
  end

  def test_perpendicular_Query_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.perpendicular?(nil)
    end

    vector3d_zero_length = Geom::Vector3d.new(0, 0, 0)
    assert_raises(ArgumentError, 'Argument with zero length vector3d') do
      vector1.perpendicular?(vector3d_zero_length)
    end

    assert_raises(ArgumentError, 'Testing with zero length vector3d') do
      vector3d_zero_length.perpendicular?(vector1)
    end

    assert_raises(ArgumentError, 'multiple arguments') do
      vector1.perpendicular?(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.perpendicular?
    end
  end

  def test_reverse
    vector1 = Geom::Vector3d.new(1, 2, 3)
    output = vector1.reverse
    assert_equal(Geom::Vector3d.new(-1, -2, -3), output)
    refute(output == vector1)
    assert_kind_of(Geom::Vector3d, output)
  end

  def test_reverse_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.reverse(nil)
    end
  end

  def test_reverse_Bang
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector1.reverse!
    assert_equal(Geom::Vector3d.new(-1, -2, -3), vector1)
    assert_kind_of(Geom::Vector3d, vector1)
    assert_equal(Geom::Vector3d.new(1, 2, 3), vector1.reverse!)
  end

  def test_reverse_Bang_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.reverse!(nil)
    end
  end

  def test_samedirection_Query
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(2, 4, 6)
    assert(vector1.samedirection?(vector2))
    assert(vector1.samedirection?([2, 4, 6]))

    vector2 = Geom::Vector3d.new(2, 4, -6)
    refute(vector1.samedirection?(vector2))
  end

  def test_samedirection_Query_tolerance
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(2.01, 4.01, 6.01)
    assert(vector1.samedirection?(vector2))

    # our tolerance seems to be =< 0.013
    vector2 = Geom::Vector3d.new(2.014, 4.014, 6.014)
    refute(vector1.samedirection?(vector2))
  end

  def test_samedirection_Query_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.samedirection?(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.samedirection?('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with numbers') do
      vector1.samedirection?(1234)
    end

    assert_raises(ArgumentError, 'too many arguments') do
      vector1.samedirection?(vector1, vector1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.samedirection?
    end
  end

  def test_set_Bang
    vector1 = Geom::Vector3d.new(1, 2, 3)

    vector1.set!([4, 5, 6])
    assert(Geom::Vector3d.new(4, 5, 6), vector1)
    assert_kind_of(Geom::Vector3d, vector1)

    vector2 = Geom::Vector3d.new(11, 12, 13)
    vector1.set!(vector2)
    assert_equal(vector2, vector1)
    assert_kind_of(Geom::Vector3d, vector1)

    vector1.set!(99)
    assert_equal(Geom::Vector3d.new(99, 12, 13), vector1)
    vector1.set!(89, 123)
    assert_equal(Geom::Vector3d.new(89, 123, 13), vector1)
    vector1.set!(90, 999, 4444)
    assert_equal(Geom::Vector3d.new(90, 999, 4444), vector1)
    assert_kind_of(Geom::Vector3d, vector1)
  end

  def test_set_Bang_too_many_arguments
    # This is actually supported, extra args are ignored
    vector1 = Geom::Vector3d.new(1, 2, 3)
    expected = Geom::Vector3d.new(7, 7, 7)
    vector1.set!(7, 7, 7, 0, 1, 2)
    assert_equal(expected, vector1)
  end

  def test_set_Bang_too_many_arguments_vectors
    # Expected behavior was that it would error out but nothing is caught.
    # Current behavior is that it uses the first argument to set the vector.
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector2 = Geom::Vector3d.new(101, 102, 103)
    vector3 = Geom::Vector3d.new(301, 201, 101)

    vector1.set!(vector2, vector3)
    assert_equal(vector2, vector1)
    refute_equal(vector3, vector1)
  end

  def test_set_Bang_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.set!(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.set!('sketchup')
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.set!
    end
  end

  def test_to_a
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_equal([1, 2, 3], vector1.to_a)
    assert_kind_of(Array, vector1.to_a)
  end

  def test_to_a_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.to_a(nil)
    end
  end

  def test_to_s
    vector1 = Geom::Vector3d.new(1.1, 2.2, 3.3)
    model = Sketchup.active_model

    model.options['UnitsOptions']['LengthFormat'] = Length::Architectural
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Decimal
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Millimeter
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Centimeter
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)

    model.options['UnitsOptions']['LengthUnit'] = Length::Meter
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Engineering
    model.options['UnitsOptions']['LengthUnit'] = Length::Feet
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)

    model.options['UnitsOptions']['LengthFormat'] = Length::Fractional
    model.options['UnitsOptions']['LengthUnit'] = Length::Inches
    assert_equal('(1.1, 2.2, 3.3)', vector1.to_s)
  end

  def test_to_s_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.to_s(nil)
    end
  end

  def test_transform
    # transformation for Vector3d does not apply translation
    # only scaling/rotating/reflecting/skewing
    vector1 = Geom::Vector3d.new(111, 222, 333)
    point1 = Geom::Point3d.new(101, 102, 103)
    transformation1 = Geom::Transformation.scaling(point1, 2)
    expected = Geom::Vector3d.new(222, 444, 666)

    output = vector1.transform(transformation1)
    assert_equal(expected, output)

    vector2 = Geom::Vector3d.new(77, 88, 99)
    transformation1 = Geom::Transformation.rotation(point1, vector2, 35)
    expected = Geom::Vector3d.new(260.445, 276.019, 168.748)
    output = vector1.transform(transformation1)
    assert_equal(expected, output)
    assert_kind_of(Geom::Vector3d, output)

    vector1.set!([77, 88, 99])
    transformation1 = Geom::Transformation.new(Y_AXIS, X_AXIS, Z_AXIS, ORIGIN)
    expected = Geom::Vector3d.new(88, 77, 99)
    assert_equal(expected, vector1.transform(transformation1))
  end

  def test_transform_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.transform(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.transform('sketchup')
    end

    transformation1 = Geom::Transformation.scaling([1, 1, 1], 2)
    assert_raises(ArgumentError, 'Argument with 2 transforms') do
      vector1.transform(transformation1, transformation1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.transform
    end
  end

  def test_transform_Bang
    vector1 = Geom::Vector3d.new(1, 2, 3)
    point1 = Geom::Point3d.new(11, 22, 33)
    transform = Geom::Transformation.scaling(point1, 2)
    expected = Geom::Vector3d.new(2, 4, 6)

    output = vector1.transform!(transform)
    assert_equal(expected, output)
    assert_equal(expected, vector1)
    assert_kind_of(Geom::Vector3d, vector1)

    transform1 = Geom::Transformation.new([0, 1, 0, 0,
                                          1, 0, 0, 0,
                                          0, 0, 1, 0,
                                          0, 0, 0, 1])
    vector2 = Geom::Vector3d.new(77, 88, 99)
    vector1.set!(vector2)
    expected.set!(88, 77, 99)
    vector1.transform!(transform1)
    assert_equal(expected, vector1)
    assert_equal(vector2, vector1.transform!(transform1))
  end

  def test_transform_Bang_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.transform!(nil)
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.transform!('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with 2 transforms') do
      transformation1 = Geom::Transformation.scaling([1, 1, 1], 2)
      vector1.transform!(transformation1, transformation1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      vector1.transform!
    end
  end

  def test_unitvector_Query
    vector1 = Geom::Vector3d.new(1, 2, 3)
    refute(vector1.unitvector?)
    vector1.set!(0, 0, 1)
    assert(vector1.unitvector?)

    num = 1 / Math.sqrt(2)
    vector1.set!(num, -num, 0)
    assert(vector1.unitvector?)

    vector1 = Geom::Vector3d.new(0, 0, 0)
    refute(vector1.unitvector?)
  end

  def test_unitvector_Query_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.unitvector?(nil)
    end

    assert_raises(ArgumentError, 'Argument with string') do
      vector1.unitvector?('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with numbers') do
      vector1.unitvector?(1234)
    end

    assert_raises(ArgumentError, 'Argument with Vector3d') do
      vector1.unitvector?(vector1)
    end
  end

  def test_valid_Query
    vector1 = Geom::Vector3d.new(0, 0, 0)
    refute(vector1.valid?)

    vector1.set!(1, 2, 3)
    assert(vector1.valid?)

    vector1.length = 0
    refute(vector1.valid?)

    vector1.set!(1, 2, 3)
    vector1.length = 1.0e-10
    refute(vector1.valid?)

    vector1.set!(1, 2, 3)
    vector1.length = 1.0e-9
    assert(vector1.valid?)
  end

  def test_valid_Query_invalid_arguments
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(ArgumentError, 'Argument with nil') do
      vector1.valid?(nil)
    end
  end

  def test_x
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_equal(1, vector1.x)
    assert_kind_of(Float, vector1.x)
  end

  def test_x_Set
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector1.x = 11
    assert_equal(11, vector1.x)

    vector1.x = 11.to_l
    assert_equal(11, vector1.x)

    vector1.x = 11.1
    assert_equal(11.1, vector1.x)
  end

  def test_x_Set_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.x = nil
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.x = 'sketchup'
    end

    assert_raises(TypeError, 'Argument with Vector3d') do
      vector1.x = vector1
    end
  end

  def test_y
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_equal(2, vector1.y)
  end

  def test_y_Set
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector1.y = 22
    assert_equal(22, vector1.y)

    vector1.y = 22.to_l
    assert_equal(22, vector1.y)

    vector1.y = 22.2
    assert_equal(22.2, vector1.y)
  end

  def test_y_Set_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.y = nil
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.y = 'sketchup'
    end

    assert_raises(TypeError, 'Argument with Vector3d') do
      vector1.y = vector1
    end
  end

  def test_z
    vector1 = Geom::Vector3d.new(1, 2, 3)
    assert_equal(3, vector1.z)
  end

  def test_z_Set
    vector1 = Geom::Vector3d.new(1, 2, 3)
    vector1.z = 33
    assert_equal(33, vector1.z)

    vector1.z = 33.to_l
    assert_equal(33, vector1.z)

    vector1.z = 33.3
    assert_equal(33.3, vector1.z)
  end

  def test_z_Set_invalid_types
    vector1 = Geom::Vector3d.new(1, 2, 3)

    assert_raises(TypeError, 'Argument with nil') do
      vector1.z = nil
    end

    assert_raises(TypeError, 'Argument with string') do
      vector1.z = 'sketchup'
    end

    assert_raises(TypeError, 'Argument with Vector3d') do
      vector1.z = vector1
    end
  end
end #class

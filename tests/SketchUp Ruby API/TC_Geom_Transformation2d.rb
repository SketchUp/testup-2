# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Adam Karkkainen

if Geom.const_defined? :Transformation2d

require "testup/testcase"
require_relative "utils/frozen"


# class Geom::Transformation2d
class TC_Geom_Transformation2d < TestUp::TestCase

  include TestUp::SketchUpTests::Frozen

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
  DivideByZeroTol = 1.0e-10

  def assert_matrix_equal(matrix1, matrix2)
    matrix1.each_with_index { |expected, index|
      assert_in_delta(expected, matrix2[index], DivideByZeroTol)
    }
  end


  def test_Operator_Multiply
    point1 = Geom::Point2d.new(1, 2)
    point2 = Geom::Point2d.new(4, 5)
    transform1 = Geom::Transformation2d.translation(point1)

    output = transform1 * point2
    expected = Geom::Point2d.new(5, 7)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point2d, output)

    output = transform1 * [4, 5]
    assert_equal(expected, output)
    assert_kind_of(Array, output)

    output = transform1 * Geom::Vector2d.new(4, 5)
    assert_equal(Geom::Vector2d.new(4, 5), output)
    assert_kind_of(Geom::Vector2d, output)

    transform2 = Geom::Transformation2d.translation(point2)
    expected2 = [1.0, 0.0,
                 0.0, 1.0,
                 5.0, 7.0]
    output = transform1 * transform2
    assert_equal(expected2, output.to_a)
    assert_kind_of(Geom::Transformation2d, output)
  end

  def test_Operator_Multiply_order_of_operation
    tr1 = Geom::Transformation2d.translation([2, 5])
    tr2 = Geom::Transformation2d.rotation(ORIGIN_2D, 30.degrees)
    result = tr1 * tr2
    expected = [0.8660253882408142, -0.5,
                0.5, 0.8660253882408142,
                2.0,  5.0]
    assert_matrix_equal(expected, result.to_a)
  end

  def test_Operator_Multiply_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)
    transform1 = Geom::Transformation2d.translation(point1)

    assert_raises(TypeError, 'Argument with nil') do
      transform1 * nil
    end

    assert_raises(TypeError, 'Argument with string') do
      transform1 * 'sketchup'
    end

    assert_raises(TypeError, 'Argument with numbers') do
      transform1 * 1234
    end

    assert_raises(TypeError, 'Argument with array of length 3') do
      transform1 * [1, 2, 3]
    end

    assert_raises(TypeError, 'Argument with array of length 7') do
      transform1 * [1, 2, 3, 4, 6, 7]
    end
  end

  def test_clone
    transformation = Geom::Transformation2d.new
    cloned = transformation.clone
    assert(cloned.to_a == transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
    refute_equal(transformation.object_id, cloned.object_id)
  end

  def test_clone_too_many_arguments
    transformation = Geom::Transformation2d.new
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation.clone(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation.clone(transformation)
    end
  end

  def test_identity_Query
    transformation = Geom::Transformation2d.new
    assert(transformation.identity?, "Geom::Transformation2d.new")

    transformation.set!(IDENTITY_2D)
    assert(transformation.identity?, "IDENTITY_2D")

    transformation.set!([1, 0, 0, 1, 0, 1])
    refute(transformation.identity?)
  end

  def test_identity_Query_too_many_arguments
    assert_raises(ArgumentError, 'Argument with nil') do
      IDENTITY_2D.identity?(nil)
    end

    assert_raises(ArgumentError, 'Argument with identity matrix') do
      IDENTITY_2D.identity?(IDENTITY_2D)
    end
  end

  def test_initialize_transformation
    transformation = Geom::Transformation2d.new
    assert_equal(IDENTITY_2D.to_a, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
  end

  def test_initialize_array
    matrix1 = [1, 0, 0, 1, 0, 0]
    transformation = Geom::Transformation2d.new(matrix1)
    assert_equal(matrix1, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)

    matrix1 = [2.0, 0.5, 0.5, 2.0, 1.0, 1.0]
    transformation = Geom::Transformation2d.new(matrix1)
    assert_equal(matrix1, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
  end

  def test_initialize_scale
    transformation = Geom::Transformation2d.scaling(5)
    matrix3 = [5, 0, 0, 5, 0, 0]
    assert_equal(matrix3, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)

    transformation = Geom::Transformation2d.scaling(2.5)
    matrix3 = [2.5, 0, 0, 2.5, 0, 0]
    assert_equal(matrix3, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
  end

  def test_initialize_invalid_arguments
    assert_raises(TypeError, 'Argument with number') do
      Geom::Transformation2d.new(1234)
    end

    assert_raises(TypeError, 'Argument with string') do
      Geom::Transformation2d.new('sketchup')
    end
  end

  class CustomTransformation < Geom::Transformation2d; end
  def test_initialize_subclassed
    # Making sure we created the objects correctly so it can be sub-classed.
    transform = CustomTransformation::new
    assert_kind_of(CustomTransformation, transform)
    assert_kind_of(Geom::Transformation2d, transform)
  end

  def test_inverse
    point1 = Geom::Point2d.new(11, 22)
    transformation1 = Geom::Transformation2d.translation(point1)
    expected = Geom::Transformation2d.translation(Geom::Point2d.new(-11, -22))
    output = transformation1.inverse
    assert_equal(expected.to_a, output.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1.inverse)
    refute_equal(transformation1.to_a, output.to_a)

    transformation2 = Geom::Transformation2d.rotation(ORIGIN_2D, 30.degrees)
    matrix = [0.8660253882408142, 0.5,
              -0.5, 0.8660253882408142,
              0.0, 0.0]
    output = transformation2.inverse
    assert_matrix_equal(matrix, output.to_a)
    assert_kind_of(Geom::Transformation2d, transformation2)
    refute_equal(transformation2.to_a, output.to_a)
  end

  def test_inverse_too_many_arguments
    point1 = Geom::Point2d.new(11, 22)
    transformation1 = Geom::Transformation2d.translation(point1)
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation1.inverse(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation1.inverse(transformation1)
    end
  end

  def test_invert_Bang
    point1 = Geom::Point2d.new(11, 22)
    transformation1 = Geom::Transformation2d.translation(point1)
    expected = Geom::Transformation2d.translation(Geom::Point2d.new(-11, -22))
    assert_equal(expected.to_a, transformation1.invert!.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1.invert!)
  end

  def test_invert_Bang_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Transformation2d') do
      IDENTITY_2D.invert!
    end
  end

  def test_invert_Bang_invalid_arguments
    point1 = Geom::Point2d.new(11, 22)
    transformation1 = Geom::Transformation2d.translation(point1)
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation1.invert!(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation1.invert!(transformation1)
    end
  end

  def test_rotation
    point1 = Geom::Point2d.new(11, 22)
    angle = 45.degrees
    transformation1 = Geom::Transformation2d.rotation(point1, angle)
    expected = [0.7071067690849304, -0.7071067690849304,
                0.7071067690849304, 0.7071067690849304,
                18.778175354003906, -1.3345222473144531]
    assert_matrix_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1)
  end

  def test_rotation_invalid_arguments
    point1 = Geom::Point2d.new(11, 22)
    vector1 = Geom::Vector2d.new(1, 1)
    angle = 45.degrees
    assert_raises(ArgumentError, 'Argument with nil') do
      Geom::Transformation2d.rotation(nil)
    end

    assert_raises(TypeError, 'Argument with nils') do
      Geom::Transformation2d.rotation(nil, nil)
    end

    assert_raises(TypeError, 'Argument with first valid and second invalid') do
      Geom::Transformation2d.rotation(point1, 'sketchup')
    end

    assert_raises(TypeError, 'Argument with second valid and first invalid') do
      Geom::Transformation2d.rotation('sketchup', angle)
    end

    assert_raises(ArgumentError, 'Arugment with one extra argument') do
      Geom::Transformation2d.rotation(point1, angle, 'food please')
    end

    assert_raises(TypeError, 'Argument with vector3s') do
      Geom::Transformation2d.rotation(vector1, angle)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation2d.rotation
    end
  end

  def test_scaling_point_and_uniform_scale
    point = Geom::Point2d.new(1, 2)
    transformation = Geom::Transformation2d.scaling(point, 10)
    expected = [10.0,   0.0,
                 0.0,  10.0,
                -9.0, -18.0]
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
  end

  def test_scaling_uniform_scale
    transformation = Geom::Transformation2d.scaling(10)
    expected = [10.0,  0.0,
                 0.0, 10.0,
                 0.0,  0.0]
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
  end

  def test_scaling_non_uniform_scale
    transformation = Geom::Transformation2d.scaling(10, 20)
    expected = [10.0,  0.0,
                 0.0, 20.0,
                 0.0,  0.0]
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
  end

  def test_scaling_point_and_non_uniform_scale
    point = Geom::Point2d.new(1, 2)
    transformation = Geom::Transformation2d.scaling(point, 10, 20)
    expected = [10.0,   0.0,
                 0.0,  20.0,
                -9.0, -38.0]
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation2d, transformation)
  end

  def test_scaling_invalid_arguments
    point1 = Geom::Point2d.new(1, 2)
    assert_raises(TypeError, 'Argument with nil') do
      Geom::Transformation2d.scaling(nil)
    end

    assert_raises(TypeError, 'Argument with nils') do
      Geom::Transformation2d.scaling(nil, nil)
    end

    assert_raises(TypeError, 'Argument with vector2d') do
      vec1 = Geom::Vector2d.new(1, 2)
      Geom::Transformation2d.scaling(vec1, 4, 5)
    end

    assert_raises(TypeError, 'Argumet with 1 valid and 2 invalid') do
      Geom::Transformation2d.scaling(point1, 'sketchup', 'ketchup')
    end

    assert_raises(TypeError, 'Argument with 2 valid and 1 invalid') do
      Geom::Transformation2d.scaling(point1, 10, '30')
    end

    assert_raises(ArgumentError, 'too many arguments') do
      Geom::Transformation2d.scaling(point1, 10, 20, 30)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation2d.scaling
    end
  end

  def test_set_Bang_transformation
    transformation1 = Geom::Transformation2d.translation(Geom::Point2d.new(1, 2))
    transformation2 = Geom::Transformation2d.new
    refute_equal(transformation2.to_a, transformation1.to_a)
    transformation2.set!(transformation1)
    assert_equal(transformation1.to_a, transformation2.to_a)
    assert_kind_of(Geom::Transformation2d, transformation2)
  end

  def test_set_Bang_array
    transformation1 = Geom::Transformation2d.new
    matrix = [1.0, 2.0,
              3.0, 4.0,
              5.0, 6.0]
    refute_equal(transformation1.to_a, matrix)
    transformation1.set!(matrix)
    assert_equal(matrix, transformation1.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1)
  end

  def test_set_Bang_scale
    transformation1 = Geom::Transformation2d.new
    scale_transformation = Geom::Transformation2d.scaling(11)
    refute_equal(scale_transformation.to_a, transformation1.to_a)
    transformation1.set!(scale_transformation)
    assert_equal(scale_transformation.to_a, transformation1.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1)
  end

  def test_set_Bang_frozen
    assert_raises(FROZEN_ERROR, 'set frozen Geom::Transformation2d') do
      IDENTITY_2D.set!([0, 1, 1, 0, 1, 1])
    end
  end

  def test_set_Bang_invalid_arguments
    transformation1 = Geom::Transformation2d.new

    assert_raises(TypeError, 'Argument with nil') do
      transformation1.set!(nil)
    end

    assert_raises(TypeError, 'Argument with array size of 1') do
      transformation1.set!([1])
    end

    assert_raises(TypeError, 'Argument with array size of 5') do
      transformation1.set!([1, 2, 3, 4, 5])
    end

    assert_raises(ArgumentError, 'too many arguments') do
      transformation1.set!(Geom::Vector2d.new(1, 2), ORIGIN_2D)
    end

    assert_raises(ArgumentError, 'empty argument') do
      transformation1.set!
    end
  end

  def test_to_a
    transformation1 = Geom::Transformation2d.new
    assert_equal(IDENTITY_2D.to_a, transformation1.to_a)
    assert_kind_of(Array, transformation1.to_a)
  end

  def test_to_a_too_many_arguments
    transformation1 = Geom::Transformation2d.new

    assert_raises(ArgumentError, 'Argument with nil') do
      transformation1.to_a(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation1.to_a(IDENTITY_2D)
    end
  end

  def test_translation
    point1 = Geom::Point2d.new(1, 2)
    vector1 = Geom::Vector2d.new(4, 5)

    transformation1 = Geom::Transformation2d.translation(point1)
    expected = [1.0, 0.0,
                0.0, 1.0,
                1.0, 2.0,]
    assert_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1)

    transformation1 = Geom::Transformation2d.translation(vector1)
    expected = [1.0, 0.0,
                0.0, 1.0,
                4.0, 5.0]
    assert_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1)

    transformation1 = Geom::Transformation2d.translation([2, 3])
    expected = [1.0, 0.0,
                0.0, 1.0,
                2.0, 3.0]
    assert_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation2d, transformation1)
  end

  def test_translation_invalid_arguments
    assert_raises(TypeError, 'Argument with nil') do
      Geom::Transformation2d.translation(nil)
    end

    assert_raises(TypeError, 'Argument with number') do
      Geom::Transformation2d.translation(1234)
    end

    assert_raises(ArgumentError, 'too many arguments') do
      Geom::Transformation2d.translation(ORIGIN_2D, ORIGIN_2D)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation2d.translation
    end

    assert_raises(ArgumentError, 'Argument with array with length 1') do
      Geom::Transformation2d.translation([1])
    end

    matrix = [1, 2, 3, 4, 5, 6, 7]
    assert_raises(ArgumentError, 'Argument with array with legth 7') do
      Geom::Transformation2d.translation(matrix)
    end
  end
end

end # if Geom.const_defined? :Transformation2d

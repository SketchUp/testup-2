# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi


require "testup/testcase"


# class Geom::Transformation
class TC_Geom_Transformation < TestUp::TestCase

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
    point1 = Geom::Point3d.new(1, 2, 3)
    point2 = Geom::Point3d.new(4, 5, 6)
    transform1 = Geom::Transformation.new(point1)

    output = transform1 * point2
    expected = Geom::Point3d.new(5, 7, 9)
    assert_equal(expected, output)
    assert_kind_of(Geom::Point3d, output)

    output = transform1 * [4, 5, 6]
    assert_equal(expected, output)
    assert_kind_of(Array, output)

    output = transform1 * Geom::Vector3d.new(4, 5, 6)
    assert_equal(Geom::Vector3d.new(4, 5, 6), output)
    assert_kind_of(Geom::Vector3d, output)

    transform2 = Geom::Transformation.new(point2)
    expected2 = [1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                5.0, 7.0, 9.0, 1.0]
    output = transform1 * transform2
    assert_equal(expected2, output.to_a)
    assert_kind_of(Geom::Transformation, output)

    # Transform * Plane3d
    output = transform1 * [[1, 2, 3], [0, 0, 1]]
    expected3 = [0, 0, 1, -6]
    assert_equal(expected3, output)
    assert_kind_of(Array, output)
  end

  def test_Operator_Multiply_order_of_operation
    tr1 = Geom::Transformation.translation([2,5,8])
    tr2 = Geom::Transformation.rotation(ORIGIN, Z_AXIS, 30.degrees)
    result = tr1 * tr2
    expected = [
      0.8660254037844386, 0.5, 0.0, 0.0,
      -0.5, 0.8660254037844386, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      2.0, 5.0, 8.0, 1.0
    ]
    assert_matrix_equal(expected, result.to_a)
  end

  def test_Operator_Multiply_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    transform1 = Geom::Transformation.new(point1)

    assert_raises(ArgumentError, 'Argument with nil') do
      transform1 * nil
    end

    assert_raises(ArgumentError, 'Argument with string') do
      transform1 * 'sketchup'
    end

    assert_raises(ArgumentError, 'Argument with numbers') do
      transform1 * 1234
    end

    assert_raises(ArgumentError, 'Argument with array of length 2') do
      transform1 * [1, 2]
    end

    assert_raises(ArgumentError, 'Argument with array of length 17') do
      transform1 * [1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    end
  end

  def test_axes
    transform1 = Geom::Transformation.axes(ORIGIN, X_AXIS, Z_AXIS,
        Y_AXIS.reverse)
    expected = [1.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                -0.0, -1.0, -0.0, 0.0,
                0.0, 0.0, 0.0, 1.0]
    assert_equal(expected, transform1.to_a)
    assert_kind_of(Geom::Transformation, transform1)
  end

  def test_axes_invalid_arguments
    assert_raises(ArgumentError, 'Argument with nil') do
      Geom::Transformation.axes(nil)
    end

    assert_raises(ArgumentError, 'Argument with nils') do
      Geom::Transformation.axes(nil, nil, nil, nil)
    end

    vec1 = Geom::Vector3d.new(1, 2, 3)
    vec2 = Geom::Vector3d.new(0, 0, 0)
    assert_raises(ArgumentError, 'Argument with Vector3d length zero') do
      Geom::Transformation.axes(ORIGIN, vec1, vec1, vec2)
    end

    assert_raises(ArgumentError, 'Argument with 1 valid and 3 invalid') do
      Geom::Transformation.axes(ORIGIN, 1, 2, 3)
    end

    assert_raises(ArgumentError, 'Argument with 3 valid and 1 invalid') do
      Geom::Transformation.axes(ORIGIN, X_AXIS, Y_AXIS, 'sketchup')
    end

    assert_raises(ArgumentError, 'Argument with a string') do
      Geom::Transformation.axes('sketchup')
    end

    assert_raises(ArgumentError, 'Argument with a number') do
      Geom::Transformation.axes(1234)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation.axes
    end
  end

  def test_axes_too_many_arguments
    # Documentation says it will take either 3 or 4 args. This does not raise
    # an error. However, if this were to be implemented in 2017, we would
    # not allow this type of behavior and raised an error.
    Geom::Transformation.axes(ORIGIN, X_AXIS, Z_AXIS, Y_AXIS.reverse, Y_AXIS)
  end

  def test_clone
    transformation = Geom::Transformation.new(ORIGIN)
    cloned = transformation.clone
    assert(cloned.to_a == transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
    refute_equal(transformation.object_id, cloned.object_id)
  end

  def test_clone_too_many_arguments
    transformation = Geom::Transformation.new(ORIGIN)
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation.clone(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation.clone(transformation)
    end
  end

  def test_identity_Query
    transformation = Geom::Transformation.new(ORIGIN)
    if Sketchup.version.to_i < 18
      # Originally this method returned true only for transformations created
      # as identity transformation via the CTransformation class.
      # It would not check the actual values of the transformation but use a
      # special flag set internally.
      refute(transformation.identity?, "Geom::Transformation.new(ORIGIN)")
    else
      # In SU2018 we refactored Geom::Transformation to wrap the C API's
      # SUTransformation instead. This did not preserve the special flags.
      # Instead this method now checks the values of the transformation to
      # determine if it's an identity matrix.
      assert(transformation.identity?, "Geom::Transformation.new(ORIGIN)")
    end

    transformation.set!(IDENTITY)
    assert(transformation.identity?, "IDENTITY")
  end

  def test_identity_Query_too_many_arguments
    assert_raises(ArgumentError, 'Argument with nil') do
      IDENTITY.identity?(nil)
    end

    assert_raises(ArgumentError, 'Argument with identity matrix') do
      IDENTITY.identity?(IDENTITY)
    end
  end

  def test_initialize_point3d
    transformation = Geom::Transformation.new(ORIGIN)
    matrix1 = [1, 0, 0, 0,
              0, 1, 0, 0,
              0, 0, 1, 0,
              0, 0, 0, 1]
    assert_equal(matrix1, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_vector3d
    transformation = Geom::Transformation.new(Geom::Vector3d.new(1, 1, 1))
    matrix2 = [1, 0, 0, 0,
              0, 1, 0, 0,
              0, 0, 1, 0,
              1, 1, 1, 1]
    assert_equal(matrix2, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_transformation
    transformation = Geom::Transformation.new(IDENTITY)
    assert_equal(IDENTITY.to_a, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_array
    matrix1 = [1, 0, 0, 0,
              0, 1, 0, 0,
              0, 0, 1, 0,
              0, 0, 0, 1]
    transformation = Geom::Transformation.new(matrix1)
    assert_equal(matrix1, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_scale
    transformation = Geom::Transformation.new(5)
    if Sketchup.version.to_i < 18
      # Originally this constructor set the w value of the transformation.
      # This caused problems in SU as well as many extensions.
      matrix3 = [1, 0, 0, 0,
                 0, 1, 0, 0,
                 0, 0, 1, 0,
                 0, 0, 0, 0.2]
    else
      # As of SU2018 the constructor scales the components of the matrix.
      matrix3 = [5, 0, 0, 0,
                 0, 5, 0, 0,
                 0, 0, 5, 0,
                 0, 0, 0, 1]
    end
    assert_equal(matrix3, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_origin_zaxis
    matrix1 = [1, 0, 0, 0,
              0, 1, 0, 0,
              0, 0, 1, 0,
              0, 0, 0, 1]
    transformation = Geom::Transformation.new(ORIGIN, Z_AXIS)
    assert_equal(matrix1, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_origin_xaxis_yaxis
    matrix1 = [1, 0, 0, 0,
              0, 1, 0, 0,
              0, 0, 1, 0,
              0, 0, 0, 1]
    transformation = Geom::Transformation.new(ORIGIN, X_AXIS, Y_AXIS)
    assert_equal(matrix1, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_origin_xaxis_radians
    transformation = Geom::Transformation.new(ORIGIN, X_AXIS, 30.degrees)
    matrix4 = [1.0, 0.0, 0.0, 0.0,
              0.0, 0.8660254037844386, 0.5, 0.0,
              0.0, -0.5, 0.8660254037844386, 0.0,
              0.0, 0.0, 0.0, 1.0]
    assert_equal(matrix4, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_xaxis_yaxis_zaxis_origin
    transformation = Geom::Transformation.new(ORIGIN, X_AXIS, 30.degrees)
    matrix4 = [1.0, 0.0, 0.0, 0.0,
              0.0, 0.8660254037844386, 0.5, 0.0,
              0.0, -0.5, 0.8660254037844386, 0.0,
              0.0, 0.0, 0.0, 1.0]
    assert_equal(matrix4, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_initialize_invalid_arguments
    assert_raises(TypeError, 'Argument with nil') do
      Geom::Transformation.new(nil)
    end

    assert_raises(ArgumentError, 'Argument with nils') do
      Geom::Transformation.new(nil, nil, nil, nil)
    end

    assert_raises(ArgumentError, 'Argument with 1 valid and 3 invalid') do
      Geom::Transformation.new(ORIGIN, 1, 2, 3)
    end

    assert_raises(ArgumentError, 'Argument with 3 valid and 1 invalid') do
      Geom::Transformation.new(ORIGIN, X_AXIS, Y_AXIS, 'sketchup')
    end

    assert_raises(TypeError, 'Argument with string') do
      Geom::Transformation.new('sketchup')
    end
  end

  class CustomTransformation < Geom::Transformation; end
  def test_initialize_subclassed
    # Making sure we created the objects correctly so it can be sub-classed.
    CustomTransformation::new
  end

  def test_interpolate
    origin = Geom::Point3d.new(0, 0, 0)
    x = Geom::Vector3d.new(0, 1, 0)
    y = Geom::Vector3d.new(1, 0, 0)
    z = Geom::Vector3d.new(0, 0, 1)
    point = Geom::Point3d.new(10, 20, 30)
    t1 = Geom::Transformation.new(point)
    t2 = Geom::Transformation.axes(origin, x, y, z)
    # This produce a transformation that is a mix of 75% t1 and 25% t2.
    t3 = Geom::Transformation.interpolate(t1, t2, 0.25)
    expected = [1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                7.5, 15.0, 22.5, 1.0]
    assert_equal(expected, t3.to_a)
    assert_kind_of(Geom::Transformation, t3)
  end

  def test_interpolate_invalid_arguments
    transformation1 = Geom::Transformation.new(ORIGIN)

    assert_raises(ArgumentError, 'Argument with nil') do
      Geom::Transformation.interpolate(nil)
    end

    assert_raises(TypeError, 'Argument with 1 valid and 2 invalid') do
      Geom::Transformation.interpolate(transformation1, 'sketchup', 'ketchup')
    end

    assert_raises(TypeError, 'Argument with 2 valid and 1 invalid') do
      Geom::Transformation.interpolate(transformation1, transformation1, 'what')
    end

    assert_raises(ArgumentError, 'Argument with 3 valid and 1 extra arg') do
      Geom::Transformation.interpolate(transformation1, transformation1, 1, 1)
    end

    assert_raises(TypeError, 'Argument with weight as string') do
      Geom::Transformation.interpolate(transformation1, transformation1, '1234')
    end

    assert_raises(TypeError, 'Argument with weight as transformation') do
      Geom::Transformation.interpolate(transformation1, transformation1,
          transformation1)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation.interpolate
    end
  end

  def test_interpolate_weight_out_of_range
    transformation1 = Geom::Transformation.new(ORIGIN)
    begin
      Geom::Transformation.interpolate(transformation1, transformation1, 1.1)
      Geom::Transformation.interpolate(transformation1, transformation1, -1)
    rescue
      assert(false, 'FAILURE: test_interpolate_weight_out_of_range')
    end
  end

  def test_inverse
    point1 = Geom::Point3d.new(11, 22, 33)
    transformation1 = Geom::Transformation.new(point1)
    expected = Geom::Transformation.new(Geom::Point3d.new(-11, -22, -33))
    assert_equal(expected.to_a, transformation1.inverse.to_a)
    assert_kind_of(Geom::Transformation, transformation1.inverse)

    transformation2 = Geom::Transformation.new(ORIGIN, X_AXIS, 30.degrees)
    matrix = [1.0, 0.0, 0.0, 0.0,
              0.0, 0.8660254037844387, -0.5000000000000001, 0.0,
              0.0, 0.5000000000000001, 0.8660254037844387, 0.0,
              0.0, 0.0, 0.0, 1.0]
    assert_matrix_equal(matrix, transformation2.inverse.to_a)
    assert_kind_of(Geom::Transformation, transformation2)
  end

  def test_inverse_too_many_arguments
    point1 = Geom::Point3d.new(11, 22, 33)
    transformation1 = Geom::Transformation.new(point1)
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation1.inverse(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation1.inverse(transformation1)
    end
  end

  def test_invert_Bang
    point1 = Geom::Point3d.new(11, 22, 33)
    transformation1 = Geom::Transformation.new(point1)
    expected = Geom::Transformation.new(Geom::Point3d.new(-11, -22, -33))
    assert_equal(expected.to_a, transformation1.invert!.to_a)
    assert_kind_of(Geom::Transformation, transformation1.invert!)
  end

  def test_invert_Bang_invalid_arguments
    point1 = Geom::Point3d.new(11, 22, 33)
    transformation1 = Geom::Transformation.new(point1)
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation1.invert!(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation1.invert!(transformation1)
    end
  end

  def test_origin
    point1 = Geom::Point3d.new(10, 20, 30)
    transformation1 = Geom::Transformation.new(point1)
    assert_equal(point1, transformation1.origin)
    assert_kind_of(Geom::Point3d, transformation1.origin)
  end

  def test_origin_too_many_arguments
    point1 = Geom::Point3d.new(10, 20, 30)
    transformation1 = Geom::Transformation.new(point1)

    assert_raises(ArgumentError, 'Argument with nil') do
      transformation1.origin(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation1.origin(transformation1)
    end
  end

  def test_rotation
    point1 = Geom::Point3d.new(11, 22, 33)
    vector1 = Geom::Vector3d.new(1, 1, 1)
    angle = 45.degrees
    transformation1 = Geom::Transformation.rotation(point1, vector1, angle)
    expected = [0.8047378541243649, 0.5058793634016807, -0.31061721752604565, 0,
                -0.31061721752604565, 0.8047378541243649, 0.5058793634016807, 0,
                0.5058793634016807, -0.31061721752604565, 0.8047378541243649, 0,
                -7.712556602050476, 8.98146239020499, -1.2689057881545196, 1]
    assert_matrix_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)
  end

  def test_rotation_invalid_arguments
    point1 = Geom::Point3d.new(11, 22, 33)
    vector1 = Geom::Vector3d.new(1, 1, 1)
    angle = 45.degrees
    assert_raises(ArgumentError, 'Argument with nil') do
      Geom::Transformation.rotation(nil)
    end

    assert_raises(ArgumentError, 'Argument with nils') do
      Geom::Transformation.rotation(nil, nil, nil)
    end

    assert_raises(ArgumentError, 'Argument with 1 valid and 2 invalid') do
      Geom::Transformation.rotation(point1, 'sketchup', 'ketchup')
    end

    assert_raises(TypeError, 'Argument with 2 valid and 1 invalid') do
      Geom::Transformation.rotation(point1, vector1, 'sketchup')
    end

    assert_raises(ArgumentError, 'Arugment with one extra argument') do
      Geom::Transformation.rotation(point1, vector1, angle, 'food please')
    end

    assert_raises(ArgumentError, 'Argument with point3ds') do
      Geom::Transformation.rotation(point1, point1, angle)
    end

    assert_raises(ArgumentError, 'Argument with vector3ds') do
      Geom::Transformation.rotation(vector1, vector1, angle)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation.rotation
    end

    assert_raises(ArgumentError, 'Too many arguments') do
      Geom::Transformation.rotation(point1, vector1, angle, nil)
    end
  end

  def test_scaling_point_and_uniform_scale
    point = Geom::Point3d.new(1, 2, 3)
    transformation = Geom::Transformation.scaling(point, 10)
    if Sketchup.version.to_i < 18
      # Originally this constructor set the w value of the transformation.
      # This caused problems in SU as well as many extensions.
      expected = [ 1.0,  0.0,  0.0, 0.0,
                   0.0,  1.0,  0.0, 0.0,
                   0.0,  0.0,  1.0, 0.0,
                  -0.9, -1.8, -2.7, 0.1]
    else
      # As of SU2018 the constructor scales the components of the matrix.
      expected = [10.0,   0.0,   0.0, 0.0,
                   0.0,  10.0,   0.0, 0.0,
                   0.0,   0.0,  10.0, 0.0,
                  -9.0, -18.0, -27.0, 1.0]
    end
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_scaling_uniform_scale
    transformation = Geom::Transformation.scaling(10)
    if Sketchup.version.to_i < 18
      # Originally this constructor set the w value of the transformation.
      # This caused problems in SU as well as many extensions.
      expected = [1.0, 0.0, 0.0, 0.0,
                  0.0, 1.0, 0.0, 0.0,
                  0.0, 0.0, 1.0, 0.0,
                  0.0, 0.0, 0.0, 0.1]
    else
      # As of SU2018 the constructor scales the components of the matrix.
      expected = [10.0,  0.0,  0.0, 0.0,
                   0.0, 10.0,  0.0, 0.0,
                   0.0,  0.0, 10.0, 0.0,
                   0.0,  0.0,  0.0, 1.0]
    end
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_scaling_non_uniform_scale
    transformation = Geom::Transformation.scaling(10, 20, 30)
    expected = [10.0, 0.0, 0.0, 0.0,
                0.0, 20.0, 0.0, 0.0,
                0.0, 0.0, 30.0, 0.0,
                0.0, 0.0, 0.0, 1.0]
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_scaling_point_and_non_uniform_scale
    point = Geom::Point3d.new(1, 2, 3)
    transformation = Geom::Transformation.scaling(point, 10, 20, 30)
    expected = [10.0, 0.0, 0.0, 0.0,
               0.0, 20.0, 0.0, 0.0,
               0.0, 0.0, 30.0, 0.0,
               -9.0, -38.0, -87.0, 1.0]
    assert_equal(expected, transformation.to_a)
    assert_kind_of(Geom::Transformation, transformation)
  end

  def test_scaling_invalid_arguments
    point1 = Geom::Point3d.new(1, 2, 3)
    assert_raises(TypeError, 'Argument with nil') do
      Geom::Transformation.scaling(nil)
    end

    assert_raises(TypeError, 'Argument with nils') do
      Geom::Transformation.scaling(nil, nil, nil)
    end

    assert_raises(ArgumentError, 'Argument with vector3d') do
      vec1 = Geom::Vector3d.new(1, 2, 3)
      Geom::Transformation.scaling(vec1, 4, 5, 6)
    end

    assert_raises(TypeError, 'Argumet with 1 valid and 3 invalid') do
      Geom::Transformation.scaling(point1, 'sketchup', 'ketchup', 'up?')
    end

    assert_raises(TypeError, 'Argument with 3 valid and 1 invalid') do
      Geom::Transformation.scaling(point1, 10, 20, '30')
    end

    assert_raises(ArgumentError, 'too many arguments') do
      Geom::Transformation.scaling(point1, 10, 20, 30, 40)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation.scaling
    end
  end

  def test_set_Bang_point3d
    point1 = Geom::Point3d.new(1, 2, 3)
    transformation1 = Geom::Transformation.new(ORIGIN)
    refute_equal(Geom::Transformation.new(point1).to_a, transformation1.to_a)
    transformation1.set!(point1)
    assert_equal(Geom::Transformation.new(point1).to_a, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)
  end

  def test_set_Bang_transformation
    transformation1 = Geom::Transformation.new(Geom::Point3d.new(1, 2, 3))
    transformation2 = Geom::Transformation.new(ORIGIN)
    refute_equal(transformation2.to_a, transformation1.to_a)
    transformation2.set!(transformation1)
    assert_equal(transformation1.to_a, transformation2.to_a)
    assert_kind_of(Geom::Transformation, transformation2)
  end

  def test_set_Bang_vector3d
    transformation1 = Geom::Transformation.new(ORIGIN)
    vec_transformation = Geom::Transformation.new(Geom::Vector3d.new(1, 2, 3))
    refute_equal(transformation1.to_a, vec_transformation.to_a)
    transformation1.set!(Geom::Vector3d.new(1, 2, 3))
    assert_equal(vec_transformation.to_a, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)
  end

  def test_set_Bang_array
    transformation1 = Geom::Transformation.new(ORIGIN)
    matrix = [1.0, 2.0, 3.0, 0.0,
              5.0, 6.0, 7.0, 0.0,
              9.0, 10.0, 11.0, 0.0,
              13.0, 14.0, 15.0, 16.0]
    refute_equal(transformation1.to_a, matrix)
    transformation1.set!(matrix)
    assert_equal(matrix, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)
  end

  def test_set_Bang_scale
    transformation1 = Geom::Transformation.new(ORIGIN)
    scale_transformation = Geom::Transformation.new(11)
    refute_equal(scale_transformation.to_a, transformation1.to_a)
    transformation1.set!(scale_transformation)
    assert_equal(scale_transformation.to_a, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)
  end

  def test_set_Bang_invalid_arguments
    transformation1 = Geom::Transformation.new(ORIGIN)

    assert_raises(TypeError, 'Argument with nil') do
      transformation1.set!(nil)
    end

    assert_raises(ArgumentError, 'Argument with array size of 1') do
      transformation1.set!([1])
    end

    assert_raises(ArgumentError, 'Argument with array size of 15') do
      transformation1.set!([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
    end

    assert_raises(ArgumentError, 'too many arguments') do
      transformation1.set!(Geom::Vector3d.new(1, 2, 3), ORIGIN)
    end

    assert_raises(ArgumentError, 'empty argument') do
      transformation1.set!
    end
  end

  def test_to_a
    transformation1 = Geom::Transformation.new(ORIGIN)
    assert_equal(IDENTITY.to_a, transformation1.to_a)
    assert_kind_of(Array, transformation1.to_a)
  end

  def test_to_a_too_many_arguments
    transformation1 = Geom::Transformation.new(ORIGIN)

    assert_raises(ArgumentError, 'Argument with nil') do
      transformation1.to_a(nil)
    end

    assert_raises(ArgumentError, 'Argument with transformation') do
      transformation1.to_a(IDENTITY)
    end
  end

  def test_translation
    point1 = Geom::Point3d.new(1, 2, 3)
    vector1 = Geom::Vector3d.new(4, 5, 6)

    transformation1 = Geom::Transformation.translation(point1)
    expected = [1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                1.0, 2.0, 3.0, 1.0]
    assert_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)

    transformation1 = Geom::Transformation.translation(vector1)
    expected = [1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                4.0, 5.0, 6.0, 1.0]
    assert_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)

    transformation1 = Geom::Transformation.translation([4, 5, 6])
    assert_equal(expected, transformation1.to_a)
    assert_kind_of(Geom::Transformation, transformation1)
  end

  def test_translation_invalid_arguments
    assert_raises(ArgumentError, 'Argument with nil') do
      Geom::Transformation.translation(nil)
    end

    assert_raises(ArgumentError, 'Argument with number') do
      Geom::Transformation.translation(1234)
    end

    assert_raises(ArgumentError, 'too many arguments') do
      Geom::Transformation.translation(ORIGIN, ORIGIN)
    end

    assert_raises(ArgumentError, 'empty argument') do
      Geom::Transformation.translation
    end

    assert_raises(ArgumentError, 'Argument with array with length 1') do
      Geom::Transformation.translation([1])
    end

    matrix = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    assert_raises(ArgumentError, 'Argument with array with legth 17') do
      Geom::Transformation.translation(matrix)
    end
  end

  def test_xaxis
    transformation = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    xvec = transformation.xaxis
    assert_equal(Geom::Vector3d.new(1, 0, 0), xvec)
    assert_kind_of(Geom::Vector3d, xvec)
  end

  def test_xaxis_too_many_arguments
    transformation = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation.xaxis(nil)
    end
  end

  def test_yaxis
    transformation = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    yvec = transformation.yaxis
    assert_equal(Geom::Vector3d.new(0, 1, 0), yvec)
    assert_kind_of(Geom::Vector3d, yvec)
  end

  def test_yaxis_too_many_arguments
    transformation = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation.yaxis(nil)
    end
  end

  def test_zaxis
    transformation = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    zvec = transformation.zaxis
    assert_equal(Geom::Vector3d.new(0, 0, 1), zvec)
    assert_kind_of(Geom::Vector3d, zvec)
  end

  def test_zaxis_too_many_arguments
    transformation = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    assert_raises(ArgumentError, 'Argument with nil') do
      transformation.zaxis(nil)
    end
  end
end
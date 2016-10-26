# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Paul Ballew

require "testup/testcase"

# class Array
# http://www.sketchup.com/intl/developer/docs/ourdoc/array
class TC_Array < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end

  module ArrayUtils
    def self.dot_product(array1, array2)
      vector1 = Geom::Vector3d.new(array1[0], array1[1], array1[2])
      vector2 = Geom::Vector3d.new(array2[0], array2[1], array2[2])
      angle = vector1.angle_between(vector2)
      vector1.length * vector2.length * Math.cos(angle)
    end
  end

  # ========================================================================== #
  # class Array
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array

  # ========================================================================== #
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array
  def test_introduction_api_example
    # An array of 3 values can represent a 1" long vector pointing straight
    # up in the z-direction.
    array = [0, 0, 1]

    # An array of 3 values can also represent a point 1" above the origin in
    # the z direction. (Note that this is the exact same array.)
    array = [0, 0, 1]

    # How it is interpreted is based on context. For example, this code will
    # create a construction point at position 0, 0, 1, since in this context
    # a Point3d is expected.
    entities = Sketchup.active_model.entities
    construction_point = entities.add_cpoint(array)

    # Whereas this will move our construction point 1" upward, since in this
    # context a Vector3d is expected.
    transformation = Geom::Transformation.new(array)
    entities.transform_entities(transformation, construction_point)
  end

  # ========================================================================== #
  # method Array.cross
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#cross
  def test_cross_api_example
    vector1 = Geom::Vector3d.new(0, 1, 0)
    array = [1, 0, 0]
    # This will return a new Vector3d
    vector2 = array.cross(vector1)
  end

  def test_cross_bad_params
    array = [1, 2, 3]

    assert_raises(ArgumentError) do
      array.cross("Boom!")
    end

    assert_raises(ArgumentError) do
      array.cross(1.0)
    end

    assert_raises(ArgumentError) do
      array.cross(5)
    end

    assert_raises(ArgumentError) do
      array.cross(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_cross_two_arrays_z_unit_up
    array1 = [0, 1, 0]
    array2 = [1, 0, 0]

    cross_product = array2.cross(array1)
    expected = Geom::Vector3d.new(0, 0, 1)
    assert_equal(expected, cross_product)
    assert_kind_of(Geom::Vector3d, cross_product)
  end

  def test_cross_two_arrays_z_unit_down
    array1 = [0, 1, 0]
    array2 = [1, 0, 0]

    cross_product = array1.cross(array2)
    expected = Geom::Vector3d.new(0, 0, -1)
    assert_equal(expected, cross_product)
    assert_kind_of(Geom::Vector3d, cross_product)
  end

  def test_cross_array_vector_z_unit
    vector = Geom::Vector3d.new(0, 1, 0)
    array = [1, 0, 0]

    cross_product = array.cross(vector)
    expected = Geom::Vector3d.new(0, 0, 1)
    assert_equal(expected, cross_product)
    assert_kind_of(Geom::Vector3d, cross_product)
  end

  def test_cross_array_vector_zero
    vector = Geom::Vector3d.new(1, 0, 0)
    array = [1, 0, 0]

    cross_product = array.cross(vector)
    expected = Geom::Vector3d.new(0, 0, 0)
    assert_equal(expected, cross_product)
    assert_kind_of(Geom::Vector3d, cross_product)
  end

  # ========================================================================== #
  # method Array.distance
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#distance
  def test_distance_api_example
    point = Geom::Point3d.new(10, 10, 10)
    array = [1, 1, 1]
    # This will return a Length
    distance = array.distance(point)
  end

  def test_distance_bad_params
    array = [1, 2, 3]

    assert_raises(ArgumentError) do
      array.distance("Boom!")
    end

    assert_raises(ArgumentError) do
      array.distance(1.0)
    end

    assert_raises(ArgumentError) do
      array.distance(5)
    end

    assert_raises(ArgumentError) do
      array.distance(Geom::Vector3d.new(1, 2, 3))
    end
  end

  def test_distance_point
    point = Geom::Point3d.new(0, 0, 0)

    distance = [1, 0, 0].distance(point)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)

    distance = [0, 1, 0].distance(point)
    assert_equal(1, distance)

    distance = [0, 0, 1].distance(point)
    assert_equal(1, distance)

    distance = [1, 1, 1].distance(point)
    assert_equal(Math.sqrt(3), distance)
  end

  def test_distance_array
    array1 = [1, 0, 0]
    array2 = [0, 0, 0]
    distance = array1.distance(array2)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_of_zero
    point = Geom::Point3d.new(10, 10, 10)
    array = [10, 10, 10]
    distance = array.distance(point)
    assert_equal(0, distance)
  end

  # ========================================================================== #
  # method Array.distance_to_line
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#distance_to_line
  def test_distance_to_line_api_example
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [10, 10, 10]
    # This will return a Length
    distance = array.distance_to_line(line)
  end

  def test_distance_to_line_bad_params
    array = [1, 2, 3]

    assert_raises(TypeError) do
      array.distance_to_line("Boom!")
    end

    assert_raises(TypeError) do
      array.distance_to_line(1.0)
    end

    assert_raises(TypeError) do
      array.distance_to_line(5)
    end

    assert_raises(TypeError) do
      array.distance_to_line(Geom::Vector3d.new(1, 2, 3))
    end
  end

  def test_distance_to_line_x_to_z
    array = [0, 0, 1]
    line = [Geom::Point3d.new(-1, 0, 0), Geom::Vector3d.new(1, 0, 0)]
    distance = array.distance_to_line(line)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_line_y_to_x
    array = [0, 1, 0]
    line = [Geom::Point3d.new(-1, 0, 0), Geom::Vector3d.new(1, 0, 0)]
    distance = array.distance_to_line(line)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_line_x_to_y
    array = [1, 0, 0]
    line = [Geom::Point3d.new(0,-1,0), Geom::Vector3d.new(0, 1, 0)]
    distance = array.distance_to_line(line)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_line_point_to_origin
    array = [1, 1, 1]
    line = [Geom::Point3d.new(-1, 0, 0), Geom::Vector3d.new(1, 0, 0)]
    distance = array.distance_to_line(line)
    assert_equal(Math.sqrt(2), distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_line_zero_distance
    array = [2,2,2]
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(2,2,2)]
    distance = array.distance_to_line(line)
    assert_equal(0, distance)
    assert_kind_of(Length, distance)
  end


  # ========================================================================== #
  # method Array.distance_to_plane
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#distance_to_plane
  def test_distance_to_plane_api_example
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [10, 10, 10]
    # This will return a Length
    distance = array.distance_to_plane(plane)
  end

  def test_distance_to_plane_bad_params
    array = [1, 2, 3]

    assert_raises(TypeError) do
      array.distance_to_plane("Boom!")
    end

    assert_raises(TypeError) do
      array.distance_to_plane(1.0)
    end

    assert_raises(TypeError) do
      array.distance_to_plane(5)
    end

    assert_raises(TypeError) do
      array.distance_to_plane(Geom::Vector3d.new(1, 2, 3))
    end
  end

  def test_distance_to_plane_xyplane_to_zpoint
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [0, 0, 1]
    distance = array.distance_to_plane(plane)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_plane_yzplane_to_xpoint
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(1, 0, 0)]
    array = [1, 0, 0]
    distance = array.distance_to_plane(plane)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_plane_xzplane_to_ypoint
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    array = [0, 1, 0]
    distance = array.distance_to_plane(plane)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_plane_xyplane_to_origin
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [0, 0, 0]
    distance = array.distance_to_plane(plane)
    assert_equal(0, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_plane_xyplane_to_point
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [1, 1, 1]
    distance = array.distance_to_plane(plane)
    assert_equal(1, distance)
    assert_kind_of(Length, distance)
  end

  def test_distance_to_plane_when_already_on_plane
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [500, 1000, 0]
    distance = array.distance_to_plane(plane)
    assert_equal(0, distance)
    assert_kind_of(Length, distance)
  end

  # ========================================================================== #
  # method Array.dot
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#dot
  def test_dot_api_example
    vector = Geom::Vector3d.new(0, 1, 0)
    array = [1, 0, 0]
    # This will return a Float, in this case 22.0
    dot_product = array.dot(vector)
  end

  def test_dot_bad_params
    array = [1, 2, 3]

    assert_raises(ArgumentError) do
      array.dot("Boom!")
    end

    assert_raises(ArgumentError) do
      array.dot(1.0)
    end

    assert_raises(ArgumentError) do
      array.dot(5)
    end

    assert_raises(ArgumentError) do
      array.dot(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_dot_two_arrays
    array1 = [2, 3, 4]
    array2 = [1, 2, 3]
    dot_product = array1.dot(array2)
    expected = ArrayUtils::dot_product(array1, array2)
    assert_in_delta(expected, dot_product, SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_dot_two_arrays_orthogonal
    array1 = [1, 0, 0]
    array2 = [0, 1, 0]
    dot_product = array1.dot(array2)
    expected = ArrayUtils::dot_product(array1, array2)
    assert_in_delta(expected, dot_product, SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_dot_array_vector
    array1 = [2, 3, 4]
    array2 = [1, 2, 3]
    vector2 = Geom::Vector3d.new(array2[0], array2[1], array2[2])
    dot_product = array1.dot(vector2)
    expected = ArrayUtils::dot_product(array1, array2)
    assert_in_delta(expected, dot_product, SKETCHUP_FLOAT_TOLERANCE)
  end

  # ========================================================================== #
  # method Array.normalize
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#normalize
  def test_normalize_api_example
    array = [1, 2, 3]
    # This will return a new Vector3d
    normal_vector = array.normalize
  end

  def test_normalize_bad_params
    array = [1, 2, 3]

    assert_raises(ArgumentError) do
      array.normalize("Boom!")
    end
  end

  def test_normalize_large_array
    x = 999
    y = 9999
    z = 99999
    length = Geom::Vector3d.new(x, y, z).length
    expected_x_normal = x / length
    expected_y_normal = y / length
    expected_z_normal = z / length

    array = [x, y, z]
    new_array = array.normalize
    assert_kind_of(Array, new_array)
    assert_equal(3, new_array.size)
    assert_in_delta(expected_x_normal, new_array.x, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected_y_normal, new_array.y, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected_z_normal, new_array.z, SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_normalize_original_array_unchanged
    array = [1, 2, 3]
    expected = array
    array.normalize
    assert_equal(expected, array)
  end

  # ========================================================================== #
  # method Array.normalize!
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#normalize!
  def test_normalize_Bang_api_example
    array = [1, 2, 3]
    # This will modify 'array' in place
    array.normalize!
  end

  def test_normalize_Bang_bad_params
    array = [1, 2, 3]

    assert_raises(ArgumentError) do
      array.normalize!("Boom!")
    end
  end

  def test_normalize_Bang_frozen
    array = [1, 2, 3]
    array.freeze

    assert_raises(RuntimeError) do
      array.normalize!
    end
  end

  def test_normalize_Bang_large_array
    x = 999
    y = 9999
    z = 99999
    length = Geom::Vector3d.new(x, y, z).length
    expected_x_normal = x / length
    expected_y_normal = y / length
    expected_z_normal = z / length

    array = [x, y, z]
    vector = array.normalize!
    assert_same(array, vector)
    assert_in_delta(expected_x_normal, array.x, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected_y_normal, array.y, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected_z_normal, array.z, SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_normalize_Bang_check_return_vector
    x = 1
    y = 2
    z = 3
    length = Geom::Vector3d.new(x, y, z).length
    expected_x_normal = x / length
    expected_y_normal = y / length
    expected_z_normal = z / length

    array = [x, y, z]
    vector = array.normalize!
    assert_same(array, vector)
    assert_in_delta(expected_x_normal, array.x, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected_y_normal, array.y, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected_z_normal, array.z, SKETCHUP_FLOAT_TOLERANCE)
  end

  # ========================================================================== #
  # method Array.offset
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#offset
  def test_offset_api_example
    array = [10, 10, 10]
    vector = Geom::Vector3d.new(0, 0, 1)
    # This will return a new Array
    point = array.offset(vector)
  end

  def test_offset_bad_params
    array1 = [1, 2, 3]

    assert_raises(ArgumentError) do
      array1.offset("Boom!")
    end

    assert_raises(ArgumentError) do
      array1.offset(1.0)
    end

    assert_raises(ArgumentError) do
      array1.offset(5)
    end

    assert_raises(ArgumentError) do
      array1.offset(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_offset_zero_length_vector
    array = [1, 2, 3]
    vector = Geom::Vector3d.new(0, 0, 0)
    array2 = array.offset(vector)
    expected = Geom::Point3d.new(array2.x, array2.y, array2.z)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_offset_all_axes
    array = [10, 11, 12]
    vector = Geom::Vector3d.new(2.123, 4.567, 6.789)
    array2 = array.offset(vector)
    expected = Geom::Point3d.new(array.x + vector.x, array.y + vector.y, array.z + vector.z)
    assert_in_delta(expected.x, array2.x, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected.y, array2.y, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected.z, array2.z, SKETCHUP_FLOAT_TOLERANCE)
    assert_kind_of(Array, array2)
  end

  def test_offset_original_array_unchanged
    array = [10, 11, 12]
    expected = array
    vector = Geom::Vector3d.new(2.123, 4.567, 6.789)
    array.offset(vector)
    assert_equal(expected, array)
  end

  # ========================================================================== #
  # method Array.offset!
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#offset!
  def test_offset_Bang_api_example
    array = [10, 10, 10]
    vector = Geom::Vector3d.new(0, 0, 1)
    # This will modify 'array' in place
    array.offset!(vector)
  end

  def test_offset_Bang_frozen
    array = [1, 2, 3]
    array.freeze

    assert_raises(RuntimeError) do
      array.offset!(X_AXIS)
    end
  end

  def test_offset_Bang_bad_params
    array1 = [1, 2, 3]

    assert_raises(ArgumentError) do
      array1.offset!("Boom!")
    end

    assert_raises(ArgumentError) do
      array1.offset!(1.0)
    end

    assert_raises(ArgumentError) do
      array1.offset!(5)
    end

    assert_raises(ArgumentError) do
      array1.offset!(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_offset_Bang_zero_length_vector
    array = [1, 2, 3]
    vector = Geom::Vector3d.new(0, 0, 0)
    expected = [array.x, array.y, array.z]
    array.offset!(vector)
    assert_equal(expected, array)
  end

  def test_offset_Bang_all_axes
    array = [10, 11, 12]
    vector = Geom::Vector3d.new(2.123, 4.567, 6.789)
    expected = [array.x + vector.x, array.y + vector.y, array.z + vector.z]
    array.offset!(vector)
    assert_in_delta(expected.x, array.x, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected.y, array.y, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected.z, array.z, SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_offset_Bang_check_return_point
    array = [1, 2, 3]
    vector = Geom::Vector3d.new(0, 0, 0)
    expected = [array.x, array.y, array.z]
    point = array.offset!(vector)
    assert_equal(expected, point)
    assert_kind_of(Array, point)
  end

  # ========================================================================== #
  # method Array.on_line?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array#on_line?
  def test_on_line_Query_api_example
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [10, 10, 10]
    # This will return a true or false value
    on_line = array.on_line?(line)
  end

  def test_on_line_Query_bad_params
    array1 = [1, 2, 3]

    assert_raises(TypeError) do
      array1.on_line?("Boom!")
    end

    assert_raises(TypeError) do
      array1.on_line?(1.0)
    end

    assert_raises(TypeError) do
      array1.on_line?(5)
    end

    assert_raises(TypeError) do
      array1.on_line?(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_on_line_Query_true
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [0, 0, 1]
    on_line = array.on_line?(line)
    assert_equal(true, on_line)
  end

  def test_on_line_Query_far_point
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    array = [0, 0, 99999999]
    on_line = array.on_line?(line)
    assert_equal(true, on_line)
  end

  def test_on_line_Query_false
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    array = [1, 0, 1]
    on_line = array.on_line?(line)
    assert_equal(false, on_line)

    array = [0, 1, 1]
    on_line = array.on_line?(line)
    assert_equal(false, on_line)

    array = [1, 1, 1]
    on_line = array.on_line?(line)
    assert_equal(false, on_line)
  end

  def test_on_line_Query_tolerance
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    array = [0, 0.001, 0]
    on_line = array.on_line?(line)
    assert_equal(false, on_line)

    array = [0.001, 0, 0]
    on_line = array.on_line?(line)
    assert_equal(false, on_line)
  end

  def test_on_line_Query_true_from_at_origin
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(1, 1, 1)]

    array = [0, 0, 0]
    on_line = array.on_line?(line)
    assert_equal(true, on_line)
  end

  # ========================================================================== #
  # method Array.on_plane?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#on_plane?
  def test_on_plane_Query_api_example
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [10, 10, 10]
    # This will return a true or false value
    on_plane = array.on_plane?(plane)
  end

  def test_on_plane_Query_bad_params
    array1 = [1, 2, 3]

    assert_raises(TypeError) do
      array1.on_plane?("Boom!")
    end

    assert_raises(TypeError) do
      array1.on_plane?(1.0)
    end

    assert_raises(TypeError) do
      array1.on_plane?(5)
    end

    assert_raises(TypeError) do
      array1.on_plane?(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_on_plane_Query_true
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]

    array = [1, 2, 0]
    on_plane = array.on_plane?(plane)
    assert_equal(true, on_plane)
  end

  def test_on_plane_Query_far_point_true
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [99999999, 999999999, 0]
    on_plane = array.on_plane?(plane)
    assert_equal(true, on_plane)
  end

  def test_on_plane_Query_just_outside_tolerance
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [1, 2, 0.001]
    on_plane = array.on_plane?(plane)
    assert_equal(false, on_plane)
  end

  def test_on_plane_Query_inside_tolerance
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [1, 2, 0.0001]
    on_plane = array.on_plane?(plane)
    assert_equal(true, on_plane)
  end

  def test_on_plane_Query_true_point_on_origin
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [0.0, 0.0, 0.0]
    on_plane = array.on_plane?(plane)
    assert_equal(true, on_plane)
  end

  # ========================================================================== #
  # method Array.project_to_line
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#project_to_line
  def test_project_to_line_api_example
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [10, 10, 10]
    # This will return a new Array
    point_on_line = array.project_to_line(line)
  end

  def test_project_to_line_bad_params
    array1 = [1, 2, 3]

    assert_raises(TypeError) do
      array1.project_to_line("Boom!")
    end

    assert_raises(TypeError) do
      array1.project_to_line(1.0)
    end

    assert_raises(TypeError) do
      array1.project_to_line(5)
    end

    assert_raises(TypeError) do
      array1.project_to_line(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_project_to_line_x_axis
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(1, 0, 0)]
    array = [0, 2, 0]
    point = array.project_to_line(line)
    assert_equal([0, 0, 0], point)
    assert_kind_of(Array, point)
  end

  def test_project_to_line_y_axis
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    array = [2, 0, 0]
    point = array.project_to_line(line)
    assert_equal([0, 0, 0], point)
    assert_kind_of(Array, point)
  end

  def test_project_to_line_z_axis
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [0, 2, 0]
    point = array.project_to_line(line)
    assert_equal([0, 0, 0], point)
    assert_kind_of(Array, point)
  end

  def test_project_to_line_with_point_already_on_line
    line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [0, 0, 2]
    point = array.project_to_line(line)
    expected = Geom::Point3d.new(0, 0, 2)
    assert_equal(expected, point)
    assert_kind_of(Array, point)
  end

  # ========================================================================== #
  # method Array.project_to_plane
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#project_to_plane
  def test_project_to_plane_api_example
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [10, 10, 10]
    # This will return a new Array
    point_on_plane = array.project_to_plane(plane)
  end

  def test_project_to_plane_bad_params
    array = [1, 2, 3]

    assert_raises(TypeError) do
      array.project_to_plane("Boom!")
    end

    assert_raises(TypeError) do
      array.project_to_plane(1.0)
    end

    assert_raises(TypeError) do
      array.project_to_plane(5)
    end

    assert_raises(TypeError) do
      array.project_to_plane(Geom::Point3d.new(1, 2, 3))
    end
  end

  def test_project_to_plane_x_y_plane
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [1, 2, 3]
    point = array.project_to_plane(plane)
    assert_equal([1, 2, 0], point)
    assert_kind_of(Array, point)
  end

  def test_project_to_plane_y_z_plane
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(1, 0, 0)]
    array = [1, 2, 3]
    point = array.project_to_plane(plane)
    assert_equal([0, 2, 3], point)
    assert_kind_of(Array, point)
  end

  def test_project_to_plane_x_z_plane
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0)]
    array = [1, 2, 3]
    point = array.project_to_plane(plane)
    assert_equal([1, 0, 3], point)
    assert_kind_of(Array, point)
  end

  def test_project_to_plane_with_point_already_on_plane
    plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
    array = [2, 2, 0]
    point = array.project_to_plane(plane)
    expected = Geom::Point3d.new(2, 2, 0)
    assert_equal(expected, point)
    assert_kind_of(Array, point)
  end

  # ========================================================================== #
  # method Array.transform
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#transform
  def test_transform_api_example
    point1 = Geom::Point3d.new(10, 20, 30)
    transform = Geom::Transformation.new(point1)
    array = [1, 2, 3]
    # This will return a new Array
    point2 = array.transform(transform)
  end

  def test_transform_bad_params
    array1 = [1, 2, 3]

    assert_raises(TypeError) do
      array1.transform("Boom!")
    end
  end

  def test_transform_identity
    array = [1, 2, 3]
    transform = Geom::Transformation.new()
    expected = Geom::Point3d.new(array.x, array.y, array.z)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_point_translation
    array1 = [1, 2, 3]
    point = Geom::Point3d.new(1, 1, 1)
    transform = Geom::Transformation.new(point)
    expected = Geom::Point3d.new(array1.x + point.x, array1.y + point.y, array1.z + point.z)
    array2 = array1.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_point_translation_shorthand
    array1 = [1, 2, 3]
    point = Geom::Point3d.new(1, 1, 1)
    expected = Geom::Point3d.new(array1.x + point.x, array1.y + point.y, array1.z + point.z)
    array2 = array1.transform(point)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_vector_translation
    array = [1, 2, 3]
    vector = Geom::Vector3d.new(1, 1, 1)
    transform = Geom::Transformation.new(vector)
    expected = Geom::Point3d.new(array.x + vector.x, array.y + vector.y, array.z + vector.z)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_4_x_4_array_rotate_90_x_axis
    array = [1, 2, 3]
    expected = [1, -3, 2]
    array_4x4 = [1, 0, 0, 0,
                 0, 0, 1, 0,
                 0, -1, 0, 0,
                 0, 0, 0, 1]
    transform = Geom::Transformation.new(array_4x4)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_4_x_4_array_scale_2x
    assert(false, "Fix this for SU2016") # Temporarily added to avoid assert.
    array = [1, 2, 3]
    expected = [2, 4, 6]
    array_4x4 = [1, 0, 0, 0,
                 0, 1, 0, 0,
                 0, 0, 1, 0,
                 0, 0, 0, 0.5]
    transform = Geom::Transformation.new(array_4x4)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_uniform_scale
    array = [1, 2, 3]
    expected = [2, 4, 6]
    transform = Geom::Transformation.new(2)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_uniform_scale_shorthand_integer
    array = [1, 2, 3]
    expected = [2, 4, 6]
    array2 = array.transform(2)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_uniform_scale_shorthand_float
    array = [1, 2, 3]
    expected = [2, 4, 6]
    array2 = array.transform(2.0)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_new_origin_zaxis
    array = [10, 20, 30]

    origin = Geom::Point3d.new(1, 22, 333)
    zaxis = Geom::Vector3d.new(0, 1, 0)

    expected = [-9, 52, 353]
    transform = Geom::Transformation.new(origin, zaxis)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_new_origin_xaxis_yaxis
    array = [10, 20, 30]

    origin = Geom::Point3d.new(1, 22, 333)
    xaxis = Geom::Vector3d.new(0, 1, 0)
    yaxis = Geom::Vector3d.new(1, 0, 0)

    expected = [21, 32, 303]
    transform = Geom::Transformation.new(origin, xaxis, yaxis)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_rotate_pi_radians_around_y_axis
    array = [10, 20, 30]

    origin = Geom::Point3d.new(1, 2, 3)
    axis = Geom::Vector3d.new(0, 1, 0)

    expected = [-8, 20, -24]
    transform = Geom::Transformation.new(origin, axis, Math::PI)
    array2 = array.transform(transform)
    assert_in_delta(expected.x, array2.x, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected.y, array2.y, SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(expected.z, array2.z, SKETCHUP_FLOAT_TOLERANCE)
    assert_kind_of(Array, array2)
  end

  def test_transform_3_axes_and_origin
    array = [10, 20, 30]

    origin = Geom::Point3d.new(1, 2, 3)
    xaxis = Geom::Vector3d.new(0, 1, 0)
    yaxis = Geom::Vector3d.new(0, 0, 1)
    zaxis = Geom::Vector3d.new(1, 0, 0)

    expected = [31, 12, 23]
    transform = Geom::Transformation.new(xaxis, yaxis, zaxis, origin)
    array2 = array.transform(transform)
    assert_equal(expected, array2)
    assert_kind_of(Array, array2)
  end

  def test_transform_original_array_unchanged
    array = [10, 10, 10]
    expected = array
    point = Geom::Point3d.new(1, 1, 1)
    transform = Geom::Transformation.new(point)
    array.transform(transform)
    assert_equal(expected, array)
  end

  # ========================================================================== #
  # method Array.transform!
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#transform!
  def test_transform_Bang_api_example
    point = Geom::Point3d.new(10, 20, 30)
    transform = Geom::Transformation.new(point)
    array = [1, 2, 3]
    # This will modify 'array' in place
    array.transform!(transform)
  end

  def test_transform_Bang_frozen
    array = [1, 2, 3]
    array.freeze

    assert_raises(RuntimeError) do
      array.transform!(2)
    end
  end

  def test_transform_Bang_bad_params
    array1 = [1, 2, 3]

    assert_raises(TypeError) do
      array1.transform!("Boom!")
    end
  end

  def test_transform_Bang_in_place_array
    array = [10, 10, 10]
    point = Geom::Point3d.new(1, 1, 1)
    transform = Geom::Transformation.new(point)
    expected = Geom::Point3d.new(array.x + point.x, array.y + point.y, array.z + point.z)
    array.transform!(transform)
    point = Geom::Point3d.new(array.x, array.y, array.z)
    assert_equal(expected, point)
  end

  def test_transform_Bang_returned_array
    array = [10, 10, 10]
    point = Geom::Point3d.new(1, 1, 1)
    transform = Geom::Transformation.new(point)
    expected = Geom::Point3d.new(array.x + point.x, array.y + point.y, array.z + point.z)
    array2 = array.transform!(transform)
    point = Geom::Point3d.new(array2.x, array2.y, array2.z)
    assert_equal(expected, point)
    assert_kind_of(Array, array2)
  end

  # ========================================================================== #
  # method Array.vector_to
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#vector_to
  def test_vector_to_api_example
    point = Geom::Point3d.new(10, 20, 30)
    array = [1, 2, 3]
    # This will return a new Vector3d
    vector = array.vector_to(point)
  end

  def test_vector_to_bad_params
    array1 = [1, 2, 3]

    assert_raises(ArgumentError) do
      array1.vector_to("Boom!")
    end

    assert_raises(ArgumentError) do
      array1.vector_to(1.0)
    end

    assert_raises(ArgumentError) do
      array1.vector_to(5)
    end

    assert_raises(ArgumentError) do
      array1.vector_to(Geom::Vector3d.new(1, 2, 3))
    end
  end

  def test_vector_to_with_same_points
    point = Geom::Point3d.new(100, 200, 300)
    array = [100, 200, 300]
    vector = array.vector_to(point)
    expected = Geom::Vector3d.new(0, 0, 0)
    assert_equal(expected, vector)
    assert_kind_of(Geom::Vector3d, vector)
  end

  def test_vector_to_different_points
    point = Geom::Point3d.new(10, 20, 30)
    array = [1, 2, 3]
    vector = array.vector_to(point)
    expected = Geom::Vector3d.new(9, 18, 27)
    assert_equal(expected, vector)
    assert_kind_of(Geom::Vector3d, vector)
  end

  # ========================================================================== #
  # method Array.x
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#x
  def test_x_api_example
    array = [1, 2, 3]
    # This will return a Fixnum, in this case 1
    x = array.x

    array = [1.0, 2.0, 3.0]
    # This will return a Float, in this case 1.0
    x = array.x
  end

  def test_x
    array = [1, 2, 3]
    assert_equal(1, array.x)
  end

  # ========================================================================== #
  # method Array.x=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#x=
  def test_x_Set_api_example
    array = [1, 2, 3]
    # This will initialize the x value as a Float
    array.x = 2.5
    # This will initialize the x value as a Fixnum
    array.x = 5
  end

  def test_x_Set_edge_cases
    array = [1, 2, 3]
    array.x = 0
    assert_equal(0, array.x)
    array.x = -5
    assert_equal(-5, array.x)
    array.x = 5
    assert_equal(5, array.x)
    array.x = 100.999
    assert_equal(100.999, array.x)
    array.x = -100.999
    assert_equal(-100.999, array.x)
  end

  # ========================================================================== #
  # method Array.y
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#y
  def test_y_api_example
    array = [1, 2, 3]
    # This will return a Fixnum, in this case 2
    y = array.y

    array = [1.0, 2.0, 3.0]
    # This will return a Float, in this case 2.0
    y = array.y
  end

  def test_y
    array = [1, 2, 3]
    assert_equal(2, array.y)
  end

  # ========================================================================== #
  # method Array.y=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#y=
  def test_y_Set_api_example
    array = [1, 2, 3]
    # This will initialize the y value as a Float
    array.y = 2.5
    # This will initialize the y value as a Fixnum
    array.y = 5
  end

  def test_y_Set_edge_cases
    array = [1, 2, 3]
    array.y = 0
    assert_equal(0, array.y)
    array.y = -5
    assert_equal(-5, array.y)
    array.y = 5
    assert_equal(5, array.y)
    array.y = 100.999
    assert_equal(100.999, array.y)
    array.y = -100.999
    assert_equal(-100.999, array.y)
  end

  # ========================================================================== #
  # method Array.z
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#z
  def test_z_api_example
    array = [1, 2, 3]
    # This will return a Fixnum, in this case 3
    z = array.z

    array = [1.0, 2.0, 3.0]
    # This will return a Float, in this case 3.0
    z = array.z
  end

  def test_z
    array = [1, 2, 3]
    assert_equal(3, array.z)
  end

  # ========================================================================== #
  # method Array.z=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/array.php#z=
  def test_z_Set_api_example
    array = [1, 2, 3]
    # This will initialize the z value as a Float
    array.z = 2.5
    # This will initialize the z value as a Fixnum
    array.z = 5
  end

  def test_z_Set_edge_cases
    array = [1, 2, 3]
    array.z = 0
    assert_equal(0, array.z)
    array.z = -5
    assert_equal(-5, array.z)
    array.z = 5
    assert_equal(5, array.z)
    array.z = 100.999
    assert_equal(100.999, array.z)
    array.z = -100.999
    assert_equal(-100.999, array.z)
  end
end # class

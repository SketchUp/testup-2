# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Edge
# http://www.sketchup.com/intl/en/developer/docs/ourdoc/edge
class TC_Geom_BoundingBox < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # class Geom::BoundingBox
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox

  def test_introduction_api_example_1
    # You can get the bounding box on a model.
    model = Sketchup.active_model
    model_bb = model.bounds

    # Or you can get the bounding box on any Drawingelement object.
    first_entity = model.entities[0]
    first_entity_bb = first_entity.bounds

    # Or you can create an empty bounding box of your own.
    boundingbox = Geom::BoundingBox.new
  end


  # ========================================================================== #
  # method Geom::BoundingBox.add
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#add

  def test_add_api_example
    model = Sketchup.active_model
    boundingbox = model.bounds
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)
    boundingbox.add(point1, point2)
  end

  def test_add_point
    boundingbox = Geom::BoundingBox.new
    boundingbox.add(Geom::Point3d.new(100, 200, 300))

    result = boundingbox.add( Geom::Point3d.new(200, 400, 200))
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_points
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)

    result = boundingbox.add(point1, point2)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_array_of_points
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)

    result = boundingbox.add([point1, point2])
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_vertex
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)
    boundingbox.add(point1)
    edge = Sketchup.active_model.entities.add_line(point1, point2)

    result = boundingbox.add(edge.end)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_vertices
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)
    edge = Sketchup.active_model.entities.add_line(point1, point2)

    result = boundingbox.add(edge.start, edge.end)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_array_of_vertices
    skip("Improved in SU2015") if Sketchup.version.to_i < 15
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)
    edge = Sketchup.active_model.entities.add_line(point1, point2)

    result = boundingbox.add(edge.vertices)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_boundingbox
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)
    boundingbox.add(point1, point2)

    boundingbox2 = Geom::BoundingBox.new
    point3 = Geom::Point3d.new(-200, 600,  100)
    point4 = Geom::Point3d.new( 300, 100, -100)
    boundingbox2.add(point3, point4)

    result = boundingbox.add(boundingbox2)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(-200, 100, -100), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new( 300, 600,  300), boundingbox.corner(7))
  end

  def test_add_boundingboxes
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)
    boundingbox.add(point1, point2)

    boundingbox2 = Geom::BoundingBox.new
    point3 = Geom::Point3d.new(-200, 600,  100)
    point4 = Geom::Point3d.new( 300, 100, -100)
    boundingbox2.add(point3, point4)

    boundingbox3 = Geom::BoundingBox.new
    point5 = Geom::Point3d.new(500,  400, 800)
    point6 = Geom::Point3d.new(300, -100, 100)
    boundingbox3.add(point5, point6)

    result = boundingbox.add(boundingbox2, boundingbox3)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(-200, -100, -100), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new( 500,  600,  800), boundingbox.corner(7))
  end

  def test_add_array_of_boundingboxes
    skip("Improved in SU2015") if Sketchup.version.to_i < 15
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 400, 200)
    boundingbox.add(point1, point2)

    boundingbox2 = Geom::BoundingBox.new
    point3 = Geom::Point3d.new(-200, 600,  100)
    point4 = Geom::Point3d.new( 300, 100, -100)
    boundingbox2.add(point3, point4)

    boundingbox3 = Geom::BoundingBox.new
    point5 = Geom::Point3d.new(500,  400, 800)
    point6 = Geom::Point3d.new(300, -100, 100)
    boundingbox3.add(point5, point6)

    result = boundingbox.add([boundingbox2, boundingbox3])
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(-200, -100, -100), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new( 500,  600,  800), boundingbox.corner(7))
  end

  def test_add_array_as_point
    boundingbox = Geom::BoundingBox.new
    boundingbox.add(Geom::Point3d.new(100, 200, 300))

    result = boundingbox.add( [200, 400, 200] )
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_array_as_points
    boundingbox = Geom::BoundingBox.new
    point1 = [100, 200, 300]
    point2 = [200, 400, 200]

    result = boundingbox.add(point1, point2)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_array_of_array_as_points
    boundingbox = Geom::BoundingBox.new
    point1 = [100, 200, 300]
    point2 = [200, 400, 200]

    result = boundingbox.add([point1, point2])
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 200), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(200, 400, 300), boundingbox.corner(7))
  end

  def test_add_boundingbox_and_point_and_array_as_point
    boundingbox = Geom::BoundingBox.new

    boundingbox2 = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 300, 400)
    boundingbox2.add(point1, point2)

    point3 = Geom::Point3d.new(300, 400, 500)
    point4 = [400, 500, 600]

    result = boundingbox.add(boundingbox2, point3, point4)
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 300), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(400, 500, 600), boundingbox.corner(7))
  end

  def test_add_array_of_boundingbox_and_point_and_array_as_point
    skip("Improved in SU2015") if Sketchup.version.to_i < 15
    boundingbox = Geom::BoundingBox.new

    boundingbox2 = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 300)
    point2 = Geom::Point3d.new(200, 300, 400)
    boundingbox2.add(point1, point2)

    point3 = Geom::Point3d.new(300, 400, 500)
    point4 = [400, 500, 600]

    result = boundingbox.add([boundingbox2, point3, point4])
    assert_equal(boundingbox, result)
    assert_equal(Geom::Point3d.new(100, 200, 300), boundingbox.corner(0))
    assert_equal(Geom::Point3d.new(400, 500, 600), boundingbox.corner(7))
  end

  def test_add_invalid_argument_nil
    boundingbox = Geom::BoundingBox.new
    # Ideally it should be TypeError, but to preserve backwards compatibility
    # the actual implementation is used.
    assert_raises(ArgumentError, "Argument with nil") do
      boundingbox.add(nil)
    end
  end

  def test_add_invalid_argument_string
    boundingbox = Geom::BoundingBox.new
    # Ideally it should be TypeError, but to preserve backwards compatibility
    # the actual implementation is used.
    assert_raises(ArgumentError, "Argument with string") do
      boundingbox.add("FooBar")
    end
  end

  def test_add_invalid_argument_vector
    boundingbox = Geom::BoundingBox.new
    vector = Geom::Vector3d.new(1, 2, 3)
    # Ideally it should be TypeError, but to preserve backwards compatibility
    # the actual implementation is used.
    assert_raises(ArgumentError, "Argument with vector") do
      boundingbox.add(vector)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.center
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#center

  def test_center_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return a point Point3d(150, 300, -150).
    point = boundingbox.center
  end

  def test_center_positive_quadrant
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, 400], [200, 400, 100])

    expected = Geom::Point3d.new(150, 300, 250)
    result = boundingbox.center
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_center_negative_quadrant
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([-100, -200, -400], [-200, -400, -100])

    expected = Geom::Point3d.new(-150, -300, -250)
    result = boundingbox.center
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_center_mixed_quadrant
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(150, 300, -150)
    result = boundingbox.center
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_center_no_points_added
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(0, 0, 0)
    result = boundingbox.center
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_center_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.center(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.clear
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#clear

  def test_clear_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    # This will return false.
    boundingbox.empty?

    boundingbox.clear
    # This will return true.
    boundingbox.empty?
  end

  def test_clear
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    assert_equal(false, boundingbox.empty?)
    result = boundingbox.clear
    assert_equal(true, boundingbox.empty?)
    assert_equal(0, boundingbox.width)
    assert_equal(0, boundingbox.height)
    assert_equal(0, boundingbox.depth)
  end

  def test_clear_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.clear(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.contains?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#contains

  def test_contains_Query_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return false.
    boundingbox.contains?([300, 100, 400])
    # This will return true.
    boundingbox.contains?([150, 300, -200])
  end

  def test_contains_Query_point_inside
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    result = boundingbox.contains?([150, 300, -200])
    assert_equal(true, result)
  end

  def test_contains_Query_point_outside
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    result = boundingbox.contains?([300, 100, 400])
    assert_equal(false, result)
  end

  def test_contains_Query_point_on_volume_border
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    result = boundingbox.contains?([100, 300, 0])
    assert_equal(true, result)
  end

  def test_contains_Query_point_on_volume_corner
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    result = boundingbox.contains?([100, 200, -400])
    assert_equal(true, result)
  end

  def test_contains_Query_boundingbox_inside
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    other_boundingbox = Geom::BoundingBox.new
    other_boundingbox.add([110, 210, -390], [190, 390, 90])

    result = boundingbox.contains?(other_boundingbox)
    assert_equal(true, result)
  end

  def test_contains_Query_boundingbox_outside
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    other_boundingbox = Geom::BoundingBox.new
    other_boundingbox.add([300, 500, 200], [600, 800, 300])

    result = boundingbox.contains?(other_boundingbox)
    assert_equal(false, result)
  end

  def test_contains_Query_boundingbox_intersecting
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    other_boundingbox = Geom::BoundingBox.new
    other_boundingbox.add([150, 250, -300], [300, 500, 200])

    result = boundingbox.contains?(other_boundingbox)
    assert_equal(false, result)
  end

  def test_contains_Query_incorrect_number_of_arguments_zero
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.contains?
    end
  end

  def test_contains_Query_incorrect_number_of_arguments_two
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.contains?(1, 2)
    end
  end

  def test_contains_Query_invalid_argument_vector
    boundingbox = Geom::BoundingBox.new
    vector = Geom::Vector3d.new(1, 2, 3)
    # Ideally it should be TypeError, but to preserve backwards compatibility
    # the actual implementation is used.
    assert_raises(ArgumentError) do
      boundingbox.contains?(vector)
    end
  end

  def test_contains_Query_invalid_argument_string
    boundingbox = Geom::BoundingBox.new
    # Ideally it should be TypeError, but to preserve backwards compatibility
    # the actual implementation is used.
    assert_raises(ArgumentError) do
      boundingbox.contains?("Hello World")
    end
  end

  def test_contains_Query_invalid_argument_number
    boundingbox = Geom::BoundingBox.new
    # Ideally it should be TypeError, but to preserve backwards compatibility
    # the actual implementation is used.
    assert_raises(ArgumentError) do
      boundingbox.contains?(123)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.corner
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#corner

  def test_corner_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return Point3d(100, 200, -400).
    boundingbox.corner(0)
    # This will return Point3d(100, 200, -400).
    boundingbox.corner(6)
  end

  def test_corner_left_front_bottom
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(100, 200, -400)
    assert_equal(expected, boundingbox.corner(0))
  end

  def test_corner_right_front_bottom
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(200, 200, -400)
    assert_equal(expected, boundingbox.corner(1))
  end

  def test_corner_left_back_bottom
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(100, 400, -400)
    assert_equal(expected, boundingbox.corner(2))
  end

  def test_corner_right_back_bottom
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(200, 400, -400)
    assert_equal(expected, boundingbox.corner(3))
  end

  def test_corner_left_front_top
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(100, 200, 100)
    assert_equal(expected, boundingbox.corner(4))
  end

  def test_corner_right_front_top
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(200, 200, 100)
    assert_equal(expected, boundingbox.corner(5))
  end

  def test_corner_left_back_top
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(100, 400, 100)
    assert_equal(expected, boundingbox.corner(6))
  end

  def test_corner_right_back_top
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(200, 400, 100)
    assert_equal(expected, boundingbox.corner(7))
  end

  def test_corner_empty_boundingbox_left_front_bottom
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MIN
    )
    assert_equal(expected, boundingbox.corner(0))
  end

  def test_corner_empty_boundingbox_right_front_bottom
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MIN
    )
    assert_equal(expected, boundingbox.corner(1))
  end

  def test_corner_empty_boundingbox_left_back_bottom
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MIN
    )
    assert_equal(expected, boundingbox.corner(2))
  end

  def test_corner_empty_boundingbox_right_back_bottom
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MIN
    )
    assert_equal(expected, boundingbox.corner(3))
  end

  def test_corner_empty_boundingbox_left_front_top
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MAX
    )
    assert_equal(expected, boundingbox.corner(4))
  end

  def test_corner_empty_boundingbox_right_front_top
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MAX
    )
    assert_equal(expected, boundingbox.corner(5))
  end

  def test_corner_empty_boundingbox_left_back_top
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MAX
    )
    assert_equal(expected, boundingbox.corner(6))
  end

  def test_corner_empty_boundingbox_right_back_top
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MAX
    )
    assert_equal(expected, boundingbox.corner(7))
  end

  def test_corner_float_argument
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    expected = Geom::Point3d.new(100, 200, 100)
    assert_equal(expected, boundingbox.corner(4.44))
    assert_equal(expected, boundingbox.corner(4.55))
  end

  def test_corner_incorrect_number_of_arguments_zero
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    assert_raises ArgumentError do
      boundingbox.corner
    end
  end

  def test_corner_incorrect_number_of_arguments_two
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])

    assert_raises ArgumentError do
      boundingbox.corner(1, 2)
    end
  end

  def test_corner_invalid_argument_negative_index
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    assert_raises(IndexError) do
      boundingbox.corner(-1)
    end
  end

  def test_corner_invalid_argument_index_out_max_bounds
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    assert_raises(IndexError) do
      boundingbox.corner(8)
    end
  end

  def test_corner_invalid_argument_string
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    assert_raises(TypeError) do
      boundingbox.corner("HelloInvalidWorld")
    end
  end

  def test_corner_invalid_argument_array
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    assert_raises(TypeError) do
      boundingbox.corner([1, 2, 3])
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.depth
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#depth

  def test_depth_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return a Length of 500.0.
    length = boundingbox.depth
  end

  def test_depth_with_points_added
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, 400], [200, 400, 100])

    result = boundingbox.depth
    assert_equal(300.0, result)
    assert_kind_of(Length, result)
  end

  def test_depth_no_points_added
    boundingbox = Geom::BoundingBox.new

    result = boundingbox.depth
    assert_equal(0.0, result)
    assert_kind_of(Length, result)
  end

  def test_depth_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.depth(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.diagonal
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#diagonal

  def test_diagonal_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return a point a Length of ~547.72.
    length = boundingbox.diagonal
  end

  def test_diagonal_with_points_added
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 400, 100)
    boundingbox.add(point1, point2)

    expected = point1.distance(point2)
    result = boundingbox.diagonal
    assert_equal(expected, result)
    assert_kind_of(Length, result)
  end

  def test_diagonal_no_points_added
    boundingbox = Geom::BoundingBox.new

    result = boundingbox.diagonal
    assert_equal(0.0, result)
    assert_kind_of(Length, result)
  end

  def test_diagonal_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.diagonal(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.empty?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#empty

  def test_empty_Query_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return false.
    boundingbox.empty?
  end

  def test_empty_Query_with_points_added
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 400, 100)
    boundingbox.add(point1, point2)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_no_points_added
    boundingbox = Geom::BoundingBox.new

    result = boundingbox.empty?
    assert_equal(true, result)
  end

  def test_empty_Query_with_one_point
    boundingbox = Geom::BoundingBox.new
    point = Geom::Point3d.new(100, 200, 400)
    boundingbox.add(point)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_when_1D_along_x
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 200, 400)
    boundingbox.add(point1, point2)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_when_1D_along_y
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(100, 300, 400)
    boundingbox.add(point1, point2)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_when_1D_along_z
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(100, 200, 500)
    boundingbox.add(point1, point2)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_when_2D_along_xy
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 300, 400)
    boundingbox.add(point1, point2)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_when_2D_along_yz
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(100, 300, 500)
    boundingbox.add(point1, point2)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_when_2D_along_xz
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 200, 500)
    boundingbox.add(point1, point2)

    result = boundingbox.empty?
    assert_equal(false, result)
  end

  def test_empty_Query_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.empty?(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.height
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#height

  def test_height_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return a Length of 200.0.
    length = boundingbox.height
  end

  def test_height_with_points_added
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, 400], [200, 400, 100])

    result = boundingbox.height
    assert_equal(200.0, result)
    assert_kind_of(Length, result)
  end

  def test_height_no_points_added
    boundingbox = Geom::BoundingBox.new

    result = boundingbox.height
    assert_equal(0.0, result)
    assert_kind_of(Length, result)
  end

  def test_height_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.height(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.intersect
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#intersect

  def test_intersect_api_example
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([150, 350, 100], [200, 400, 500])
    # The returned boundingbox is a result of the intersection of the two.
    boundingbox = boundingbox1.intersect(boundingbox2)
  end

  def test_intersect_intersecting
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([150, 350, 100], [200, 400, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(false, boundingbox.empty?)

    expected = Geom::Point3d.new(150, 350, 100)
    result = boundingbox.corner(0)
    assert_equal(expected, result, "Bottom left corner")

    expected = Geom::Point3d.new(200, 400, 300)
    result = boundingbox.corner(7)
    assert_equal(expected, result, "Top right corner")
  end

  def test_intersect_not_intersecting
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([300, 500, 400], [400, 600, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_intersect_border_x
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([200, 200, -400], [500, 400, 300])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(200.0, boundingbox.height, "Height")
    assert_equal(700.0, boundingbox.depth, "Depth")
    assert_equal(false, boundingbox.empty?, "Empty boundingbox")
  end

  def test_intersect_border_y
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([100, 400, -400], [200, 600, 300])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(100.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(700.0, boundingbox.depth, "Depth")
    assert_equal(false, boundingbox.empty?, "Empty boundingbox")
  end

  def test_intersect_border_z
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([100, 200,  300], [200, 400, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(100.0, boundingbox.width, "Width")
    assert_equal(200.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(false, boundingbox.empty?, "Empty boundingbox")
  end

  def test_intersect_border_x_tolerance
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    # At the time of writing the tests, SketchUp doesn't perform intersection
    # with tolerance.
    half_tolerance = SKETCHUP_UNIT_TOLERANCE / 2.0
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([200 + half_tolerance, 200, -400], [500, 400, 300])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Empty boundingbox")
  end

  def test_intersect_border_y_tolerance
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    # At the time of writing the tests, SketchUp doesn't perform intersection
    # with tolerance.
    half_tolerance = SKETCHUP_UNIT_TOLERANCE / 2.0
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([100, 400 + half_tolerance, -400], [200, 600, 300])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Empty boundingbox")
  end

  def test_intersect_border_z_tolerance
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    # At the time of writing the tests, SketchUp doesn't perform intersection
    # with tolerance.
    half_tolerance = SKETCHUP_UNIT_TOLERANCE / 2.0
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([100, 200,  300 + half_tolerance], [200, 400, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Empty boundingbox")
  end

  def test_intersect_not_intersecting_overlap_x
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([150, 500, 400], [400, 600, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_intersect_not_intersecting_overlap_y
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([300, 300, 400], [400, 600, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_intersect_not_intersecting_overlap_z
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([300, 500, 200], [400, 600, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_intersect_not_intersecting_overlap_xy
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([150, 300, 400], [400, 600, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_intersect_not_intersecting_overlap_xz
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([150, 500, 200], [400, 600, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_intersect_not_intersecting_overlap_yz
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    boundingbox1 = Geom::BoundingBox.new
    boundingbox1.add([100, 200, -400], [200, 400, 300])
    boundingbox2 = Geom::BoundingBox.new
    boundingbox2.add([300, 300, 200], [400, 600, 500])

    boundingbox = boundingbox1.intersect(boundingbox2)
    assert_kind_of(Geom::BoundingBox, boundingbox)
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_intersect_invalid_argument_number
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    assert_raises(TypeError) do
      boundingbox.intersect(123)
    end
  end

  def test_intersect_invalid_argument_string
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    assert_raises(TypeError) do
      boundingbox.intersect("HelloInvalidWorld")
    end
  end

  def test_intersect_invalid_argument_point
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    point = Geom::Point3d.new(1, 2, 3)
    assert_raises(TypeError) do
      boundingbox.intersect(point)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.max
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#max

  def test_max_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [700, 900, 800], [200, 400, 100])
    # This will return a point Point3d(700, 900, 800).
    point = boundingbox.max
  end

  def test_max_with_points_added
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [700, 900, 800], [200, 400, 100])

    expected = Geom::Point3d.new(700, 900, 800)
    result = boundingbox.max
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_max_no_points_added
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MAX, SKETCHUP_RANGE_MAX
    )
    result = boundingbox.max
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_max_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.max(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.min
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#min

  def test_min_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [700, 900, 800], [200, 400, 100])
    # This will return a point Point3d(100, 200, -400).
    point = boundingbox.min
  end

  def test_min_with_points_added
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [700, 900, 800], [200, 400, 100])

    expected = Geom::Point3d.new(100, 200, -400)
    result = boundingbox.min
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_min_no_points_added
    boundingbox = Geom::BoundingBox.new

    expected = Geom::Point3d.new(
      SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MIN, SKETCHUP_RANGE_MIN
    )
    result = boundingbox.min
    assert_equal(expected, result)
    assert_kind_of(Geom::Point3d, result)
  end

  def test_min_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.min(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.new
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#new

  def test_new_api_example
    boundingbox = Geom::BoundingBox.new
  end

  def test_new
    boundingbox = Geom::BoundingBox.new
    assert_equal(0.0, boundingbox.width, "Width")
    assert_equal(0.0, boundingbox.height, "Height")
    assert_equal(0.0, boundingbox.depth, "Depth")
    assert_equal(true, boundingbox.empty?, "Not empty boundingbox")
  end

  def test_new_incorrect_number_of_arguments
    assert_raises ArgumentError do
      Geom::BoundingBox.new(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.valid?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#valid?

  def test_valid_Query_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return true.
    boundingbox.valid?
  end

  def test_valid_Query_with_points_added
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 400, 100)
    boundingbox.add(point1, point2)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_no_points_added
    boundingbox = Geom::BoundingBox.new

    result = boundingbox.valid?
    assert_equal(false, result)
  end

  def test_valid_Query_with_one_point
    boundingbox = Geom::BoundingBox.new
    point = Geom::Point3d.new(100, 200, 400)
    boundingbox.add(point)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_when_1D_along_x
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 200, 400)
    boundingbox.add(point1, point2)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_when_1D_along_y
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(100, 300, 400)
    boundingbox.add(point1, point2)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_when_1D_along_z
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(100, 200, 500)
    boundingbox.add(point1, point2)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_when_2D_along_xy
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 300, 400)
    boundingbox.add(point1, point2)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_when_2D_along_yz
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(100, 300, 500)
    boundingbox.add(point1, point2)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_when_2D_along_xz
    boundingbox = Geom::BoundingBox.new
    point1 = Geom::Point3d.new(100, 200, 400)
    point2 = Geom::Point3d.new(200, 200, 500)
    boundingbox.add(point1, point2)

    result = boundingbox.valid?
    assert_equal(true, result)
  end

  def test_valid_Query_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.valid?(nil)
    end
  end


  # ========================================================================== #
  # method Geom::BoundingBox.width
  # http://www.sketchup.com/intl/developer/docs/ourdoc/boundingbox#width

  def test_width_api_example
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, -400], [200, 400, 100])
    # This will return a Length of 100.0.
    length = boundingbox.width
  end

  def test_width_with_points_added
    boundingbox = Geom::BoundingBox.new
    boundingbox.add([100, 200, 400], [200, 400, 100])

    result = boundingbox.width
    assert_equal(100.0, result)
    assert_kind_of(Length, result)
  end

  def test_width_no_points_added
    boundingbox = Geom::BoundingBox.new

    result = boundingbox.width
    assert_equal(0.0, result)
    assert_kind_of(Length, result)
  end

  def test_width_incorrect_number_of_arguments
    boundingbox = Geom::BoundingBox.new

    assert_raises ArgumentError do
      boundingbox.width(nil)
    end
  end


end # class

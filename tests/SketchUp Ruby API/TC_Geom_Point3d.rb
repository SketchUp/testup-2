# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Geom::Point3d
# http://www.sketchup.com/intl/developer/docs/ourdoc/point3d
class TC_Geom_Point3d < TestUp::TestCase

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
      point1.vector_to()
    end

    assert_raises(ArgumentError, "Two arguments") do
      point1.vector_to(point2, point2)
    end
  end


end # class

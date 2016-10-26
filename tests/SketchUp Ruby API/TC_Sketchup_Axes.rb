# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


require "testup/testcase"


# Utility class to capture observer events.
class TestUpModelObserver < Sketchup::ModelObserver

  include TestUp::ObserverForwarder

  def initialize
    _set_forwarding_receiver(TC_Sketchup_Axes)
    _start_notification_trace
  end

end # class


# class Sketchup::Axes
# http://www.sketchup.com/intl/developer/docs/ourdoc/axes
class TC_Sketchup_Axes < TestUp::TestCase

  include TestUp::ObserverReceiver

  def setup
    start_with_empty_model
    reset_callback_data
  end

  def teardown
    reset_callback_data
  end


  # ========================================================================== #
  # method Sketchup::Axes.origin
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#origin

  def test_origin_api_example
    point = Sketchup.active_model.axes.origin
  end

  def test_origin
    result = Sketchup.active_model.axes.origin
    assert_kind_of(Geom::Point3d, result)
  end

  def test_origin_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.origin(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.axes
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#axes

  def test_axes_api_example
    xaxis, yaxis, zaxis = Sketchup.active_model.axes.axes
  end

  def test_axes
    result = Sketchup.active_model.axes.axes
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Geom::Vector3d, result[0])
    assert_kind_of(Geom::Vector3d, result[1])
    assert_kind_of(Geom::Vector3d, result[2])
  end

  def test_axes_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.axes(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.xaxis
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#xaxis

  def test_xaxis_api_example
    point = Sketchup.active_model.axes.xaxis
  end

  def test_xaxis
    result = Sketchup.active_model.axes.xaxis
    assert_kind_of(Geom::Vector3d, result)
    assert(result.valid?)
  end

  def test_xaxis_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.xaxis(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.yaxis
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#yaxis

  def test_yaxis_api_example
    point = Sketchup.active_model.axes.yaxis
  end

  def test_yaxis
    result = Sketchup.active_model.axes.yaxis
    assert_kind_of(Geom::Vector3d, result)
    assert(result.valid?)
  end

  def test_yaxis_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.yaxis(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.zaxis
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#zaxis

  def test_zaxis_api_example
    point = Sketchup.active_model.axes.zaxis
  end

  def test_zaxis
    result = Sketchup.active_model.axes.zaxis
    assert_kind_of(Geom::Vector3d, result)
    assert(result.valid?)
  end

  def test_zaxis_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.zaxis(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.transformation
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#transformation

  def test_transformation_api_example
    # Point for a rectangle.
    points = [
      Geom::Point3d.new( 0,  0, 0),
      Geom::Point3d.new(10,  0, 0),
      Geom::Point3d.new(10, 20, 0),
      Geom::Point3d.new( 0, 20, 0)
    ]
    # Transform the points so they are local to the model axes. Otherwise
    # they would be local to the model origin.
    tr = Sketchup.active_model.axes.transformation
    points.each { |point| point.transform!(tr) }
    Sketchup.active_model.active_entities.add_face(points)
  end

  def test_transformation
    result = Sketchup.active_model.axes.transformation
    assert_kind_of(Geom::Transformation, result)
  end

  def test_transformation_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.transformation(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.sketch_plane
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#sketch_plane

  def test_sketch_plane_api_example
    xaxis, yaxis, zaxis = Sketchup.active_model.axes.sketch_plane
  end

  def test_sketch_plane
    result = Sketchup.active_model.axes.sketch_plane
    assert_kind_of(Array, result)
    assert_equal(4, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_kind_of(Float, result[3])
  end

  def test_sketch_plane_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.sketch_plane(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.set
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#set

  def test_set_api_example
    xaxis = Geom::Vector3d.new(3, 5, 0)
    yaxis = xaxis * Z_AXIS
    Sketchup.active_model.axes.set([10,0,0], xaxis, yaxis, Z_AXIS)
  end

  def test_set_axes_parent_to_model
    model_observer = TestUpModelObserver.new
    Sketchup.active_model.add_observer(model_observer)

    xaxis = Geom::Vector3d.new(3, 5, 0)
    yaxis = xaxis * Z_AXIS
    result = Sketchup.active_model.axes.set([10, 0, 0], xaxis, yaxis, Z_AXIS)
    assert_equal(Sketchup.active_model.axes, result)

    assert_notifications("onTransactionStart", "onTransactionCommit")
    assert_notification_count("onTransactionStart", 1)
    assert_notification_count("onTransactionCommit", 1)

    origin = Sketchup.active_model.axes.origin
    assert_equal(Geom::Point3d.new(10, 0, 0), origin)

    xaxis, yaxis, zaxis = Sketchup.active_model.axes.axes
    assert_equal(Geom::Vector3d.new(3,  5, 0).normalize, xaxis)
    assert_equal(Geom::Vector3d.new(5, -3, 0).normalize, yaxis)
    assert_equal(Geom::Vector3d.new(0,  0, 1).normalize, zaxis)

  ensure
    Sketchup.active_model.remove_observer(model_observer)
  end

  def test_set_axes_parent_to_page
    page = Sketchup.active_model.pages.add("Example Page")

    model_observer = TestUpModelObserver.new
    Sketchup.active_model.add_observer(model_observer)

    xaxis = Geom::Vector3d.new(3, 5, 0)
    yaxis = xaxis * Z_AXIS
    result = page.axes.set([10, 0, 0], xaxis, yaxis, Z_AXIS)
    assert_equal(page.axes, result)

    assert_no_notification

    origin = page.axes.origin
    assert_equal(Geom::Point3d.new(10, 0, 0), origin)

    xaxis, yaxis, zaxis = page.axes.axes
    assert_equal(Geom::Vector3d.new(3,  5, 0).normalize, xaxis)
    assert_equal(Geom::Vector3d.new(5, -3, 0).normalize, yaxis)
    assert_equal(Geom::Vector3d.new(0,  0, 1).normalize, zaxis)

  ensure
    Sketchup.active_model.remove_observer(model_observer)
  end

  def test_set_incorrect_number_of_arguments_zero
    assert_raises ArgumentError do
       Sketchup.active_model.axes.set
    end
  end

  def test_set_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.set(ORIGIN)
    end
  end

  def test_set_incorrect_number_of_arguments_two
    assert_raises ArgumentError do
       Sketchup.active_model.axes.set(ORIGIN, X_AXIS)
    end
  end

  def test_set_incorrect_number_of_arguments_three
    assert_raises ArgumentError do
       Sketchup.active_model.axes.set(ORIGIN, X_AXIS, Y_AXIS)
    end
  end

  def test_set_incorrect_number_of_arguments_five
    assert_raises ArgumentError do
       Sketchup.active_model.axes.set(ORIGIN, X_AXIS, Y_AXIS, Z_AXIS, X_AXIS)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.to_a
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#to_a

  def test_to_a_api_example
    xaxis, yaxis, zaxis = Sketchup.active_model.axes.to_a
  end

  def test_to_a
    result = Sketchup.active_model.axes.to_a
    assert_kind_of(Array, result)
    assert_equal(4, result.size)
    assert_kind_of(Geom::Point3d,  result[0])
    assert_kind_of(Geom::Vector3d, result[1])
    assert_kind_of(Geom::Vector3d, result[2])
    assert_kind_of(Geom::Vector3d, result[3])
  end

  def test_to_a_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.to_a(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.typename
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#typename

  def test_typename_api_example
    xaxis, yaxis, zaxis = Sketchup.active_model.axes.typename
  end

  def test_typename
    result = Sketchup.active_model.axes.typename
    assert_kind_of(String, result)
    assert_equal("Axes", result)
  end

  def test_typename_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       Sketchup.active_model.axes.typename(123)
    end
  end


end # class

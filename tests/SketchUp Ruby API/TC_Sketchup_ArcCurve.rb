# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::ArcCurve
class TC_Sketchup_ArcCurve < TestUp::TestCase

  def setup
    start_with_empty_model
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

  # TODO(thomthom): Move this into SketchUpTestUtilities.
  def open_test_model(filename)
    testcase_name = File.basename(__FILE__, ".*")
    path = File.dirname(__FILE__)
    test_model = File.join(path, testcase_name, filename)
    close_active_model()
    disable_read_only_flag_for_test_models
    Sketchup.open_file(test_model)
    restore_read_only_flag_for_test_models
    Sketchup.active_model
  end

  def create_circle(angle)
    model = Sketchup.active_model
    entities = model.entities

    start_a = angle
    end_a = 360.degrees + start_a
    edges = entities.add_arc(ORIGIN, X_AXIS, Z_AXIS, 500.mm, start_a, end_a, 16)
    edges.first.curve
  end


  # ========================================================================== #
  # method Sketchup::ArcCurve.end_angle

  # SU-23297
  def test_end_angle_extruded_circle
    skip("Fixed in SU2018") if Sketchup.version.to_i < 18
    model = open_test_model('ExtrudedCircle.skp')
    edges = model.entities.grep(Sketchup::Edge)
    curve = edges.find { |edge| edge.curve }.curve

    assert_equal_tol(360.degrees, curve.end_angle)
  end

  def test_end_angle_x_axis_oriented
    skip("Fixed in SU2018") if Sketchup.version.to_i < 18
    model = start_with_empty_model
    curve = create_circle(0.degrees)

    assert_equal_tol(360.degrees, curve.end_angle)
  end

  def test_end_angle_rotated_circle
    skip("Fixed in SU2018") if Sketchup.version.to_i < 18
    model = start_with_empty_model
    curve = create_circle(15.degrees)

    assert_equal_tol(360.degrees + 15.degrees, curve.end_angle)
  end

end # class

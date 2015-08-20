# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Camera
# http://www.sketchup.com/intl/developer/docs/ourdoc/camera
class TC_Sketchup_Camera < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    camera = Sketchup.active_model.active_view.camera
    camera.aspect_ratio = 0.0
  end


  # ========================================================================== #
  # method Sketchup::Camera.fov_is_height?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/camera#fov_is_height?

  def test_fov_is_height_Query_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    if camera.fov_is_height?
      fov_vertical = camera.fov
      # Compute the horizontal FOV.
    else
      fov_horizontal = camera.fov
      # Compute the vertical FOV.
    end
  end

  def test_fov_is_height_Query_is_height
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    camera.aspect_ratio = 0.0
    result = camera.fov_is_height?
    assert_kind_of(TrueClass, result)
  end

  def test_fov_is_height_Query_is_width
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    camera.aspect_ratio = 3.0
    result = camera.fov_is_height?
    assert_kind_of(FalseClass, result)
  end

  def test_fov_is_height_Query_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    assert_raises ArgumentError do
      camera.fov_is_height?(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Camera.is_2d?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/camera#is_2d?

  def test_is_2d_Query_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.active_view.camera.is_2d?
  end

  def test_is_2d_Query_is_not_2d
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.close(true) # Assume template in perspective view.
    camera = Sketchup.active_model.active_view.camera
    result = camera.is_2d?
    assert_kind_of(FalseClass, result)
  end

  def test_is_2d_Query_is_2d
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.close(true)
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
    page = Sketchup.active_model.pages.add_matchphoto_page(filename)
    Sketchup.active_model.pages.selected_page = page

    camera = Sketchup.active_model.active_view.camera
    result = camera.is_2d?
    assert_kind_of(TrueClass, result)
  end

  def test_is_2d_Query_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    assert_raises ArgumentError do
      camera.is_2d?(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Camera.center_2d
  # http://www.sketchup.com/intl/developer/docs/ourdoc/camera#center_2d

  def test_center_2d_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.active_view.camera.center_2d
  end

  def test_center_2d
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    result = camera.center_2d
    assert_kind_of(Geom::Point3d, result)
    assert_equal(ORIGIN, result)
  end

  def test_center_2d_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    assert_raises ArgumentError do
      camera.center_2d(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Camera.scale_2d
  # http://www.sketchup.com/intl/developer/docs/ourdoc/camera#scale_2d

  def test_scale_2d_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.active_view.camera.scale_2d
  end

  def test_scale_2d
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    result = camera.scale_2d
    assert_kind_of(Float, result)
    assert_equal(1.0, result)
  end

  def test_scale_2d_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    camera = Sketchup.active_model.active_view.camera
    assert_raises ArgumentError do
      camera.scale_2d(123)
    end
  end


end # class

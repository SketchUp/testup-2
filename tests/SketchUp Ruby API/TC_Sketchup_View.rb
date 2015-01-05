# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::View
# http://www.sketchup.com/intl/developer/docs/ourdoc/view
class TC_Sketchup_View < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::View.draw
  # http://www.sketchup.com/intl/developer/docs/ourdoc/view#draw

  def test_draw_invalid_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw()
    end
  end

  def test_draw_invalid_arguments_zero_points
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_POINTS)
    end
  end


  def test_draw_gl_points_single
    Sketchup.active_model.active_view.draw(GL_POINTS, ORIGIN)
  end

  def test_draw_gl_points_multiple
    Sketchup.active_model.active_view.draw(GL_POINTS, ORIGIN, [9,9,9])
  end


  def test_draw_gl_lines_single
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    Sketchup.active_model.active_view.draw(GL_LINES, points)
  end

  def test_draw_gl_lines_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    Sketchup.active_model.active_view.draw(GL_LINES, points)
  end

  def test_draw_gl_lines_invalid_arguments
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2], [4,4,4]]
      Sketchup.active_model.active_view.draw(GL_LINES, points)
    end
  end


  def test_draw_gl_line_strip_single
    points = [ORIGIN, [2,2,2]]
    Sketchup.active_model.active_view.draw(GL_LINE_STRIP, points)
  end

  def test_draw_gl_line_strip_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    Sketchup.active_model.active_view.draw(GL_LINE_STRIP, points)
  end

  def test_draw_gl_line_strip_invalid_arguments
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_LINE_STRIP, points)
    end
  end


  def test_draw_gl_line_loop_single
    points = [ORIGIN, [2,2,2]]
    Sketchup.active_model.active_view.draw(GL_LINE_LOOP, points)
  end

  def test_draw_gl_line_loop_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    Sketchup.active_model.active_view.draw(GL_LINE_LOOP, points)
  end

  def test_draw_gl_line_loop_invalid_arguments
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_LINE_LOOP, points)
    end
  end


  def test_draw_gl_triangles_single
    points = [ORIGIN, [2,2,2], [4,4,4]]
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, points)
  end

  def test_draw_gl_triangles_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8], [10,10,10]]
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, points)
  end

  def test_draw_gl_triangles_invalid_arguments_one
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_TRIANGLES, points)
    end
  end

  def test_draw_gl_triangles_invalid_arguments_two
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2]]
      Sketchup.active_model.active_view.draw(GL_TRIANGLES, points)
    end
  end

  def test_draw_gl_triangles_invalid_arguments_four
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
      Sketchup.active_model.active_view.draw(GL_TRIANGLES, points)
    end
  end

  def test_draw_gl_triangles_invalid_arguments_five
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
      Sketchup.active_model.active_view.draw(GL_TRIANGLES, points)
    end
  end


  def test_draw_gl_triangle_strip_single
    points = [ORIGIN, [2,2,2], [4,4,4]]
    Sketchup.active_model.active_view.draw(GL_TRIANGLE_STRIP, points)
  end

  def test_draw_gl_triangle_strip_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    Sketchup.active_model.active_view.draw(GL_TRIANGLE_STRIP, points)
  end

  def test_draw_gl_triangle_strip_invalid_arguments_one
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_TRIANGLE_STRIP, points)
    end
  end

  def test_draw_gl_triangle_strip_invalid_arguments_two
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2]]
      Sketchup.active_model.active_view.draw(GL_TRIANGLE_STRIP, points)
    end
  end


  def test_draw_gl_triangle_fan_single
    points = [ORIGIN, [2,2,2], [4,4,4]]
    Sketchup.active_model.active_view.draw(GL_TRIANGLE_FAN, points)
  end

  def test_draw_gl_triangle_fan_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    Sketchup.active_model.active_view.draw(GL_TRIANGLE_FAN, points)
  end

  def test_draw_gl_triangle_fan_invalid_arguments_one
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_TRIANGLE_FAN, points)
    end
  end

  def test_draw_gl_triangle_fan_invalid_arguments_two
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2]]
      Sketchup.active_model.active_view.draw(GL_TRIANGLE_FAN, points)
    end
  end


  def test_draw_gl_quads_single
    points = [ORIGIN, [2,0,0], [2,2,0], [0,2,0]]
    Sketchup.active_model.active_view.draw(GL_QUADS, points)
  end

  def test_draw_gl_quads_multiple
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8], [10,10,10], [12,12,12], [14,14,14]
    ]
    Sketchup.active_model.active_view.draw(GL_QUADS, points)
  end

  def test_draw_gl_quads_invalid_arguments_one
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_QUADS, points)
    end
  end

  def test_draw_gl_quads_invalid_arguments_two
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2]]
      Sketchup.active_model.active_view.draw(GL_QUADS, points)
    end
  end

  def test_draw_gl_quads_invalid_arguments_three
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2], [4,4,4]]
      Sketchup.active_model.active_view.draw(GL_QUADS, points)
    end
  end

  def test_draw_gl_quads_invalid_arguments_five
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [
        ORIGIN, [2,2,2], [4,4,4], [6,6,6],
        [8,8,8]
      ]
      Sketchup.active_model.active_view.draw(GL_QUADS, points)
    end
  end

  def test_draw_gl_quads_invalid_arguments_six
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [
        ORIGIN, [2,2,2], [4,4,4], [6,6,6],
        [8,8,8], [10,10,10]
      ]
      Sketchup.active_model.active_view.draw(GL_QUADS, points)
    end
  end

  def test_draw_gl_quads_invalid_arguments_seven
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [
        ORIGIN, [2,2,2], [4,4,4], [6,6,6],
        [8,8,8], [10,10,10], [12,12,12]
      ]
      Sketchup.active_model.active_view.draw(GL_QUADS, points)
    end
  end


  def test_draw_gl_quad_strip_single
    points = [ORIGIN, [2,0,0], [2,2,0], [0,2,0]]
    Sketchup.active_model.active_view.draw(GL_QUAD_STRIP, points)
  end

  def test_draw_gl_quad_strip_multiple
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8], [10,10,10]
    ]
    Sketchup.active_model.active_view.draw(GL_QUAD_STRIP, points)
  end

  def test_draw_gl_quad_strip_invalid_arguments_one
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_QUAD_STRIP, points)
    end
  end

  def test_draw_gl_quad_strip_invalid_arguments_two
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2]]
      Sketchup.active_model.active_view.draw(GL_QUAD_STRIP, points)
    end
  end

  def test_draw_gl_quad_strip_invalid_arguments_three
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2], [4,4,4]]
      Sketchup.active_model.active_view.draw(GL_QUAD_STRIP, points)
    end
  end

  def test_draw_gl_quad_strip_invalid_arguments_five
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [
        ORIGIN, [2,2,2], [4,4,4], [6,6,6],
        [8,8,8]
      ]
      Sketchup.active_model.active_view.draw(GL_QUAD_STRIP, points)
    end
  end

  def test_draw_gl_quad_strip_invalid_arguments_seven
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      points = [
        ORIGIN, [2,2,2], [4,4,4], [6,6,6],
        [8,8,8], [10,10,10], [12,12,12]
      ]
      Sketchup.active_model.active_view.draw(GL_QUAD_STRIP, points)
    end
  end


  def test_draw_gl_polygon_triangle
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    Sketchup.active_model.active_view.draw(GL_POLYGON, points)
  end

  def test_draw_gl_polygon_quad
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    Sketchup.active_model.active_view.draw(GL_POLYGON, points)
  end

  def test_draw_gl_polygon_pentagon
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    Sketchup.active_model.active_view.draw(GL_POLYGON, points)
  end

  def test_draw_gl_polygon_invalid_arguments_one
    assert_raises(ArgumentError) do
      points = [ORIGIN]
      Sketchup.active_model.active_view.draw(GL_POLYGON, points)
    end
  end

  def test_draw_gl_polygon_invalid_arguments_two
    assert_raises(ArgumentError) do
      points = [ORIGIN, [2,2,2]]
      Sketchup.active_model.active_view.draw(GL_POLYGON, points)
    end
  end

end # class

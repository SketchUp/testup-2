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


  # ========================================================================== #
  # method Sketchup::View.draw_text
  # http://www.sketchup.com/intl/developer/docs/ourdoc/view#draw_text

  def test_draw_text_api_example
    view = Sketchup.active_model.active_view

    # This works in all SketchUp versions and draws the text using the
    # default font, color and size.
    point = Geom::Point3d.new(200, 100, 0)
    view.draw_text(point, "This is a test")

    # This works in SketchUp 2016 and up.
    options = {
      :font => "Arial",
      :size => 20,
      :bold => true,
      :align => TextAlignRight
    }
    point = Geom::Point3d.new(200, 200, 0)
    view.draw_text(point, "This is another\ntest", options)

    # You can also use Ruby 2.0's named arguments:
    point = Geom::Point3d.new(200, 200, 0)
    view.draw_text(point, "Hello world!", color: "Red")
  end

  def test_draw_text
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test")
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_invalid_argument_position
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.draw_text("FooBar", "Test")
    end
  end

  def test_draw_invalid_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw_text()
    end
  end

  def test_draw_invalid_arguments_one
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw_text(ORIGIN)
    end
  end

  def test_draw_invalid_arguments_three
    skip("Optional argument added in SU2016") if Sketchup.version.to_i >= 16
    assert_raises(TypeError) do
      Sketchup.active_model.active_view.draw_text(ORIGIN, "Test", 123)
    end
  end

  def test_draw_invalid_arguments_four
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw_text(ORIGIN, "Test", 123, 456)
    end
  end

  def test_draw_text_options_argument
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", {})
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_options_invalid_argument
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", ORIGIN)
    end
  end

  def test_draw_text_option_font
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    options = {
      :font => "Arial"
    }
    result = view.draw_text(ORIGIN, "Test", options)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_font_bogus_name
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    options = {
      :font => "IamNotAFontButShouldNotCrash"
    }
    result = view.draw_text(ORIGIN, "Test", options)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_font_long_name
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    options = {
      :font => "ThisFontNameIsTooLongForWindows01234"
    }
    if Sketchup.platform == :platform_osx
      result = view.draw_text(ORIGIN, "Test", options)
      assert_equal(view, result)
    else
      assert_raises(ArgumentError) do
        view.draw_text(ORIGIN, "Test", options)
      end
    end
  end

  def test_draw_text_option_font_name_unicode
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    options = {
      :font => "Tæsting てすと"
    }
    result = view.draw_text(ORIGIN, "てすと", options)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_font_invalid_argument
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", font: ORIGIN)
    end
  end

  def test_draw_text_option_size
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", size: 20)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_size_zero
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", size: 0)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_size_invalid_argument
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", size: "FooBar")
    end
  end

  def test_draw_text_option_italic
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", italic: true)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_bold
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", bold: true)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_color
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    color = Sketchup::Color.new(255, 0, 0)
    result = view.draw_text(ORIGIN, "Test", color: color)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_color_string
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", color: "red")
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_color_invalid_argument
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", color: ORIGIN)
    end
  end

  def test_draw_text_option_align_left
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", align: TextAlignLeft)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_align_center
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", align: TextAlignCenter)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_align_right
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", align: TextAlignRight)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_align_invalid_integer_less_than
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.draw_text(ORIGIN, "Test", align: -1)
    end
  end

  def test_draw_text_option_align_invalid_integer_higher_than
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.draw_text(ORIGIN, "Test", align: 3)
    end
  end

  def test_draw_text_option_align_invalid_symbol
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", align: :foobar)
    end
  end

  def test_draw_text_option_align_invalid_argument
    skip("Added in SU2016") if Sketchup.version.to_i < 16
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", align: ORIGIN)
    end
  end

end # class

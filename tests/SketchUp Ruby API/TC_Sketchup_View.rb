# Copyright:: Copyright 2018-2019 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'fileutils'
require 'testup/testcase'


# class Sketchup::View
class TC_Sketchup_View < TestUp::TestCase

  attr_accessor :temp_file

  def self.setup_testcase
    discard_all_models
  end

  def setup
    Sketchup.active_model.select_tool(nil)
    @temp_file = temp_filename('png')
    File.delete(@temp_file) if File.exist?(@temp_file)
  end

  def teardown
    Sketchup.active_model.select_tool(nil)
    File.delete(@temp_file) if File.exist?(@temp_file)
  end


  def temp_dir
    path = File.join(Sketchup.temp_dir, self.class.name)
    FileUtils.mkdir_p(path)
    path
  end

  def temp_filename(file_extension)
    filename = "output-#{Time.now.to_i}-#{rand(1..100_000)}.#{file_extension}"
    File.join(temp_dir, filename)
  end

  # @param [String]
  # @return [Sketchup::ImageRep]
  def get_image_rep(filename)
    test_folder = File.basename(__FILE__, '.*')
    path = File.join(__dir__, test_folder, filename)
    Sketchup::ImageRep.new(path)
  end

  def load_test_style(model, style_filename, select: true)
    path = File.join(__dir__, 'shared', style_filename)
    assert(File.exist?(path), "Style file doesn't exist: #{path}")
    model.styles.add_style(path, select)
  end


  # ========================================================================== #
  # method Sketchup::View.draw

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

  # view.draw(mode, points, normals: normals)

  def test_draw_options_normals_array_of_points
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    normals = [Z_AXIS, Z_AXIS, Z_AXIS]
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: normals)
  end

  def test_draw_options_normals_splatted_points
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    normals = [Z_AXIS, Z_AXIS, Z_AXIS]
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, *points, normals: normals)
  end

  def test_draw_options_normals_vectors_as_arrays
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    normals = [[0,0,1], [0,0,1], [0,0,1]]
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: normals)
  end

  def test_draw_options_normals_too_few_normals
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: [])
    end
  end

  def test_draw_options_normals_too_many_normals
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    normals = [Z_AXIS, Z_AXIS, Z_AXIS, Z_AXIS]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: normals)
    end
  end

  def test_draw_options_normals_zero_length_vectors
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    normals = [Z_AXIS, Geom::Vector3d.new(0,0,0), Z_AXIS]
    # Invalid types are ignored (like points are).
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: normals)
  end

  def test_draw_options_normals_nil_in_vector_array
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    normals = [Z_AXIS, nil, Z_AXIS]
    # Invalid types are ignored (like points are).
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: normals)
  end

  def test_draw_options_normals_string_in_vector_array
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    normals = [Z_AXIS, '[0,0,1]', Z_AXIS]
    # Invalid types are ignored (like points are).
    Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: normals)
  end

  def test_draw_options_normals_string_instead_of_option_hash
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0]]
    assert_raises(TypeError) do
      Sketchup.active_model.active_view.draw(GL_TRIANGLES, points, normals: 'normals')
    end
  end

  # view.draw(mode, points, texture_id: texture_id, uvs: uvs)

  class TextureTool

    def activate
      view = Sketchup.active_model.active_view
      image_rep = get_image_rep('test_small.jpg')
      @texture_id = view.load_texture(image_rep)
      view.invalidate
    end

    def deactivate(view)
      view.release_texture(@texture_id) if @texture_id
      view.invalidate
    end

    def draw(view)
      points = [ [0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0] ]
      uvs = [ [0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0] ]
      view.draw(GL_QUADS, points, texture_id: @texture_id, uvs: uvs)
    end

    private

    # @param [String]
    # @return [Sketchup::ImageRep]
    def get_image_rep(filename)
      test_folder = File.basename(__FILE__, '.*')
      path = File.join(__dir__, test_folder, filename)
      Sketchup::ImageRep.new(path)
    end

  end

  def test_draw_options_uvs_and_texture
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
  ensure
    Sketchup.active_model.select_tool(nil)
  end

  def test_draw_options_uvs_and_texture_multiple_tools
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(nil) # Activates Select Tool
    model.tools.push_tool(TextureTool.new)
    model.tools.pop_tool
  end

  def test_draw_options_uvs_array_of_points
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0]]
    Sketchup.active_model.active_view.draw(GL_QUADS, points, uvs: uvs)
  end

  def test_draw_options_uvs_nil_in_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], nil, [0,1,0]]
    # Invalid types are ignored (like points are).
    Sketchup.active_model.active_view.draw(GL_QUADS, points, uvs: uvs)
  end

  def test_draw_options_uvs_string_in_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], '[1,1,0]', [0,1,0]]
    # Invalid types are ignored (like points are).
    Sketchup.active_model.active_view.draw(GL_QUADS, points, uvs: uvs)
  end

  def test_draw_options_uvs_too_few_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_QUADS, points, uvs: uvs)
    end
  end

  def test_draw_options_uvs_too_many_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_QUADS, points, uvs: uvs)
    end
  end

  def test_draw_options_texture_invalid_texture_id_zero
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_QUADS, points, texture: 0, uvs: uvs)
    end
  end

  def test_draw_options_texture_invalid_texture_id
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_QUADS, points, texture: 10, uvs: uvs)
    end
  end

  def test_draw_options_texture_invalid_texture_id_negative
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw(GL_QUADS, points, texture: -10, uvs: uvs)
    end
  end

  def test_draw_options_texture_invalid_type
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0]]
    assert_raises(TypeError) do
      Sketchup.active_model.active_view.draw(GL_QUADS, points, texture: '10', uvs: uvs)
    end
  end


  # ========================================================================== #
  # method Sketchup::View.draw2d

  class TextureTool2d

    def activate
      view = Sketchup.active_model.active_view
      image_rep = get_image_rep('test_small.jpg')
      @texture_id = view.load_texture(image_rep)
      view.invalidate
    end

    def deactivate(view)
      view.release_texture(@texture_id) if @texture_id
      view.invalidate
    end

    def draw(view)
      points = [ [0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0] ]
      uvs = [ [0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0] ]
      view.draw2d(GL_QUADS, points, texture_id: @texture_id, uvs: uvs)
    end

    private

    # @param [String]
    # @return [Sketchup::ImageRep]
    def get_image_rep(filename)
      test_folder = File.basename(__FILE__, '.*')
      path = File.join(__dir__, test_folder, filename)
      Sketchup::ImageRep.new(path)
    end

  end

  def test_draw2d_options_uvs_and_texture
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool2d.new)
  ensure
    Sketchup.active_model.select_tool(nil)
  end

  def test_draw2d_options_uvs_and_texture_multiple_tools
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(nil) # Activates Select Tool
    model.tools.push_tool(TextureTool2d.new)
    model.tools.pop_tool
  end

  def test_draw2d_options_uvs_array_of_points
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0]]
    Sketchup.active_model.active_view.draw2d(GL_QUADS, points, uvs: uvs)
  end

  def test_draw2d_options_uvs_nil_in_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], nil, [0,1,0]]
    # Invalid types are ignored (like points are).
    Sketchup.active_model.active_view.draw2d(GL_QUADS, points, uvs: uvs)
  end

  def test_draw2d_options_uvs_string_in_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], '[1,1,0]', [0,1,0]]
    # Invalid types are ignored (like points are).
    Sketchup.active_model.active_view.draw2d(GL_QUADS, points, uvs: uvs)
  end

  def test_draw2d_options_uvs_too_few_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw2d(GL_QUADS, points, uvs: uvs)
    end
  end

  def test_draw2d_options_uvs_too_many_uvs
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw2d(GL_QUADS, points, uvs: uvs)
    end
  end

  def test_draw2d_options_texture_invalid_texture_id_zero
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw2d(GL_QUADS, points, texture: 0, uvs: uvs)
    end
  end

  def test_draw2d_options_texture_invalid_texture_id
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw2d(GL_QUADS, points, texture: 10, uvs: uvs)
    end
  end

  def test_draw2d_options_texture_invalid_texture_id_negative
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [0,1,0]]
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw2d(GL_QUADS, points, texture: -10, uvs: uvs)
    end
  end

  def test_draw2d_options_texture_invalid_type
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    points = [[0,0,0], [9,0,0], [9,9,0], [0,9,0]]
    uvs = [[0,0,0], [1,0,0], [1,1,0], [0,1,0]]
    assert_raises(TypeError) do
      Sketchup.active_model.active_view.draw2d(GL_QUADS, points, texture: '10', uvs: uvs)
    end
  end


  # ========================================================================== #
  # method Sketchup::View.load_texture

  def test_load_texture_with_ruby_tool
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    skip("Changed in SU2023.0") if Sketchup.version.to_f >= 23.0
    model = Sketchup.active_model
    begin
      model.select_tool(TextureTool.new)
      image_rep = get_image_rep('test_small.jpg')
      texture_id = model.active_view.load_texture(image_rep)
      assert_kind_of(Integer, texture_id)
      refute_equal(0, texture_id)
    ensure
      model.active_view.release_texture(texture_id)
    end
    model.select_tool(nil)
    assert_raises(RuntimeError) do
      model.active_view.load_texture(image_rep)
    end
  end

  def test_load_texture_without_ruby_tool
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    skip("Changed in SU2023.0") if Sketchup.version.to_f >= 23.0
    image_rep = get_image_rep('test_small.jpg')
    assert_raises(RuntimeError) do
      Sketchup.active_model.active_view.load_texture(image_rep)
    end
  end

  def test_load_texture_with_ruby_tool_su2022_1
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    begin
      model.select_tool(TextureTool.new)
      image_rep = get_image_rep('test_small.jpg')
      texture_id = model.active_view.load_texture(image_rep)
      assert_kind_of(Integer, texture_id)
      refute_equal(0, texture_id)
    ensure
      model.active_view.release_texture(texture_id)
    end
    model.select_tool(nil)
    texture_id = model.active_view.load_texture(image_rep)
    model.active_view.release_texture(texture_id)
  end

  def test_load_texture_without_ruby_tool_su2022_1
    skip("Changed in SU2023.0") if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    begin
      image_rep = get_image_rep('test_small.jpg')
      texture_id = model.active_view.load_texture(image_rep)
      assert_kind_of(Integer, texture_id)
      refute_equal(0, texture_id)
    ensure
      model.active_view.release_texture(texture_id) if texture_id
    end
  end

  def test_load_texture_auto_release_by_model_without_cleanup
    skip("Changed in SU2023.0") if Sketchup.version.to_f < 23.0
    # This test deliberately doesn't release the loaded texture in order to
    # test the model clean up code.
    model = Sketchup.active_model
    image_rep = get_image_rep('test_small.jpg')
    texture_id = model.active_view.load_texture(image_rep)
    assert_kind_of(Integer, texture_id)
    refute_equal(0, texture_id)
    discard_all_models
  end

  def test_load_texture_invalid_image_rep
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
  end

  def test_load_texture_invalid_argument_type_nil
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
    assert_raises(TypeError) do
      model.active_view.load_texture(nil)
    end
  end

  def test_load_texture_invalid_argument_type_integer
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
    assert_raises(TypeError) do
      model.active_view.load_texture(123)
    end
  end

  def test_load_texture_invalid_argument_type_string
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
    assert_raises(TypeError) do
      model.active_view.load_texture('123')
    end
  end

  def test_load_texture_too_many_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
    image_rep = get_image_rep('test_small.jpg')
    assert_raises(ArgumentError) do
      model.active_view.load_texture(image_rep, '123')
    end
  end

  def test_load_texture_too_few_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
    assert_raises(ArgumentError) do
      model.active_view.load_texture
    end
  end


  # ========================================================================== #
  # method Sketchup::View.release_texture

  def test_release_texture_valid_texture_id
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
    image_rep = get_image_rep('test_small.jpg')
    texture_id = model.active_view.load_texture(image_rep)

    assert(model.active_view.release_texture(texture_id))
    refute(model.active_view.release_texture(texture_id))
  end

  def test_release_texture_invalid_texture_id_zero
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    refute(model.active_view.release_texture(0))
  end

  def test_release_texture_invalid_texture_id
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    refute(model.active_view.release_texture(10))
  end

  def test_release_texture_invalid_texture_id_negative
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    refute(model.active_view.release_texture(-10))
  end

  def test_release_texture_invalid_argument_nil
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    assert_raises(TypeError) do
      model.active_view.release_texture(nil)
    end
  end

  def test_release_texture_invalid_argument_string
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    assert_raises(TypeError) do
      model.active_view.release_texture('10')
    end
  end

  def test_release_texture_too_many_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.select_tool(TextureTool.new)
    image_rep = get_image_rep('test_small.jpg')
    texture_id = model.active_view.load_texture(image_rep)

    assert_raises(ArgumentError) do
      model.active_view.release_texture(texture_id, 10)
    end
  end

  def test_release_texture_too_few_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    assert_raises(ArgumentError) do
      model.active_view.release_texture
    end
  end


  # ========================================================================== #
  # method Sketchup::View.draw_text

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

  def test_draw_text_invalid_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw_text()
    end
  end

  def test_draw_text_invalid_arguments_one
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.draw_text(ORIGIN)
    end
  end

  def test_draw_text_invalid_arguments_three
    skip("Optional argument added in SU2016") if Sketchup.version.to_i >= 16
    assert_raises(TypeError) do
      Sketchup.active_model.active_view.draw_text(ORIGIN, "Test", 123)
    end
  end

  def test_draw_text_invalid_arguments_four
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

  def test_draw_text_option_vertical_align_bounds_top
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", vertical_align: TextVerticalAlignBoundsTop)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_vertical_align_baseline
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", vertical_align: TextVerticalAlignBaseline)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_vertical_align_cap_height
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", vertical_align: TextVerticalAlignCapHeight)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_vertical_align_center
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.draw_text(ORIGIN, "Test", vertical_align: TextVerticalAlignCenter)
    assert_equal(view, result)
    view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_vertical_align_invalid_integer_less_than
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.draw_text(ORIGIN, "Test", vertical_align: -1)
    end
  end

  def test_draw_text_option_vertical_align_invalid_integer_higher_than
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.draw_text(ORIGIN, "Test", vertical_align: 4)
    end
  end

  def test_draw_text_option_vertical_align_invalid_symbol
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", vertical_align: :foobar)
    end
  end

  def test_draw_text_option_vertical_align_invalid_argument
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.draw_text(ORIGIN, "Test", vertical_align: ORIGIN)
    end
  end


  # ========================================================================== #
  # method Sketchup::View.write_image

  def assert_image_written(*args)
    view = Sketchup.active_model.active_view
    result = view.write_image(*args)

    assert(result, 'unexpected return value')
    assert(File.exist?(temp_file), 'no write written')
    refute(File.size(temp_file).zero?, 'file written is zero size')

    return unless defined?(Sketchup::ImageRep)
    image = Sketchup::ImageRep.new(temp_file)
    yield(view, image)
  end

  def test_write_image_options_array
    model = start_with_empty_model
    load_test_style(model, '07Architectural Design Style.style')
    model.rendering_options['DrawHorizon'] = false
    camera = Sketchup::Camera.new([0, 0, 10], ORIGIN, Y_AXIS)
    model.active_view.camera = camera
    options = {
      :filename => temp_file,
      :width => 400,
      :height => 200,
      :antialias => true,
      :compression => 0.5,
      :transparent => true,
    }
    assert_image_written(options) do |view, image|
      assert_equal(options[:width], image.width)
      assert_equal(options[:height], image.height)
      assert_equal([0, 0, 0, 0], image.colors.first.to_a, "Filename: #{temp_file}") # transparency
      # TODO(thomthom): Compression
      # TODO(thomthom): Antialias
    end
  end

  def test_write_image_too_few_argument
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.write_image
    end
  end

  def test_write_image_options_scale_factor
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    model = start_with_empty_model
    load_test_style(model, '07Architectural Design Style.style')
    model.rendering_options['DrawHorizon'] = false
    camera = Sketchup::Camera.new([0, 0, 10], ORIGIN, Y_AXIS)
    model.active_view.camera = camera
    options = {
      :filename => temp_file,
      :width => 400,
      :height => 200,
      :antialias => true,
      :transparent => true,
      :scale_factor => 4,
    }
    assert_image_written(options) do |view, image|
      assert_equal(options[:width], image.width)
      assert_equal(options[:height], image.height)
      assert_equal([0, 0, 0, 0], image.colors.first.to_a, "Filename: #{temp_file}") # transparency
      # TODO(thomthom): Until we can reliably export a viewport across
      # platforms and viewport sizes, manually verify line scale.
    end
  end

  def test_write_image_options_invalid_scale_factor
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    view = Sketchup.active_model.active_view
    [0.0, -2.0, 2000.0].each { |value|
      assert_raises(ArgumentError, "scale_factor: #{value}") do
        view.write_image(filename: temp_file, scale_factor: value)
      end
    }
  end

  def test_write_image_legacy_one_argument
    assert_image_written(temp_file) do |view, image|
      assert_equal(view.vpwidth, image.width)
      assert_equal(view.vpheight, image.height)
    end
  end

  def test_write_image_legacy_two_argument
    assert_image_written(temp_file, 300) do |view, image|
      assert_equal(300, image.width)
      assert_equal(view.vpheight, image.height)
    end
  end

  def test_write_image_legacy_three_argument
    assert_image_written(temp_file, 300, 200) do |view, image|
      assert_equal(300, image.width)
      assert_equal(200, image.height)
    end
  end

  def test_write_image_legacy_four_argument
    antialias = true
    assert_image_written(temp_file, 300, 200, antialias) do |view, image|
      assert_equal(300, image.width)
      assert_equal(200, image.height)
      # TODO(thomthom): Can we check some pixels to verify image is anti-aliased?
    end
  end

  def test_write_image_legacy_five_argument
    antialias = true
    compression = 0.1
    assert_image_written(temp_file, 300, 200, antialias, compression) do |view, image|
      assert_equal(300, image.width)
      assert_equal(200, image.height)
      # TODO(thomthom): Can we check some pixels to verify compression is not
      #   the same as default? Maybe check JPEG image data?
    end
  end

  def test_write_image_legacy_too_many_argument
    skip("Fixed in SU2019") if Sketchup.version.to_i < 19
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.write_image(temp_file, 300, 200, true, 0.1, true)
    end
  end


  # ========================================================================== #
  # method Sketchup::View.text_bounds

  def test_text_bounds
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test")
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_alignment_center
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    position = [200, 300]
    result = view.text_bounds(position, "Test", align: TextAlignCenter )
    assert_kind_of(Geom::Bounds2d, result)
    assert(result.upper_left.x < position.x)
  end

  def test_text_bounds_alignment_right
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    position = [200, 300]
    result = view.text_bounds(position, "Test", align: TextAlignRight )
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(result.lower_right.x, position.x)
  end

  def test_text_bounds_alignment_baseline_and_cap_height
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    position = [200, 300]
    bounds_baseline = view.text_bounds(position, "Test",
      vertical_align: TextVerticalAlignBaseline)
    bounds_cap_height = view.text_bounds(position, "Test",
      vertical_align: TextVerticalAlignCapHeight)
    assert(bounds_baseline.upper_left.y < position.y, "baseline < y")
    assert(bounds_cap_height.upper_left.y < position.y, "cap_height < y")
    assert(bounds_baseline.upper_left.y < bounds_cap_height.upper_left.y,
      "baseline < cap_height")
  end

  def test_text_bounds_invalid_argument_position
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.text_bounds("FooBar", "Test")
    end
  end

  def test_text_bounds_invalid_arguments_zero
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.text_bounds()
    end
  end

  def test_text_bounds_invalid_arguments_one
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.text_bounds(ORIGIN)
    end
  end

  def test_text_bounds_invalid_arguments_three
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    assert_raises(TypeError) do
      Sketchup.active_model.active_view.text_bounds(ORIGIN, "Test", 123)
    end
  end

  def test_text_bounds_invalid_arguments_four
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_view.text_bounds(ORIGIN, "Test", 123, 456)
    end
  end

  def test_text_bounds_options_argument
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", {})
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_options_invalid_argument
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.text_bounds(ORIGIN, "Test", ORIGIN)
    end
  end

  def test_text_bounds_option_font
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    options = {
      :font => "Arial"
    }
    result = view.text_bounds(ORIGIN, "Test", options)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_font_bogus_name
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    options = {
      :font => "IamNotAFontButShouldNotCrash"
    }
    result = view.text_bounds(ORIGIN, "Test", options)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_font_long_name
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    options = {
      :font => "ThisFontNameIsTooLongForWindows01234"
    }
    if Sketchup.platform == :platform_osx
      result = view.text_bounds(ORIGIN, "Test", options)
      assert_kind_of(Geom::Bounds2d, result)
      assert_equal(ORIGIN_2D, result.upper_left)
      assert(result.width > 0)
      assert(result.height > 0)
    else
      assert_raises(ArgumentError) do
        view.text_bounds(ORIGIN, "Test", options)
      end
    end
  end

  def test_text_bounds_option_font_name_unicode
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    options = {
      :font => "Tæsting てすと"
    }
    result = view.text_bounds(ORIGIN, "てすと", options)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_font_invalid_argument
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.text_bounds(ORIGIN, "Test", font: ORIGIN)
    end
  end

  def test_text_bounds_option_size
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", size: 20)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_size_zero
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", size: 0)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert_equal(0, result.width)
    assert_equal(0, result.height)
  end

  def test_text_bounds_option_size_invalid_argument
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.text_bounds(ORIGIN, "Test", size: "FooBar")
    end
  end

  def test_text_bounds_option_italic
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", italic: true)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_bold
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", bold: true)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_align_left
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", align: TextAlignLeft)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_align_center
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", align: TextAlignCenter)
    assert_kind_of(Geom::Bounds2d, result)
    assert(result.upper_left.x < 0)
    assert(result.upper_left.y == 0)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_align_right
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", align: TextAlignRight)
    assert_kind_of(Geom::Bounds2d, result)
    assert(result.upper_left.x < 0)
    assert(result.upper_left.y == 0)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_align_invalid_integer_less_than
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.text_bounds(ORIGIN, "Test", align: -1)
    end
  end

  def test_text_bounds_option_align_invalid_integer_higher_than
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.text_bounds(ORIGIN, "Test", align: 3)
    end
  end

  def test_text_bounds_option_align_invalid_symbol
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.text_bounds(ORIGIN, "Test", align: :foobar)
    end
  end

  def test_text_bounds_option_align_invalid_argument
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.text_bounds(ORIGIN, "Test", align: ORIGIN)
    end
  end

  def test_text_bounds_option_vertical_align_bounds_top
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", vertical_align: TextVerticalAlignBoundsTop)
    assert_kind_of(Geom::Bounds2d, result)
    assert_equal(ORIGIN_2D, result.upper_left)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_vertical_align_baseline
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", vertical_align: TextVerticalAlignBaseline)
    assert_kind_of(Geom::Bounds2d, result)
    assert(result.upper_left.x == 0)
    assert(result.upper_left.y < 0)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_vertical_align_cap_height
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", vertical_align: TextVerticalAlignCapHeight)
    assert_kind_of(Geom::Bounds2d, result)
    assert(result.upper_left.x == 0)
    assert(result.upper_left.y < 0)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_vertical_align_center
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    result = view.text_bounds(ORIGIN, "Test", vertical_align: TextVerticalAlignCenter)
    assert_kind_of(Geom::Bounds2d, result)
    assert(result.upper_left.x == 0)
    assert(result.upper_left.y < 0)
    assert(result.width > 0)
    assert(result.height > 0)
  end

  def test_text_bounds_option_vertical_align_invalid_integer_less_than
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.text_bounds(ORIGIN, "Test", vertical_align: -1)
    end
  end

  def test_text_bounds_option_vertical_align_invalid_integer_higher_than
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(ArgumentError) do
      view.text_bounds(ORIGIN, "Test", vertical_align: 4)
    end
  end

  def test_text_bounds_option_vertical_align_invalid_symbol
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.text_bounds(ORIGIN, "Test", vertical_align: :foobar)
    end
  end

  def test_text_bounds_option_vertical_align_invalid_argument
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    view = Sketchup.active_model.active_view
    assert_raises(TypeError) do
      view.text_bounds(ORIGIN, "Test", vertical_align: ORIGIN)
    end
  end

end # class

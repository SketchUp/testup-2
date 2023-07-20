# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi (jinyi@sketchup.com)


require "testup/testcase"


# class Sketchup::ImageRep
class TC_Sketchup_ImageRep < TestUp::TestCase

  IS_WIN = Sketchup.platform == :platform_win
  IS_MAC = Sketchup.platform == :platform_osx

  def self.setup_testcase
    discard_all_models
  end

  def setup
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model()
    @image_rep = Sketchup::ImageRep.new
    @filename = get_test_file("test_small.jpg")
    @image_rep.load_file(@filename)

    @image_rep_quad = Sketchup::ImageRep.new
    @filename_quad = get_test_file("myquad.png")
    @image_rep_quad.load_file(@filename_quad)
  end

  def teardown
    # ...
  end


  def get_test_file(filename)
    File.join(__dir__, "TC_Sketchup_ImageRep", filename)
  end

  # Reorder bytes into RGB order regardless of platform.
  def rgb_bytes(bytes)
    if IS_MAC
      reverse_rgb_bytes(bytes)
    else
      bytes
    end
  end

  # Reorder bytes into BGR order regardless of platform.
  def bgr_bytes(bytes)
    if IS_WIN
      reverse_rgb_bytes(bytes)
    else
      bytes
    end
  end

  def reverse_rgb_bytes(bytes)
    bytes.each_slice(3).map { |rgb| rgb.reverse }.flatten
  end


  def test_bits_per_pixel
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    bits_per_pixel = @image_rep.bits_per_pixel
    assert_equal(24, bits_per_pixel)
    assert_kind_of(Integer, bits_per_pixel)

    # caffeine_meme_32bit.png:
    # PNG image data, 604 x 453, 8-bit/color RGBA, non-interlaced
    tempfile = get_test_file("caffeine_meme_32bit.png")
    temp = Sketchup::ImageRep.new(tempfile)
    bits_per_pixel = temp.bits_per_pixel
    assert_equal(32, bits_per_pixel)

    # grayscale_fish.png:
    # PNG image data, 640 x 400, 8-bit gray+alpha, non-interlaced
    tempfile = get_test_file("grayscale_fish.png")
    temp = Sketchup::ImageRep.new(tempfile)
    bits_per_pixel = temp.bits_per_pixel
    assert_equal(32, bits_per_pixel)

    # caffeine_meme_1bit.png:
    # PNG image data, 604 x 453, 1-bit colormap, non-interlaced
    tempfile = get_test_file("caffeine_meme_1bit.png")
    temp = Sketchup::ImageRep.new(tempfile)
    bits_per_pixel = temp.bits_per_pixel
    assert_equal(24, bits_per_pixel)
  end

  def test_bits_per_pixel_too_many_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @image_rep.bits_per_pixel(nil)
    end
  end

  def test_height
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    height = @image_rep.height
    assert_equal(337, height)
    assert_kind_of(Integer, height)
  end

  def test_height_too_many_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @image_rep.height(nil)
    end
  end

  def test_width
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    width = @image_rep.width
    assert_equal(656, width)
    assert_kind_of(Integer, width)
  end

  def test_width_too_many_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @image_rep.width(nil)
    end
  end

  def test_width_no_image_loaded
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    empty = Sketchup::ImageRep.new
    assert_equal(0, empty.width)
  end

  def test_height_no_image_loaded
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    empty = Sketchup::ImageRep.new
    assert_equal(0, empty.height)
  end

  def test_bits_per_pixel_no_image_loaded
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    empty = Sketchup::ImageRep.new
    assert_equal(0, empty.bits_per_pixel)
  end

  def test_row_padding_no_image_loaded
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    empty = Sketchup::ImageRep.new
    assert_equal(0, empty.row_padding)
  end

  def test_data_no_image_loaded
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    empty = Sketchup::ImageRep.new
    assert_equal(nil, empty.data)
  end

  def test_color_at_uv_no_image_loaded
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    empty = Sketchup::ImageRep.new
    assert_equal(nil, empty.color_at_uv(0.1, 0.1))
  end

  def test_colors_no_image_loaded
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    empty = Sketchup::ImageRep.new
    assert_equal(nil, empty.colors)
  end

  def test_initialize
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_kind_of(Sketchup::ImageRep, @image_rep)
    assert_equal(663216, @image_rep.size)
    assert_equal(24, @image_rep.bits_per_pixel)

    temp = Sketchup::ImageRep.new
    assert_kind_of(Sketchup::ImageRep, temp)
    assert_equal(0, temp.width)
    assert_equal(0, temp.height)
  end

  def test_initialize_filename
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    temp = Sketchup::ImageRep.new(@filename)
    assert_kind_of(Sketchup::ImageRep, temp)
    assert_equal(656, temp.width)
    assert_equal(337, temp.height)
  end

  def test_initialize_too_many_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      Sketchup::ImageRep.new(@filename, @filename)
    end
  end

  def test_initialize_invalid_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(TypeError) do
      Sketchup::ImageRep.new(1234)
    end

    assert_raises(TypeError) do
      Sketchup::ImageRep.new(@image_rep)
    end
  end

  def su42482?
    IS_WIN && Sketchup.version.to_f < 19.2
  end

  def test_initialize_invalid_arguments_empty_file
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    skip("Bugged under Windows (SU-42482)") if su42482?
    tempfile = get_test_file("emptyfile")
    assert_raises(ArgumentError) do
      Sketchup::ImageRep.new(tempfile)
    end
  end

  def test_initialize_corrupt_image
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    skip("Bugged under Windows (SU-42482)") if su42482?
    tempfile = get_test_file("corrupt_pikachu.jpg")
    assert_raises(ArgumentError) do
      Sketchup::ImageRep.new(tempfile)
    end
  end

  def test_load_file
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    temp = Sketchup::ImageRep.new
    assert_equal(0, temp.size)
    temp.load_file(@filename)
    assert_equal(663216, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_load_file_too_many_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @image_rep.load_file(@filename, @filename)
    end
  end

  def test_load_file_invalid_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(TypeError) do
      @image_rep.load_file(nil)
    end

    assert_raises(TypeError) do
      @image_rep.load_file(1234)
    end
  end

  def test_size
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_equal(663216, @image_rep.size)
    assert_kind_of(Integer, @image_rep.size)
  end

  def test_size_too_many_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @image_rep.size(nil)
    end
  end

  def test_data
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    data = @image_rep.data
    data_size = @image_rep.size
    assert_equal(data_size, data.size)
    assert_kind_of(String, data)
    bytes = bgr_bytes(data.bytes)
    assert_equal(207, bytes[0])
    assert_equal(208, bytes[data_size / 2])
    assert_equal(180, bytes[data_size - 1])
  end

  def test_data_16x16
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    data = temp.data
    data_size = temp.size
    assert_equal(data_size, data.size)
    assert_kind_of(String, data)
    bgr_bytes = [
    171, 55,  98,  248, 242, 227, 253, 252, 234, 253, 252, 234, 253, 252, 234,
    253, 252, 234, 254, 252, 232, 252, 252, 235, 251, 245, 218, 249, 236, 174,
    251, 237, 120, 198, 107, 85,  182, 80,  112, 243, 240, 219, 253, 252, 234,
    253, 252, 234, 188, 82,  84,  250, 239, 210, 253, 253, 232, 253, 252, 230,
    253, 252, 231, 253, 251, 232, 251, 252, 233, 247, 225, 157, 251, 237, 108,
    253, 238, 102, 252, 239, 109, 208, 143, 141, 251, 249, 229, 253, 252, 233,
    253, 252, 233, 253, 252, 233, 252, 235, 88,  247, 225, 147, 253, 253, 235,
    253, 253, 230, 252, 249, 229, 250, 239, 204, 248, 223, 125, 253, 238, 89,
    252, 231, 89,  249, 226, 114, 246, 232, 188, 255, 255, 237, 252, 252, 231,
    253, 252, 231, 253, 252, 231, 253, 252, 231, 252, 232, 71,  246, 211, 88,
    253, 254, 237, 244, 230, 191, 249, 220, 85,  253, 231, 73,  253, 231, 71,
    253, 226, 71,  241, 181, 87,  248, 247, 225, 253, 250, 227, 253, 252, 226,
    253, 253, 229, 253, 253, 229, 253, 253, 229, 253, 253, 229, 253, 227, 48,
    249, 214, 46,  240, 201, 134, 251, 223, 44,  254, 226, 49,  254, 225, 49,
    253, 225, 53,  223, 171, 41,  253, 229, 49,  245, 212, 69,  246, 216, 137,
    231, 164, 117, 243, 206, 136, 239, 207, 154, 247, 232, 209, 253, 254, 229,
    242, 200, 49,  246, 193, 30,  250, 217, 24,  253, 221, 20,  254, 221, 18,
    254, 221, 18,  215, 170, 63,  115, 51,  79,  219, 175, 32,  251, 223, 21,
    239, 183, 26,  245, 199, 23,  238, 181, 32,  247, 194, 23,  228, 143, 28,
    243, 218, 147, 244, 207, 114, 251, 217, 2,   252, 218, 0,   253, 219, 0,
    253, 218, 0,   253, 218, 0,   235, 192, 9,   158, 95,  23,  234, 197, 9,
    239, 36,  3,   230, 66,  9,   246, 205, 5,   253, 220, 0,   253, 222, 8,
    242, 198, 3,   248, 211, 6,   244, 229, 195, 250, 206, 11,  246, 205, 3,
    254, 211, 1,   248, 204, 1,   255, 213, 2,   250, 205, 4,   255, 221, 2,
    236, 178, 6,   240, 0,   1,   234, 3,   3,   249, 206, 2,   253, 211, 1,
    244, 187, 2,   220, 122, 9,   238, 172, 5,   248, 242, 208, 249, 193, 18,
    133, 82,  46,  184, 130, 5,   255, 211, 3,   204, 125, 3,   189, 23,  5,
    243, 200, 9,   253, 210, 1,   243, 167, 3,   244, 182, 3,   253, 208, 2,
    250, 207, 1,   237, 172, 3,   229, 142, 3,   233, 129, 5,   253, 254, 217,
    232, 183, 114, 124, 76,  0,   180, 128, 3,   237, 165, 4,   132, 0,   5,
    244, 12,  5,   223, 81,  5,   252, 195, 2,   254, 192, 1,   253, 191, 1,
    253, 193, 1,   253, 196, 1,   233, 160, 3,   242, 150, 3,   242, 131, 1,
    252, 250, 211, 252, 249, 209, 217, 130, 0,   217, 125, 2,   255, 186, 2,
    232, 148, 4,   225, 15,  5,   236, 26,  4,   246, 171, 3,   254, 181, 1,
    251, 165, 1,   254, 180, 1,   255, 182, 1,   255, 186, 1,   214, 90,  2,
    224, 100, 2,   252, 249, 206, 250, 255, 204, 203, 60,  43,  226, 0,   1,
    217, 88,  3,   253, 175, 1,   240, 158, 1,   227, 100, 2,   248, 165, 2,
    251, 153, 2,   230, 95,  2,   255, 171, 1,   253, 169, 1,   254, 170, 2,
    229, 121, 3,   223, 73,  0,   251, 249, 201, 251, 239, 198, 237, 230, 171,
    186, 51,  31,  198, 70,  4,   251, 150, 1,   249, 164, 1,   251, 154, 1,
    250, 134, 1,   234, 78,  3,   233, 70,  3,   214, 112, 1,   253, 153, 2,
    253, 149, 1,   242, 150, 2,   195, 126, 81,  251, 249, 200, 248, 249, 194,
    251, 244, 200, 253, 255, 191, 242, 234, 180, 196, 127, 66,  234, 107, 0,
    242, 126, 1,   254, 141, 1,   251, 139, 3,   225, 110, 3,   206, 44,  3,
    187, 65,  0,   244, 129, 0,   210, 108, 5,   242, 230, 171, 251, 250, 196,
    251, 250, 197, 251, 250, 197, 251, 250, 198, 251, 246, 190, 243, 232, 174,
    188, 96,  33,  245, 128, 3,   253, 129, 2,   254, 124, 1,   252, 126, 1,
    203, 86,  0,   217, 203, 128, 211, 191, 136, 237, 228, 178, 252, 250, 197,
    251, 249, 193, 251, 249, 193, 251, 249, 193, 251, 249, 193, 255, 254, 190,
    140, 85,  41,  198, 85,  5,   209, 51,  3,   196, 58,  3,   220, 102, 2,
    250, 116, 1,   209, 90,  0,   240, 227, 171, 251, 248, 182, 251, 249, 192,
    251, 249, 193
    ]
    bytes = IS_WIN ? reverse_rgb_bytes(bgr_bytes) : bgr_bytes

    assert_equal(bytes, data.bytes)
  end

  def test_data_invalid_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @image_rep.data(nil)
    end
  end

  def test_row_padding
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    row_padding = @image_rep.row_padding
    assert_equal(0, row_padding)
    assert_kind_of(Integer, row_padding)

    tempfile = get_test_file("pikachu_17x17_rgb.bmp")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(1, temp.row_padding)

    tempfile = get_test_file("deathstar.bmp")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(2, temp.row_padding)
  end

  def test_row_padding_too_many_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @image_rep.row_padding(nil)
    end
  end

  def test_save_file
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    # using png for lossless compression
    # using jpg could possibly have byte differences
    filename = get_test_file("test_small_copy.png")
    @image_rep.save_file(filename)
    temp = Sketchup::ImageRep.new(filename)
    assert_equal(@image_rep.size, temp.size)
    assert_equal(@image_rep.data, temp.data)
  ensure
    File.delete(filename) if File.exist?(filename)
  end

  def test_save_file_invalid_arguments
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(TypeError) do
      @image_rep.save_file(nil)
    end

    assert_raises(TypeError) do
      @image_rep.save_file(1234)
    end

    assert_raises(TypeError) do
      @image_rep.save_file(@image_rep)
    end

    assert_raises(RuntimeError) do
      @image_rep.save_file("cat/goes/woof/dog/goes/meow/but/jk/copy.png")
    end
  end

  def test_load_file_jpg_happy_path
    tempfile = get_test_file("pikachu_16x16.jpg")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(16, temp.width)
    assert_equal(16, temp.height)
    assert_equal(768, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_load_file_bmp_happy_path
    tempfile = get_test_file("pikachu_16x16.bmp")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(16, temp.width)
    assert_equal(16, temp.height)
    assert_equal(768, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_load_file_tif_happy_path
    tempfile = get_test_file("pikachu_16x16.tif")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(16, temp.width)
    assert_equal(16, temp.height)
    assert_equal(768, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_load_file_png_happy_path
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(16, temp.width)
    assert_equal(16, temp.height)
    assert_equal(768, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_load_file_gif_happy_path
    tempfile = get_test_file("pikachu_16x16.gif")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(16, temp.width)
    assert_equal(16, temp.height)
    assert_equal(768, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_load_file_tga_happy_path
    tempfile = get_test_file("pikachu_16x16.tga")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(16, temp.width)
    assert_equal(16, temp.height)
    assert_equal(768, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_load_file_psd_happy_path
    tempfile = get_test_file("pikachu_16x16.psd")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_equal(16, temp.width)
    assert_equal(16, temp.height)
    assert_equal(768, temp.size)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_colors
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    width = temp.width
    height = temp.height
    size = width * height

    colors = temp.colors
    assert_equal(size, colors.size)
    assert_kind_of(Array, colors)

    color = colors[0]
    assert_equal([171,  55, 98, 255], color.to_a)
    assert_kind_of(Sketchup::Color, color)

    color = colors[size / 2]
    assert_equal([248, 242, 208, 255], color.to_a)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_colors_too_many_arguments
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_raises(ArgumentError) do
      temp.colors(nil)
    end
  end

  def test_color_at_uv
    color = @image_rep_quad.color_at_uv(0.25, 0.75)
    expected = Sketchup::Color.new(0, 0, 255, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)

    color = @image_rep_quad.color_at_uv(0.75, 0.75)
    expected = Sketchup::Color.new(0, 255, 0, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)

    color = @image_rep_quad.color_at_uv(0.25, 0.25)
    expected = Sketchup::Color.new(185, 0, 255, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)

    color = @image_rep_quad.color_at_uv(0.75, 0.25)
    expected = Sketchup::Color.new(255, 0, 0, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)
  end

  def test_color_at_uv_optional_argument
    color = @image_rep_quad.color_at_uv(0.25, 0.75, true)
    expected = Sketchup::Color.new(0, 0, 255, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)

    color = @image_rep_quad.color_at_uv(0.75, 0.75, false)
    expected = Sketchup::Color.new(0, 255, 0, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)

    color = @image_rep_quad.color_at_uv(0.25, 0.25, nil)
    expected = Sketchup::Color.new(185, 0, 255, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)

    color = @image_rep_quad.color_at_uv(0.75, 0.25, nil)
    expected = Sketchup::Color.new(255, 0, 0, 255)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(expected.to_a, color.to_a)
  end

  def test_color_at_uv_too_many_arguments
    assert_raises(ArgumentError) do
      @image_rep_quad.color_at_uv(0.1, 0.2, 0.3, 0.4)
    end
  end

  def test_color_at_uv_not_enough_arguments
    assert_raises(ArgumentError) do
      @image_rep_quad.color_at_uv(0.1)
    end
  end

  def test_color_at_uv_invalid_arguments
    assert_raises(TypeError) do
      @image_rep_quad.color_at_uv(nil, 0.2)
    end

    assert_raises(TypeError) do
      @image_rep_quad.color_at_uv(0.1, nil)
    end

    assert_raises(TypeError) do
      @image_rep_quad.color_at_uv("0.1", 0.2)
    end

    assert_raises(TypeError) do
      @image_rep_quad.color_at_uv(0.1, "0.2")
    end
  end

  def test_set_data
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    temp.set_data(1, 1, 8, 0, "\x00")
    assert_equal([0], temp.data.bytes)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_set_data_valid_bpp
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    temp.set_data(1, 1, 8, 3, "\x00\x00\x00\x00")
    assert_equal([0, 0, 0, 0], temp.data.bytes)
    assert_kind_of(Sketchup::ImageRep, temp)

    temp.set_data(1, 1, 24, 1, "\x00\x00\x00\x00")
    assert_equal([0, 0, 0, 0], temp.data.bytes)
    assert_kind_of(Sketchup::ImageRep, temp)

    temp.set_data(1, 1, 32, 0, "\x00\x00\x00\x00")
    assert_equal([0, 0, 0, 0], temp.data.bytes)
    assert_kind_of(Sketchup::ImageRep, temp)
  end

  def test_set_data_invalid_arguments
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_raises(TypeError) do
      temp.set_data("1", 1, 8, 0, "\xff")
    end

    assert_raises(TypeError) do
      temp.set_data(1, "1", 8, 0, "\xff")
    end

    assert_raises(TypeError) do
      temp.set_data(1, 1, "8", 0, "\xff")
    end

    assert_raises(TypeError) do
      temp.set_data(1, 1, 8, "0", "\xff")
    end

    assert_raises(TypeError) do
      temp.set_data(1, 1, 8, 0, 0)
    end

    assert_raises(ArgumentError) do
      temp.set_data(1, 1, 16, "\xff")
    end
  end

  def test_set_data_negative_inputs
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_raises(RangeError) do
      temp.set_data(-1, 1, 8, 0, "\xff")
    end

    assert_raises(RangeError) do
      temp.set_data(1, -1, 8, 0, "\xff")
    end

    assert_raises(RangeError) do
      temp.set_data(1, 1, -8, 0, "\xff")
    end

    assert_raises(RangeError) do
      temp.set_data(1, 1, 8, -1, "\xff")
    end
  end

  def test_set_data_invalid_row_padding
    tempfile = get_test_file("pikachu_16x16.png")
    temp = Sketchup::ImageRep.new(tempfile)
    assert_raises(ArgumentError) do
      temp.set_data(1, 1, 32, 1, "\x00\x00\x00\x00")
    end
  end
end # class

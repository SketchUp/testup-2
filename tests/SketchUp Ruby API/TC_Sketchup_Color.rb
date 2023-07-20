# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi


require "testup/testcase"


# class Sketchup::Color
class TC_Sketchup_Color < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    # ...
  end

  def teardown
    # ...
  end

  def test_initialize
    color = Sketchup::Color.new
    assert_equal(0, color.red)
    assert_equal(0, color.green)
    assert_equal(0, color.blue)
    assert_equal(255, color.alpha)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_initialize_from_name
    color_from_name = Sketchup::Color.new("AliceBlue")
    assert_equal(240, color_from_name.red)
    assert_equal(248, color_from_name.green)
    assert_equal(255, color_from_name.blue)
    assert_kind_of(Sketchup::Color, color_from_name)
  end

  def test_initialize_from_float
    color_from_float = Sketchup::Color.new(0.33, 0.25, 0.5)
    assert_equal(84, color_from_float.red)
    assert_equal(63, color_from_float.green)
    assert_equal(127, color_from_float.blue)
    assert_equal(255, color_from_float.alpha)
    assert_kind_of(Sketchup::Color, color_from_float)

    color_from_float_mix = Sketchup::Color.new(0.33, 63, 0.5)
    assert_equal(84, color_from_float_mix.red)
    assert_equal(63, color_from_float_mix.green)
    assert_equal(127, color_from_float_mix.blue)
    assert_equal(255, color_from_float_mix.alpha)
    assert_kind_of(Sketchup::Color, color_from_float_mix)
  end

  def test_initialize_from_rgba
    color_from_rgba = Sketchup::Color.new(240, 248, 255, 125)
    assert_equal(240, color_from_rgba.red)
    assert_equal(248, color_from_rgba.green)
    assert_equal(255, color_from_rgba.blue)
    assert_equal(125, color_from_rgba.alpha)
    assert_kind_of(Sketchup::Color, color_from_rgba)
  end

  def test_initialize_from_rgb
    color_from_rgb = Sketchup::Color.new(240, 248, 255)
    assert_equal(240, color_from_rgb.red)
    assert_equal(248, color_from_rgb.green)
    assert_equal(255, color_from_rgb.blue)
    assert_equal(255, color_from_rgb.alpha)
    assert_kind_of(Sketchup::Color, color_from_rgb)
  end

  def test_initialize_from_array_float_rgb
    color_from_float = Sketchup::Color.new([0.33, 0.25, 0.5])
    assert_equal(84, color_from_float.red)
    assert_equal(63, color_from_float.green)
    assert_equal(127, color_from_float.blue)
    assert_equal(255, color_from_float.alpha)
    assert_kind_of(Sketchup::Color, color_from_float)
  end

  def test_initialize_from_array_float_rgba
    color_from_float = Sketchup::Color.new([0.33, 0.25, 0.5, 0.1])
    assert_equal(84, color_from_float.red)
    assert_equal(63, color_from_float.green)
    assert_equal(127, color_from_float.blue)
    assert_equal(25, color_from_float.alpha)
    assert_kind_of(Sketchup::Color, color_from_float)
  end

  def test_initialize_from_array_rgba
    color_from_rgba = Sketchup::Color.new([240, 248, 255, 125])
    assert_equal(240, color_from_rgba.red)
    assert_equal(248, color_from_rgba.green)
    assert_equal(255, color_from_rgba.blue)
    assert_equal(125, color_from_rgba.alpha)
    assert_kind_of(Sketchup::Color, color_from_rgba)
  end

  def test_initialize_from_array_rgb
    color_from_rgb = Sketchup::Color.new([240, 248, 255])
    assert_equal(240, color_from_rgb.red)
    assert_equal(248, color_from_rgb.green)
    assert_equal(255, color_from_rgb.blue)
    assert_equal(255, color_from_rgb.alpha)
    assert_kind_of(Sketchup::Color, color_from_rgb)
  end

  def test_initialize_from_color
    color = Sketchup::Color.new(240, 248, 255)
    color_from_color = Sketchup::Color.new(color)
    assert_equal(color.to_a, color_from_color.to_a)
    refute(color.object_id == color_from_color.object_id)
    assert_kind_of(Sketchup::Color, color_from_color)
  end

  def test_initialize_from_integer
    color_from_integer = Sketchup::Color.new(16775408)
    assert_equal([240, 248, 255, 255], color_from_integer.to_a)
    assert_kind_of(Sketchup::Color, color_from_integer)
  end

  def test_initialize_too_many_arguments
    # expected behavior was that a argument error would be raised
    # but no error is raised when 5 arguments or more are passed
    # behavior changed in SU2018
    skip("Behavior change in SU2018") if Sketchup.version.to_i > 17
    color = Sketchup::Color.new(1, 2, 3, 4, 5)
    assert_equal(1, color.red)
    assert_equal(2, color.green)
    assert_equal(3, color.blue)
    assert_equal(4, color.alpha)
  end

  def test_initialize_too_many_arguments_SU2018
    skip("Behavior change in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError, "too many arguments") do
      Sketchup::Color.new(1, 2, 3, 4, 5)
    end
  end

  def test_initialize_invalid_argument
    assert_raises(TypeError, "argument with nil") do
      Sketchup::Color.new(nil)
    end

    assert_raises(ArgumentError, "array of size 1") do
      Sketchup::Color.new([1])
    end

    assert_raises(ArgumentError, "array of size 2") do
      Sketchup::Color.new([1, 2])
    end

    assert_raises(ArgumentError, "invalid name") do
      Sketchup::Color.new("HelloWorld")
    end
  end

  class CustomColor < Sketchup::Color; end
  def test_initialize_subclassed
    # Making sure we created the objects correctly so it can be sub-classed.
    CustomColor::new(12, 34, 56)
  end

  def test_alpha
    color = Sketchup::Color.new(240, 248, 255)
    alpha = color.alpha
    assert_equal(255, alpha)
    assert_kind_of(Sketchup::Color, color)
    assert_kind_of(Integer, alpha)
  end

  def test_alpha_Set
    color = Sketchup::Color.new(240, 248, 255)
    color.alpha = 150
    assert_equal(150, color.alpha)
  end

  def test_alpha_Set_invalid_arguments
    color = Sketchup::Color.new(240, 248, 255)
    assert_raises(TypeError, "argument with nil") do
      color.alpha = nil
    end

    assert_raises(ArgumentError, "number out of range") do
      color.alpha = 256
    end

    assert_raises(ArgumentError, "negative number") do
      color.alpha = -1
    end
  end

  def test_blend
    color1 = Sketchup::Color.new(240, 248, 255)
    color2 = Sketchup::Color.new("CornflowerBlue")
    color3 = color1.blend(color2, 0.5)
    assert_equal(170, color3.red)
    assert_equal(198, color3.green)
    assert_equal(246, color3.blue)
    assert_kind_of(Sketchup::Color, color3)
  end

  def test_blend_invalid_arguments
    color1 = Sketchup::Color.new(240, 248, 255)
    color2 = Sketchup::Color.new("CornflowerBlue")
    assert_raises(ArgumentError, "argument with nil") do
      color1.blend(nil)
    end

    assert_raises(TypeError, "argument with two colors") do
      color1.blend(color2, color1)
    end

    assert_raises(TypeError, "argument with 1 color and nil") do
      color1.blend(color2, nil)
    end
  end

  def test_blend_out_of_bounds
    # In the documentation it states the weight is between 0 and 1 based on
    # CColor::Blend class, however, no error is raised
    color1 = Sketchup::Color.new(240, 248, 255)
    color2 = Sketchup::Color.new("CornflowerBlue")
    assert_equal([0, 50, 219, 255], color1.blend(color2, -1).to_a)
    assert_equal([254, 255, 255, 255], color1.blend(color2, 1.1).to_a)
  end

  def test_blue
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal(255, color.blue)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_blue_Set
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal(255, color.blue)
    color.blue = 123
    assert_equal(123, color.blue)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_blue_Set_invalid_arguments
    color = Sketchup::Color.new(240, 248, 255)
    assert_raises(TypeError, "argument with nil") do
      color.blue = nil
    end

    assert_raises(TypeError, "argument with color") do
      color.blue = color
    end

    assert_raises(TypeError, "argument with string") do
      color.blue = "blue"
    end

    assert_raises(TypeError, "argument with array") do
      color.blue = [1]
    end

    assert_raises(ArgumentError, "out of bounds < 0") do
      color.blue = -1
    end

    assert_raises(ArgumentError, "out of bounds > 255") do
      color.blue = 256
    end
  end

  def test_green
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal(248, color.green)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_green_Set
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal(248, color.green)
    color.green = 123
    assert_equal(123, color.green)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_green_Set_invalid_arguments
    color = Sketchup::Color.new(240, 248, 255)
    assert_raises(TypeError, "argument with nil") do
      color.green = nil
    end

    assert_raises(TypeError, "argument with color") do
      color.green = color
    end

    assert_raises(TypeError, "argument with string") do
      color.green = "green"
    end

    assert_raises(TypeError, "argument with array") do
      color.green = [1]
    end

    assert_raises(ArgumentError, "out of bounds < 0") do
      color.green = -1
    end

    assert_raises(ArgumentError, "out of bounds > 255") do
      color.green = 256
    end
  end

  def test_red
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal(240, color.red)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_red_Set
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal(240, color.red)
    color.red = 123
    assert_equal(123, color.red)
    assert_kind_of(Sketchup::Color, color)
  end

  def test_red_Set_invalid_arguments
    color = Sketchup::Color.new(240, 248, 255)
    assert_raises(TypeError, "argument with nil") do
      color.red = nil
    end

    assert_raises(TypeError, "argument with color") do
      color.red = color
    end

    assert_raises(TypeError, "argument with string") do
      color.red = "red"
    end

    assert_raises(TypeError, "argument with array") do
      color.red = [1]
    end

    assert_raises(ArgumentError, "out of bounds < 0") do
      color.red = -1
    end

    assert_raises(ArgumentError, "out of bounds > 255") do
      color.red = 256
    end
  end

  def test_rgba_float
    color_from_rgba = Sketchup::Color.new(240, 248, 255, 125)
    assert_equal(240, color_from_rgba.red)
    assert_equal(248, color_from_rgba.green)
    assert_equal(255, color_from_rgba.blue)
    assert_equal(125, color_from_rgba.alpha)
    assert_kind_of(Sketchup::Color, color_from_rgba)

    color_from_rgba.red = 5.9
    color_from_rgba.green = 249.1
    color_from_rgba.blue = 10.5
    color_from_rgba.alpha = 0.1
    assert_equal(5, color_from_rgba.red)
    assert_equal(249, color_from_rgba.green)
    assert_equal(10, color_from_rgba.blue)
    assert_equal(25, color_from_rgba.alpha)
    assert_kind_of(Integer, color_from_rgba.red)
    assert_kind_of(Integer, color_from_rgba.green)
    assert_kind_of(Integer, color_from_rgba.blue)
  end

  def test_set_rgba_out_of_bounds_float
    color = Sketchup::Color.new(125, 125, 125, 125)
    color.red = -0.1
    color.green = -0.5
    color.blue = -0.99999
    assert_equal(0, color.red)
    assert_equal(0, color.green)
    assert_equal(0, color.blue)
    assert_raises(ArgumentError, "negative float for alpha") do
      color.alpha = -0.4
    end

    assert_raises(ArgumentError, "alpha is a float") do
      color.alpha = 12.3
    end
  end

  def test_names
    array_of_names = ["AliceBlue", "AntiqueWhite", "Aqua", "Aquamarine",
        "Azure", "Beige", "Bisque", "Black", "BlanchedAlmond", "Blue",
        "BlueViolet", "Brown", "BurlyWood", "CadetBlue", "Chartreuse",
        "Chocolate", "Coral", "CornflowerBlue", "Cornsilk", "Crimson", "Cyan",
        "DarkBlue", "DarkCyan", "DarkGoldenrod", "DarkGray", "DarkGreen",
        "DarkKhaki", "DarkMagenta", "DarkOliveGreen", "DarkOrange",
        "DarkOrchid", "DarkRed", "DarkSalmon", "DarkSeaGreen", "DarkSlateBlue",
        "DarkSlateGray", "DarkTurquoise", "DarkViolet", "DeepPink",
        "DeepSkyBlue", "DimGray", "DodgerBlue", "FireBrick", "FloralWhite",
        "ForestGreen", "Fuchsia", "Gainsboro", "GhostWhite", "Gold",
        "Goldenrod", "Gray", "Green", "GreenYellow", "Honeydew", "HotPink",
        "IndianRed", "Indigo", "Ivory", "Khaki", "Lavender", "LavenderBlush",
        "LawnGreen", "LemonChiffon", "LightBlue", "LightCoral", "LightCyan",
        "LightGoldenrodYellow", "LightGreen", "LightGrey", "LightPink",
        "LightSalmon", "LightSeaGreen", "LightSkyBlue", "LightSlateGray",
        "LightSteelBlue", "LightYellow", "Lime", "LimeGreen", "Linen",
        "Magenta", "Maroon", "MediumAquamarine", "MediumBlue", "MediumOrchid",
        "MediumPurple", "MediumSeaGreen", "MediumSlateBlue",
        "MediumSpringGreen", "MediumTurquoise", "MediumVioletRed",
        "MidnightBlue", "MintCream", "MistyRose", "Moccasin", "NavajoWhite",
        "Navy", "OldLace", "Olive", "OliveDrab", "Orange", "OrangeRed",
        "Orchid", "PaleGoldenrod", "PaleGreen", "PaleTurquoise",
        "PaleVioletRed", "PapayaWhip", "PeachPuff", "Peru", "Pink", "Plum",
        "PowderBlue", "Purple", "Red", "RosyBrown", "RoyalBlue", "SaddleBrown",
        "Salmon", "SandyBrown", "SeaGreen", "Seashell", "Sienna", "Silver",
        "SkyBlue", "SlateBlue", "SlateGray", "Snow", "SpringGreen", "SteelBlue",
        "Tan", "Teal", "Thistle", "Tomato", "Turquoise", "Violet", "Wheat",
        "White", "WhiteSmoke", "Yellow", "YellowGreen"]
    names = Sketchup::Color.names
    assert_kind_of(Array, names)
    assert_equal(140, names.size)
    array_of_names.each_with_index { |name, index|
      assert_equal(name, names[index])
    }
  end

  def test_names_invalid_arguments
    assert_raises(ArgumentError, "argument with nil") do
      Sketchup::Color.names(nil)
    end
  end

  def test_to_a
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal([240, 248, 255, 255], color.to_a)
    assert_kind_of(Array, color.to_a)
  end

  def test_to_a_too_many_arguments
    color = Sketchup::Color.new(240, 248, 255)
    assert_raises(ArgumentError, "argument with nil") do
      color.to_a(nil)
    end
  end

  def test_to_i
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal(16775408, color.to_i)
    assert_kind_of(Integer, color.to_i)
  end

  def test_to_i_too_many_arguments
    color = Sketchup::Color.new(240, 248, 255)
    assert_raises(ArgumentError, "argument with nil") do
      color.to_i(nil)
    end
  end

  def test_to_s
    color = Sketchup::Color.new(240, 248, 255)
    assert_equal("Color(240, 248, 255, 255)", color.to_s)
    assert_kind_of(String, color.to_s)
  end

  def test_to_s_too_many_arguments
    color = Sketchup::Color.new(240, 248, 255)
    assert_raises(ArgumentError, "argument with nil") do
      color.to_s(nil)
    end
  end

  def test_Operator_Equal_vs_same_color
    color = Sketchup::Color.new(240, 248, 255)
    assert(color == color)
  end

  def test_Operator_Equal_vs_similar_color_su2018
    skip("Added in SU2018") if Sketchup.version.to_i < 18
    color1 = Sketchup::Color.new(240, 248, 255)
    color2 = Sketchup::Color.new(240, 248, 255)
    assert(color1 == color2)
  end

  def test_Operator_Equal_vs_similar_color_su2017
    skip("Added in SU2018") if Sketchup.version.to_i > 17
    color1 = Sketchup::Color.new(240, 248, 255)
    color2 = Sketchup::Color.new(240, 248, 255)
    refute(color1 == color2)
  end

  def test_Operator_Equal_vs_different_color
    color1 = Sketchup::Color.new(240, 248, 255)
    color2 = Sketchup::Color.new(240, 248, 255, 50)
    refute(color1 == color2)
  end

  def test_Operator_Equal_vs_string
    color = Sketchup::Color.new('green')
    refute(color == 'green')
  end

  def test_Operator_Equal_vs_nil
    color = Sketchup::Color.new(240, 248, 255)
    refute(color == nil)
  end

end
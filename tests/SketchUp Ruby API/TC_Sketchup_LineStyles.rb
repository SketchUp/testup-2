# Copyright:: Copyright 2018 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi

require "testup/testcase"

# class Sketchup::LineStyles
class TC_Sketchup_LineStyles < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end

  def get_all_names
    ["Solid Basic", "Short dash", "Dash", "Dot", "Dash dot",
    "Dash double-dot", "Dash triple-dot", "Double-dash dot",
    "Double-dash double-dot", "Double-dash triple-dot", "Long-dash dash",
    "Long-dash double-dash"]
  end

  def test_size
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_equal(get_all_names.sort.size, Sketchup.active_model.line_styles.size)
  end

  def test_size_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles.size(nil)
    end
  end

  def test_length
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_equal(get_all_names.sort.size, Sketchup.active_model.line_styles.length)
  end

  def test_length_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles.length(nil)
    end
  end

  def test_names
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    names = Sketchup.active_model.line_styles.names.sort
    assert_kind_of(Array, names)
    assert_equal(get_all_names.sort, names)
  end

  def test_names_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles.names(nil)
    end
  end

  def test_get_by_name
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    line_style_to_get = get_all_names.sort.at(0)
    line_style = Sketchup.active_model.line_styles[line_style_to_get]
    assert_kind_of(Sketchup::LineStyle, line_style)
    assert_equal(line_style_to_get, line_style.name)
  end

  def test_get_by_name_invalid_name
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    invalid_name = "Shenanigans is Shenanijins"
    line_style = Sketchup.active_model.line_styles[invalid_name]
    assert_nil(line_style)
  end

  def test_get_by_name_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles["Solid Basic", "Dotted Basic"]
    end
  end

  def test_get_by_name_invalid_type
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(TypeError) do
      Sketchup.active_model.line_styles[nil]
    end
  end

  def test_each
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    line_styles = Sketchup.active_model.line_styles
    line_styles.each{ |line_style| assert_kind_of(Sketchup::LineStyle, line_style)}
  end

  def test_each_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles.each(nil)
    end
  end

  def test_to_a
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    all_names = get_all_names
    line_styles = Sketchup.active_model.line_styles.to_a
    line_styles.each_with_index { |linestyle, index|
      assert_equal(all_names[index], linestyle.name)
    }
  end

  def test_to_a_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles.to_a(nil)
    end
  end

  def test_at
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    expected_line_style = Sketchup.active_model.line_styles.at(get_all_names[0])
    result_line_style = Sketchup.active_model.line_styles.at(0)
    assert_equal(expected_line_style, result_line_style)
  end

  def test_at_alias
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    expected_line_style = Sketchup.active_model.line_styles[get_all_names[0]]
    result_line_style = Sketchup.active_model.line_styles[0]
    assert_equal(expected_line_style, result_line_style)
  end

  def test_at_negative_index
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    expected_line_style = Sketchup.active_model.line_styles.at(get_all_names[-1])
    result_line_style = Sketchup.active_model.line_styles.at(-1)
    assert_equal(expected_line_style, result_line_style)
  end

  def test_at_alias_negative_index
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    expected_line_style = Sketchup.active_model.line_styles[get_all_names[-1]]
    result_line_style = Sketchup.active_model.line_styles[-1]
    assert_equal(expected_line_style, result_line_style)
  end

  def test_at_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles.at(0, 1)
    end
  end

  def test_at_alias_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
     assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles[0, 1]
    end
  end

  def test_at_invalid_type
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(TypeError) do
      Sketchup.active_model.line_styles.at(nil)
    end
  end

  def test_at_alias_invalid_type
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(TypeError) do
      Sketchup.active_model.line_styles[nil]
    end
  end

  def test_line_style_object_id
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_equal(Sketchup.active_model.line_styles[0].object_id,
        Sketchup.active_model.line_styles[0].object_id)
  end

  def test_enumerable
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_kind_of(Enumerable, Sketchup.active_model.line_styles)
  end
end
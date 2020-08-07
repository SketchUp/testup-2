# Copyright:: Copyright 2018 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi

require "testup/testcase"

# class Sketchup::LineStyle
class TC_Sketchup_LineStyle < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end

  def test_name
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    name_of_style = "Solid Basic"
    line_style = Sketchup.active_model.line_styles[name_of_style]
    assert_kind_of(Sketchup::LineStyle, line_style)
    assert_equal(name_of_style, line_style.name)
  end

  def test_name_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    name_of_style = "Solid Basic"
    line_style = Sketchup.active_model.line_styles[name_of_style]
    assert_raises(ArgumentError) do
      line_style.name(nil)
    end
  end
end
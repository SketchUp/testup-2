# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Paul Ballew


require "testup/testcase"

require "stringio"


# class Sketchup::Tools
# http://www.sketchup.com/intl/developer/docs/ourdoc/tools
class TC_Sketchup_Tools < TestUp::TestCase

  def setup
    Sketchup.active_model.select_tool nil
  end

  # Class to use for tool tests
  class MyTool; end

  def test_push_tool
    mytool = MyTool.new
    assert_equal(true, Sketchup.active_model.tools.push_tool(mytool))
  end

  def test_push_tool_id_gt_50000
    mytool = MyTool.new
    Sketchup.active_model.tools.push_tool(mytool)
    assert_operator(Sketchup.active_model.tools.active_tool_id, :>, 50000,
        "Tool ID was invalid")
  end

  def test_push_tool_pop
    mytool = MyTool.new
    Sketchup.active_model.tools.push_tool(mytool)
    Sketchup.active_model.tools.pop_tool
    # This magic number is the resource ID for the select tool ()ID_DRAW_SELECT)
    assert_equal(21022, Sketchup.active_model.tools.active_tool_id,
        "Tool stack was not cleared")
  end

  def test_push_tool_same_tool_x2
    mytool = MyTool.new
    Sketchup.active_model.tools.push_tool(mytool)
    mytool_id = Sketchup.active_model.tools.active_tool_id

    Sketchup.active_model.tools.push_tool(mytool)
    mytool_id2 = Sketchup.active_model.tools.active_tool_id

    refute_equal(mytool_id, mytool_id2, "Tool ID did not change")
  end

  def test_push_tool_diff_tools
    mytool = MyTool.new
    Sketchup.active_model.tools.push_tool(mytool)
    mytool_id = Sketchup.active_model.tools.active_tool_id

    mytool2 = MyTool.new
    Sketchup.active_model.tools.push_tool(mytool2)
    mytool_id2 = Sketchup.active_model.tools.active_tool_id

    refute_equal(mytool_id, mytool_id2, "Tool ID did not change")
  end

end # class

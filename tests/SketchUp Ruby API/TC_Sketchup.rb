# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


# module Sketchup
# http://www.sketchup.com/intl/en/developer/docs/ourdoc/sketchup
class TC_Sketchup < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::Edges.faces
  # http://www.sketchup.com/intl/developer/docs/ourdoc/edge#faces

  def test_platform
    result = Sketchup.platform
    assert_kind_of(Symbol, result)
    if windows?
      assert_equal(:platform_win, result)
    else
      assert_equal(:platform_osx, result)
    end
  end # test


end # class

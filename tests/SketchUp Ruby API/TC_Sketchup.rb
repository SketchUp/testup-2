# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


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
  # method Sketchup.is_64bit?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/sketchup#is_64bit?

  def test_is_64bit_Query_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    # For backward compatibility, check for the existence of the method
    # and load 32bit binaries for SketchUp versions that do not have this
    # method.
    if Sketchup.respond_to?(:is_64bit?) && Sketchup.is_64bit?
      # Load 64bit binaries.
    else
      # Load 32bit binaries.
    end
  end

  def test_is_64bit_Query
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    pointer_size = ['a'].pack('P').size * 8
    expected = pointer_size == 64
    result = Sketchup.is_64bit?
    assert_equal(expected, result)
  end

  def test_is_64bit_Query_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      Sketchup.is_64bit?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup.platform
  # http://www.sketchup.com/intl/developer/docs/ourdoc/sketchup#platform

  def test_platform
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    result = Sketchup.platform
    assert_kind_of(Symbol, result)
    if windows?
      assert_equal(:platform_win, result)
    else
      assert_equal(:platform_osx, result)
    end
  end


end # class

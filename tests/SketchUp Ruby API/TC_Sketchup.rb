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
  # method Sketchup.debug_mode?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/sketchup#debug_mode?

  def test_debug_mode_Query_api_example
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16
    debug_mode = Sketchup.debug_mode?
  end

  def test_debug_mode_Query
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16
    original_mode = Sketchup.debug_mode

    Sketchup.debug_mode = true
    assert_equal(true, Sketchup.debug_mode?)

    Sketchup.debug_mode = false
    assert_equal(false, Sketchup.debug_mode?)
  ensure
    Sketchup.debug_mode = original_mode
  end

  def test_debug_mode_Query_incorrect_number_of_arguments
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16
    assert_raises ArgumentError do
      Sketchup.debug_mode?(nil)
    end
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

  def test_template
    result = Sketchup.template
    assert(result != "", "Template is blank")
    assert(result.downcase.end_with?(".skp"), "Template is not a SKP file")
  end  

  def test_template_Set
    # Get the current template
    orig_template = Sketchup.template

    begin
      # Get a different template from the Templates folder
      template_dir = Sketchup.get_resource_path("Templates")
      new_template = ""
      Dir.entries(template_dir).each do |template|
        next if !template.downcase.end_with?('.skp')
        next if orig_template.downcase.end_with?(template.downcase)
        new_template = File.join(template_dir, template)
        break
      end

      assert(new_template != "", "Could not find any templates.")
      
      # Set the default template and verify it set properly
      Sketchup.template = new_template
      new_default = Sketchup.template
      assert_equal(new_template, new_default, "Default template did not save properly.")
    
    ensure
      Sketchup.template = orig_template
    end
  end
  
end # class

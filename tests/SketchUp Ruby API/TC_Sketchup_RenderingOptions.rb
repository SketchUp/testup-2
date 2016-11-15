# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"
require "stringio"


# class Sketchup::RenderingOptions
# http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions
class TC_Sketchup_RenderingOptions < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  def mute_puts_statements(&block)
    stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = stdout
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.[]
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#[]

  def test_Operator_Get_api_example
    result = Sketchup.active_model.rendering_options["DisplayInstanceAxes"]
  end

  def test_Operator_Get_valid_key
    # Not a whole lot to verify from Ruby here. Just checking that no errors
    # are raised.
    options = Sketchup.active_model.rendering_options
    options["DisplayInstanceAxes"] = true
    result = options["DisplayInstanceAxes"]
    assert_equal(true, result)

    options["DisplayInstanceAxes"] = false
    result = options["DisplayInstanceAxes"]
    assert_equal(false, result)
  end

  def test_Operator_Get_invalid_key
    options = Sketchup.active_model.rendering_options
    result = options["House of rising sun"]
    assert_nil(result)
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.[]=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#[]=

  def test_Operator_Set_api_example
    options = Sketchup.active_model.rendering_options
    result = options["DisplayInstanceAxes"]
  end

  def test_Operator_Set_valid_key
    options = Sketchup.active_model.rendering_options
    current_value = options["DisplayInstanceAxes"]

    new_value = !current_value
    result = (options["DisplayInstanceAxes"] = new_value)
    assert_equal(new_value, result)
    assert_equal(new_value, options["DisplayInstanceAxes"])
  end

  def test_Operator_Set_invalid_key
    options = Sketchup.active_model.rendering_options
    result = (options["House of rising sun"] = true)
    assert_equal(true, result)
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.count
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#count

  def test_count_api_example
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    number = options.count
  end

  def test_count
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    number = options.count
    assert_equal(options.keys.length, number)
  end

  def test_count_by_key_value_pair
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    expected_value = options['InstanceHidden']
    result = options.count(['InstanceHidden', expected_value])
    assert_equal(1, result)
  end

  def test_count_by_block_result
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    result = options.count { |key, value|
      key =~ /^Fog/
    }
    assert_equal(4, result)
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.length
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#length

  def test_length_api_example
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    number = options.length
  end

  def test_length
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    number = options.length
    assert_equal(options.keys.length, number)
  end

  def test_length_bad_params
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.length(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.size
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#size

  def test_size_api_example
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    number = options.size
  end

  def test_size
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    options = Sketchup.active_model.rendering_options
    number = options.size
    assert_equal(options.keys.size, number)
  end

  def test_size_bad_params
    skip("Implemented in SU2014") if Sketchup.version.to_i < 14
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.size(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.each_key
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#each_key

  def test_each_key_api_example
    mute_puts_statements {
      # API example begins here:
      Sketchup.active_model.rendering_options.each_key { |key|
        puts key
      }
    }
  end

  def test_each_key_iterations_matches_length
    collection = Sketchup.active_model.rendering_options
    count = 0
    collection.each_key do |key|
      count = count + 1
    end
    expected = collection.length
    result = count
    assert_equal(expected, result)
  end

  def test_each_key_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.each_key(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.each_pair
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#each_pair

  def test_each_pair_api_example
    mute_puts_statements {
      # API example begins here:
      Sketchup.active_model.rendering_options.each_pair { |key, value|
        puts "#{key} : #{value}"
      }
    }
  end

  def test_each_pair_iterations_matches_length
    collection = Sketchup.active_model.rendering_options
    count = 0
    collection.each_pair do |key, value|
      count = count + 1
    end
    expected = collection.length
    result = count
    assert_equal(expected, result)
  end

  def test_each_pair_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.each_pair(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.each
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#each

  def test_each_api_example
    mute_puts_statements {
      # API example begins here:
      Sketchup.active_model.rendering_options.each { |key, value|
        puts "#{key} : #{value}"
      }
    }
  end

  def test_each_iterations_matches_length
    collection = Sketchup.active_model.rendering_options
    count = 0
    collection.each do |key, value|
      count = count + 1
    end
    expected = collection.length
    result = count
    assert_equal(expected, result)
  end

  def test_each_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.each(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.keys
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#keys

  def test_keys_api_example
    keys = Sketchup.active_model.rendering_options.keys
  end

  def test_keys
    expected_keys = %w[
      BackgroundColor
      BandColor
      ConstructionColor
      DepthQueWidth
      DisplayColorByLayer
      DisplayFog
      DisplayInstanceAxes
      DisplayWatermarks
      DrawDepthQue
      DrawGround
      DrawHidden
      DrawHorizon
      DrawLineEnds
      DrawProfilesOnly
      DrawSilhouettes
      DrawUnderground
      EdgeColorMode
      EdgeDisplayMode
      EdgeType
      ExtendLines
      FaceBackColor
      FaceColorMode
      FaceFrontColor
      FogColor
      FogEndDist
      FogStartDist
      FogUseBkColor
      ForegroundColor
      GroundColor
      GroundTransparency
      HideConstructionGeometry
      HighlightColor
      HorizonColor
      InactiveHidden
      InstanceHidden
      JitterEdges
      LineEndWidth
      LineExtension
      LockedColor
      MaterialTransparency
      ModelTransparency
      RenderMode
      SectionActiveColor
      SectionCutWidth
      SectionDefaultCutColor
      SectionInactiveColor
      ShowViewName
      SilhouetteWidth
      SkyColor
      Texture
      TransparencySort
    ]
    if Sketchup.version.to_i >= 7
      expected_keys << "DisplayDims"
      expected_keys << "DisplaySketchAxes"
      expected_keys << "DisplayText"
    end
    if Sketchup.version.to_i >= 8
      expected_keys << "InactiveFade"
      expected_keys << "InstanceFade"
    end
    if Sketchup.version.to_i >= 14
      expected_keys << "DisplaySectionPlanes"
    end
    if Sketchup.version.to_i >= 15
      expected_keys << "DisplaySectionCuts"
      expected_keys << "SectionCutDrawEdges"
      expected_keys << "DrawBackEdges"
    end
    expected_keys.sort!
    keys = Sketchup.active_model.rendering_options.keys
    assert_kind_of(Array, keys)
    assert_equal(expected_keys.size, keys.size)
    keys.sort!
    expected_keys.size.times { |i|
      assert_equal(expected_keys[i], keys[i])
    }
  end

  def test_keys_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.keys(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.add_observer
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#add_observer

  def test_add_observer_api_example
    observer = Sketchup::RenderingOptionsObserver.new # Dummy observer.
    result = Sketchup.active_model.rendering_options.add_observer(observer)
  ensure
    Sketchup.active_model.rendering_options.remove_observer(observer)
  end

  def test_add_observer
    observer = Sketchup::RenderingOptionsObserver.new
    result = Sketchup.active_model.rendering_options.add_observer(observer)
    assert_equal(true, result)
  ensure
    Sketchup.active_model.rendering_options.remove_observer(observer)
  end

  def test_add_observer_incorrect_number_of_arguments_two
    observer = Sketchup::RenderingOptionsObserver.new
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.add_observer(observer, nil)
    end
  ensure
    Sketchup.active_model.rendering_options.remove_observer(observer)
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.remove_observer
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#remove_observer

  def test_remove_observer_api_example
    observer = Sketchup::RenderingOptionsObserver.new # Dummy observer.
    options = Sketchup.active_model.rendering_options
    options.add_observer(observer)
    result = options.remove_observer(observer)
  ensure
    Sketchup.active_model.rendering_options.remove_observer(observer)
  end

  def test_remove_observer
    observer = Sketchup::RenderingOptionsObserver.new
    options = Sketchup.active_model.rendering_options
    options.add_observer(observer)
    result = options.remove_observer(observer)
    assert_equal(true, result)
    result = options.remove_observer(observer)
    assert_equal(false, result)
  ensure
    Sketchup.active_model.rendering_options.remove_observer(observer)
  end

  def test_remove_observer_incorrect_number_of_arguments_two
    observer = Sketchup::RenderingOptionsObserver.new
    Sketchup.active_model.rendering_options.add_observer(observer)
    assert_raises(ArgumentError) do
      Sketchup.active_model.rendering_options.remove_observer(observer, nil)
    end
  ensure
    Sketchup.active_model.rendering_options.remove_observer(observer)
  end


  # ========================================================================== #

  def test_constants
    expected_constants = %w{
      ROPAssign
      ROPDrawHidden
      ROPEditComponent
      ROPSetBackgroundColor
      ROPSetConstructionColor
      ROPSetDepthQueEdges
      ROPSetDepthQueWidth
      ROPSetDisplayColorByLayer
      ROPSetDisplayDims
      ROPSetDisplayFog
      ROPSetDisplayInstanceAxes
      ROPSetDisplaySketchAxes
      ROPSetDisplayText
      ROPSetDrawGround
      ROPSetDrawHorizon
      ROPSetDrawUnderground
      ROPSetEdgeColorMode
      ROPSetEdgeDisplayMode
      ROPSetEdgeType
      ROPSetExtendEdges
      ROPSetExtendLines
      ROPSetFaceColor
      ROPSetFaceColorMode
      ROPSetFogColor
      ROPSetFogDist
      ROPSetFogHint
      ROPSetFogUseBkColor
      ROPSetForegroundColor
      ROPSetGroundColor
      ROPSetGroundTransparency
      ROPSetHideConstructionGeometry
      ROPSetHighlightColor
      ROPSetJitterEdges
      ROPSetLineEndEdges
      ROPSetLineEndWidth
      ROPSetLineExtension
      ROPSetLockedColor
      ROPSetMaterialTransparency
      ROPSetModelTransparency
      ROPSetProfileEdges
      ROPSetProfileWidth
      ROPSetProfilesOnlyEdges
      ROPSetRenderMode
      ROPSetSectionActiveColor
      ROPSetSectionCutWidth
      ROPSetSectionDefaultCutColor
      ROPSetSectionDisplayMode
      ROPSetSectionInactiveColor
      ROPSetSkyColor
      ROPSetTexture
      ROPSetTransparencyObsolete
      ROPTransparencySortMethod
    }.sort
    actual_constants = Sketchup::RenderingOptionsObserver.constants.sort
    actual_constants.each_with_index { |constant, index|
      expected = expected_constants[index]
      assert_equal(expected, constant.to_s)
      assert_not_nil(constant)
    }
  end


end # class

# Copyright:: Copyright 2019 Trimble Inc.
# License:: The MIT License (MIT)

require "testup/testcase"

class TC_Sketchup_OptionsProvider < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end

  class NoopObserver < Sketchup::OptionsProviderObserver; end


  def test_class
    provider = Sketchup.active_model.options['UnitsOptions']
    assert_kind_of(Sketchup::OptionsProvider, provider)
    assert_kind_of(Enumerable, provider)
  end


  def test_Operator_Get_index
    provider = Sketchup.active_model.options['UnitsOptions']
    value = provider[1]
    refute_nil(value)
  end

  def test_Operator_Get_name
    provider = Sketchup.active_model.options['UnitsOptions']
    value = provider['LengthUnit']
    refute_nil(value)
  end


  def test_add_observer
    provider = Sketchup.active_model.options['UnitsOptions']
    observer = NoopObserver.new
    result = provider.add_observer(observer)
    assert_kind_of(TrueClass, result)
  ensure
    provider.remove_observer(observer)
  end


  def test_count
    provider = Sketchup.active_model.options['UnitsOptions']
    result = provider.count
    assert_kind_of(Integer, result)
    assert_equal(provider.keys.size, result)
  end


  def test_each
    provider = Sketchup.active_model.options['UnitsOptions']
    yielded = false
    provider.each { |key, value|
      yielded = true
      assert_kind_of(String, key)
      refute_nil(value)
    }
    assert(yielded, 'no value yielded')
  end


  def test_each_key
    provider = Sketchup.active_model.options['UnitsOptions']
    yielded = false
    provider.each { |key|
      yielded = true
      assert_kind_of(String, key)
    }
    assert(yielded, 'no value yielded')
  end


  def test_each_pair
    provider = Sketchup.active_model.options['UnitsOptions']
    yielded = false
    provider.each { |key, value|
      yielded = true
      assert_kind_of(String, key)
      refute_nil(value)
    }
    assert(yielded, 'no value yielded')
  end


  def test_each_value
    provider = Sketchup.active_model.options['UnitsOptions']
    yielded = false
    provider.each { |value|
      yielded = true
      refute_nil(value)
    }
    assert(yielded, 'no value yielded')
  end


  def test_has_key_Query
    provider = Sketchup.active_model.options['UnitsOptions']
    key = provider.keys[1]
    result = provider.key?(key)
    assert_kind_of(TrueClass, result)
  end


  def test_keys
    provider = Sketchup.active_model.options['UnitsOptions']
    keys = provider.keys
    assert_kind_of(Array, keys)
    keys.each { |key| assert_kind_of(String, key) }
  end

  def test_keys_named_options
    provider = Sketchup.active_model.options['NamedOptions']
    expected = %w[]
    assert_equal(expected, provider.keys.sort)
  end

  def test_keys_page_options
    provider = Sketchup.active_model.options['PageOptions']
    expected = %w[
      ShowTransition
      TransitionTime
    ]
    assert_equal(expected, provider.keys.sort)
  end

  def test_keys_print_options
    skip('Not available on OSX') if Sketchup.platform == :platform_osx
    provider = Sketchup.active_model.options['PrintOptions']
    expected = %w[
      ComputeSizeFromScale
      FitToPage
      LineWeight
      ModelExtents
      NumberOfPages
      PixelsPerInch
      PrintHeight
      PrintQuality
      PrintWidth
      QualityAdjustment
      ScaleAdjustment
      SectionSlice
      SizeInModel
      SizeInPrint
      VectorMode
    ]
    assert_equal(expected, provider.keys.sort)
  end

  def test_keys_slideshow_options
    provider = Sketchup.active_model.options['SlideshowOptions']
    expected = %w[
      LoopSlideshow
      SlideTime
    ]
    assert_equal(expected, provider.keys.sort)
  end

  def test_keys_units_options
    # If this test fails we have changed unit option keys without updating the
    # tests!
    provider = Sketchup.active_model.options['UnitsOptions']
    expected = %w[
      AnglePrecision
      AngleSnapEnabled
      ForceInchDisplay
      LengthFormat
      LengthPrecision
      LengthSnapEnabled
      LengthSnapLength
      LengthUnit
      SnapAngle
      SuppressUnitsDisplay
    ]
    if Sketchup.version.to_f >= 19.2
      expected << 'AreaUnit'
      expected << 'VolumeUnit'
    end
    if Sketchup.version.to_f >= 20.0
      expected << 'AreaPrecision'
      expected << 'VolumePrecision'
    end
    expected.sort!
    assert_equal(expected, provider.keys.sort)
  end


  def test_length
    provider = Sketchup.active_model.options['UnitsOptions']
    result = provider.length
    assert_kind_of(Integer, result)
    assert_equal(provider.keys.size, result)
  end


  def test_name
    provider = Sketchup.active_model.options['UnitsOptions']
    result = provider.name
    assert_kind_of(String, result)
    assert_equal('UnitsOptions', result)
  end


  def test_remove_observer
    provider = Sketchup.active_model.options['UnitsOptions']
    observer = NoopObserver.new
    provider.add_observer(observer)
    result = provider.remove_observer(observer)
    assert_kind_of(TrueClass, result)
  ensure
    provider.remove_observer(observer)
  end

  def test_add_observer_invalid_arguments
    provider = Sketchup.active_model.options['UnitsOptions']
    result = provider.remove_observer(nil)
    assert_kind_of(FalseClass, result)
  end


  def test_size
    provider = Sketchup.active_model.options['UnitsOptions']
    result = provider.size
    assert_kind_of(Integer, result)
    assert_equal(provider.keys.size, result)
  end

end

# Copyright:: Copyright 2019 Trimble Inc.
# License:: The MIT License (MIT)

require "testup/testcase"

class TC_Sketchup_OptionsManager < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end


  def test_class
    options = Sketchup.active_model.options
    assert_kind_of(Sketchup::OptionsManager, options)
    assert_kind_of(Enumerable, options)
  end


  def test_Operator_Get_index
    options = Sketchup.active_model.options
    provider = options[1]
    assert_kind_of(Sketchup::OptionsProvider, provider)
  end

  def test_Operator_Get_name
    options = Sketchup.active_model.options
    provider = options['UnitsOptions']
    assert_kind_of(Sketchup::OptionsProvider, provider)
    assert_equal('UnitsOptions', provider.name)
  end

  def test_Operator_Get_wrong_number_of_arguments
    options = Sketchup.active_model.options
    assert_raises(ArgumentError) do
      options[0, 1]
    end
  end

  def test_Operator_Get_invalid_arguments
    options = Sketchup.active_model.options
    assert_raises(TypeError) do
      options[nil]
    end
  end


  def test_count
    options = Sketchup.active_model.options
    result = options.count
    assert_kind_of(Integer, result)
    assert_equal(options.keys.size, result)
  end


  def test_each
    options = Sketchup.active_model.options
    yielded = false
    options.each { |option|
      yielded = true
      assert_kind_of(Sketchup::OptionsProvider, option)
    }
    assert(yielded, 'no value yielded')
  end

  def test_each_map_provider_name
    options = Sketchup.active_model.options
    expected = %w[
      NamedOptions
      PageOptions
      PrintOptions
      SlideshowOptions
      UnitsOptions
    ]
    expected.delete('PrintOptions') if Sketchup.platform == :platform_osx
    assert_equal(expected, options.map(&:name).sort)
  end


  def test_keys
    options = Sketchup.active_model.options
    keys = options.keys
    assert_kind_of(Array, keys)
    keys.each { |key| assert_kind_of(String, key) }
    assert_equal(options.map(&:name).sort, keys.sort)
  end


  def test_length
    options = Sketchup.active_model.options
    result = options.length
    assert_kind_of(Integer, result)
    assert_equal(options.keys.size, result)
  end


  def test_size
    options = Sketchup.active_model.options
    result = options.size
    assert_kind_of(Integer, result)
    assert_equal(options.keys.size, result)
  end

end

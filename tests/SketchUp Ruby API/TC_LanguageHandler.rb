# Copyright:: Copyright 2013 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"
require 'langhandler.rb'


# Class LanguageHandler
# http://www.sketchup.com/intl/developer/docs/ourdoc/languagehandler
class TC_LanguageHandler < TestUp::TestCase

  def setup
    @sample_valid_file = 'valid.strings'
    @sample_bom_file = 'with-bom.strings'
    @sample_invalid_file = 'invalid.strings'
    @sketchup_strings = 'gettingstarted.strings'
    @dynamiccomponents_strings = 'dynamiccomponents.strings'
    @sandbox_strings = 'sandbox.strings'
  end

  # ----------------------------------------------------------------------------
  # initialize

  VALID_STRINGS_NUM_STRINGS = 8
  VALID_STRINGS_WITH_BOM_NUM_STRINGS = 7

  def test_initializing_valid_file
    handler = LanguageHandler.new(@sample_valid_file)
    assert_equal(VALID_STRINGS_NUM_STRINGS, handler.GetStrings.length)
  end

  def test_initializing_valid_file_with_bom
    handler = LanguageHandler.new(@sample_bom_file)
    assert_equal(VALID_STRINGS_WITH_BOM_NUM_STRINGS, handler.GetStrings.length)
  end

  def test_initializing_invalid_file
    handler = LanguageHandler.new(@sample_invalid_file)
    assert_equal(0, handler.GetStrings.length)
  end

  def test_initializing_bad_params
    handler = LanguageHandler.new(@sample_valid_file)

    assert_raises ArgumentError do
      result = handler.GetStrings(nil)
    end
    assert_raises ArgumentError do
      result = handler.GetStrings(123)
    end
    assert_raises ArgumentError do
      result = handler.GetStrings(1, 'two', :three)
    end
  end

  # ----------------------------------------------------------------------------
  # GetResourcePath

  def test_GetResourcePath_non_existing_file
    handler = LanguageHandler.new(@sample_valid_file)
    
    result = handler.GetResourcePath('NoSuch.file')
    assert_kind_of(String, result)
    assert_equal('', result)
  end

  def test_GetResourcePath_existing_file
    handler = LanguageHandler.new(@sample_valid_file)

    path = File.dirname(__FILE__)
    basename = File.basename(__FILE__, '.rb')
    locale = Sketchup.get_locale
    filename = 'valid.strings'
    filepath = File.join(path, basename, 'Resources', locale, filename)
    result = handler.GetResourcePath(filename)
    assert_kind_of(String, result)
    assert_equal(filepath, result)
  end

  def test_GetResourcePath_bad_params
    handler = LanguageHandler.new(@sample_valid_file)

    assert_raises ArgumentError do
      result = handler.GetResourcePath(nil)
    end
    assert_raises ArgumentError do
      result = handler.GetResourcePath(123)
    end
    assert_raises ArgumentError do
      result = handler.GetResourcePath(1, 'two', :three)
    end
  end

  # ----------------------------------------------------------------------------
  # GetString
  #
  # Deprecated old method from the original version of the LanguageHandler. Kept
  # to provide backwards compatibility.

  def test_GetString_existing_file
    handler = LanguageHandler.new(@sample_valid_file)

    result = handler.GetString('Foo')
    assert_kind_of(String, result)
    assert_equal('Bar', result)
  end

  def test_GetString_quotes
    handler = LanguageHandler.new(@sample_valid_file)

    result = handler.GetString('String "3"')
    assert_equal('Localized String 3', result)

    result = handler.GetString('String 4')
    assert_equal('Localized "String" 4', result)
  end

  def test_GetString_url
    handler = LanguageHandler.new(@sample_valid_file)

    result = handler.GetString('URL: http://www.example.com/')
    assert_equal('URL: http://www.example.no/', result)
  end

  def test_GetString_encoding
    handler = LanguageHandler.new(@sample_valid_file)

    result = handler.GetString('String 5')
    assert_equal('UTF-8', result.encoding.name)
    assert_equal('Bærene bør ikke være dårlige!', result)

    result = handler.GetString('All your base are belong to us')
    assert_equal('UTF-8', result.encoding.name)
    assert_equal('你所有的基地都屬於我們', result)
  end

  def test_GetString_non_existing_file
    handler = LanguageHandler.new(@sample_valid_file)

    result = handler.GetString('Lorem')
    assert_kind_of(String, result)
    assert_equal('Lorem', result)
  end

  def test_GetString_bad_params
    handler = LanguageHandler.new(@sample_valid_file)

    result = nil
    bad_params = [
      nil,
      123,
      :symbol,
      [1, 'two', :three]
    ]
    for bad_param in bad_params
      result = handler.GetString(bad_param)
      assert_equal(bad_param, result)
    end
  end

  # ----------------------------------------------------------------------------
  # GetStrings

  def test_GetStrings
    handler = LanguageHandler.new(@sample_valid_file)

    result = handler.GetStrings
    assert_kind_of(Hash, result)
    assert_equal(VALID_STRINGS_NUM_STRINGS, result.length)
  end

  def test_GetStrings_bad_params
    handler = LanguageHandler.new(@sample_valid_file)

    assert_raises ArgumentError do
      result = handler.GetStrings(nil)
    end
    assert_raises ArgumentError do
      result = handler.GetStrings(123)
    end
    assert_raises ArgumentError do
      result = handler.GetStrings(1, 'two', :three)
    end
  end

  # ----------------------------------------------------------------------------
  # SketchUp Resources

  # Test the file that sketchup.rb loads.
  def test_resources_sketchup
    handler = LanguageHandler.new(@sketchup_strings)
    result = handler.GetString('Ruby Console')
    assert(!handler.GetStrings.empty?)
    assert_kind_of(String, result)
    assert_equal('Ruby Console', result)
  end

  # Test the file that Dynamic Component loads.
  def test_resources_dynamic_componenents
    handler = LanguageHandler.new(@dynamiccomponents_strings)
    result = handler.GetString('Millimeters')
    assert(!handler.GetStrings.empty?)
    assert_kind_of(String, result)
    assert_equal('Millimeters', result)
  end

  # Test the file that Sandbox Tools loads.
  def test_resources_sandbox_tools
    handler = LanguageHandler.new(@sandbox_strings)
    result = handler.GetString('Stamp')
    assert(!handler.GetStrings.empty?)
    assert_kind_of(String, result)
    assert_equal('Stamp', result)
  end

  # ----------------------------------------------------------------------------
  # Aliases

  def test_Operator_Get_alias_string_brackets
    handler = LanguageHandler.new(@sample_valid_file)

    expect = handler.GetString('Foo')
    result = handler['Foo']
    assert_equal(expect, result)
  end

  def test_strings_alias
    handler = LanguageHandler.new(@sample_valid_file)

    expect = handler.GetStrings
    result = handler.strings
    assert_equal(expect, result)
  end

  def test_resource_path_alias
    handler = LanguageHandler.new(@sample_valid_file)

    expect = handler.GetResourcePath('valid.strings')
    result = handler.resource_path('valid.strings')
    assert_equal(expect, result)
  end

end # class

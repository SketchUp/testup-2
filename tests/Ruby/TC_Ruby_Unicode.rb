# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"
#require_relative "TC_Ruby_Unicode/てすと/support.rb"
path = File.dirname(__FILE__)
load File.join(path, "TC_Ruby_Unicode/てすと/support.rb")


class TC_Ruby_Unicode < TestUp::TestCase

  def setup
    @loaded_features = $LOADED_FEATURES.dup
  end

  def teardown
    $LOADED_FEATURES.clear
    for path in @loaded_features
      $LOADED_FEATURES << path
    end
  end

  def get_support_file(file)
    path = File.dirname(__FILE__)
    File.join(path, "TC_Ruby_Unicode", "てすと", file)
  end


  # ========================================================================== #
  # __FILE__

  def test_FILE_encoding_expect_UTF8
    expected = Encoding.find("UTF-8")
    result = get_FILE_from_unicode_path().encoding
    assert_equal(expected, result)
  end

  def test_FILE_encoding_is_valid
    expected = Encoding.find("UTF-8")
    result = get_FILE_from_unicode_path()
    assert_equal(true, result.valid_encoding?)
  end

  # This test checks that the byte data actually is UTF-8 bytes regardless of
  # what encoding label the string might have.
  def test_FILE_bytes_expect_UTF8
    path = get_FILE_from_unicode_path()
    parts = path.split("/")

    filename = parts.pop
    multibyte_folder_name = parts.pop

    # "support.rb"
    expected = [115, 117, 112, 112, 111, 114, 116, 46, 114, 98]
    result = filename.bytes
    assert_equal(expected, result, "File Name")

    # "てすと""
    expected = [227, 129, 166, 227, 129, 153, 227, 129, 168]
    result = multibyte_folder_name.bytes
    assert_equal(expected, result, "Folder Name")
  end


  # ========================================================================== #
  # ENV

  # Unicode strings should be UTF-8.


  # ========================================================================== #
  # $LOADED_FEATURES
  # require, load, Sketchup::require, Sketchup::load

  # require .rb
  def test_require_rb_unicode_path
    testfile = get_support_file("test.rb")
    result = require(testfile)
    assert(result, "`require` failed to load file.")
  end

  def test_require_rb_unicode_path_encoding
    testfile = get_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    require testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # require .so
  def test_require_so_unicode_path
    testfile = get_support_file("SUEX_HelloWorld")
    result = require(testfile)
    assert(result, "`require` failed to load file.")
  end

  def test_require_so_unicode_path_encoding
    testfile = get_support_file("SUEX_HelloWorld")
    loaded_features_size = $LOADED_FEATURES.size
    require testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # load .rb
  def test_load_rb_unicode_path
    testfile = get_support_file("test.rb")
    result = load(testfile)
    assert(result, "`load` failed to load file.")
  end

  def test_load_rb_unicode_path_encoding
    testfile = get_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    load testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # load .so
  def test_load_so_unicode_path
    testfile = get_support_file("SUEX_HelloWorld")
    result = load(testfile)
    assert(result, "`load` failed to load file.")
  end

  def test_load_so_unicode_path_encoding
    testfile = get_support_file("SUEX_HelloWorld")
    loaded_features_size = $LOADED_FEATURES.size
    load testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end


  # Sketchup::require .rb
  def test_Sketchup_require_rb_unicode_path
    testfile = get_support_file("test.rb")
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file.")
  end

  def test_Sketchup_require_rb_unicode_path_encoding
    testfile = get_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    Sketchup::require testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # Sketchup::require .so
  def test_Sketchup_require_so_unicode_path
    testfile = get_support_file("SUEX_HelloWorld")
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file.")
  end

  def test_Sketchup_require_so_unicode_path_encoding
    testfile = get_support_file("SUEX_HelloWorld")
    loaded_features_size = $LOADED_FEATURES.size
    Sketchup::require testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # Sketchup::load .rb
  def test_Sketchup_load_rb_unicode_path
    testfile = get_support_file("test.rb")
    result = Sketchup::load(testfile)
    assert(result, "`Sketchup::load` failed to load file.")
  end

  def test_Sketchup_load_rb_unicode_path_encoding
    testfile = get_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    Sketchup::load testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # Sketchup::load .so
  def test_Sketchup_load_so_unicode_path
    testfile = get_support_file("SUEX_HelloWorld")
    result = Sketchup::load(testfile)
    assert(result, "`Sketchup::load` failed to load file.")
  end

  def test_Sketchup_load_so_unicode_path_encoding
    testfile = get_support_file("SUEX_HelloWorld")
    loaded_features_size = $LOADED_FEATURES.size
    Sketchup::load testfile
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # Load .rbs file from Unicode path.
  # Load RBS files, $LOADED_FEATURES should have new UTF-8 string.



end # class

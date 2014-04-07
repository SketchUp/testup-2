# encoding: UTF-8

# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


# <workaround>
# Some weird bug in minitest appear with this test case if tempfile isn't
# laoded. I've not been able to determine why.
require "tempfile"
# </workaround>


# Allow these tests to be run outsid eof TestUp
if defined?(TestUp)
  require "testup/testcase"
  TESTCASE = TestUp::TestCase
else
  require "test/unit"
  TESTCASE = Test::Unit::TestCase
end


begin
  #require_relative "TC_Ruby_Unicode/てすと/support.rb"
  path = File.dirname(__FILE__)
  load File.join(path, "TC_Ruby_Unicode/てすと/support.rb")
rescue LoadError => error
  puts "Unable to load support file from unicode path."
end


class TC_Ruby_Unicode < TESTCASE

  def setup
    @loaded_features = $LOADED_FEATURES.dup
  end

  def teardown
    $LOADED_FEATURES.clear
    for path in @loaded_features
      $LOADED_FEATURES << path
    end
  end


  if !method_defined?(:get_FILE_from_unicode_path)
    def get_FILE_from_unicode_path
      assert(false, "Unicode test file not loaded.")
    end
  end


  def get_unicode_support_file(file)
    path = File.dirname(__FILE__)
    File.join(path, "TC_Ruby_Unicode", "てすと", file)
  end

  def get_ascii_support_file(file)
    path = File.dirname(__FILE__)
    File.join(path, "TC_Ruby_Unicode", "test", file)
  end

  def get_test_c_extension
    case RUBY_VERSION.to_f
    when 2.0
      "SUEX_HelloWorld"
    when 2.1
      "HelloRuby210"
    when 2.2
      "HelloRuby220"
    else
      assert(false, "No test C-Extension for Ruby #{RUBY_VERSION}")
    end
  end


  # ========================================================================== #
  # __FILE__

  def test_FILE_encoding_expect_UTF8
    expected = Encoding.find("UTF-8")
    result = get_FILE_from_unicode_path().encoding
    assert_equal(expected, result)
  end

  def test_FILE_encoding_is_valid
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

  def test_FILE_file_exists
    file = get_FILE_from_unicode_path()
    result = File.exist?(file)
    assert_equal(true, result)
  end

  def test_FILE_file_exists_with_force_utf8_encoding
    file = get_FILE_from_unicode_path()
    # This is risky, it makes the assumption the string will always be UTF-8.
    # can be we sure of this?
    file.force_encoding("UTF-8")
    result = File.exist?(file)
    assert_equal(true, result)
  end


  # ========================================================================== #
  # Dir

  def test_Dir_entries
    path = File.dirname(__FILE__)
    test_path = File.join(path, "TC_Ruby_Unicode")

    expected = [".", "..", "test", "てすと"]
    result = Dir::entries(test_path)
    expected.size.times { |i|
      assert_equal(expected[i], result[i])
    }
  end

  def test_Dir_entries_force_utf8_encoding
    path = File.dirname(__FILE__)
    path.force_encoding("UTF-8")
    test_path = File.join(path, "TC_Ruby_Unicode")

    expected = [".", "..", "test", "てすと"]
    result = Dir::entries(test_path)
    expected.size.times { |i|
      assert_equal(expected[i], result[i])
    }
  end

  def test_Dir_glob
    path = File.dirname(__FILE__)
    test_path = File.join(path, "TC_Ruby_Unicode")
    filter = File.join(test_path, "*")

    expected = []
    expected << File.join(test_path, "test")
    expected << File.join(test_path, "てすと")
    result = Dir::glob(filter)
    expected.size.times { |i|
      assert_equal(expected[i], result[i])
    }
  end

  def test_Dir_glob_force_utf8_encoding
    path = File.dirname(__FILE__)
    path.force_encoding("UTF-8")
    test_path = File.join(path, "TC_Ruby_Unicode")
    filter = File.join(test_path, "*")

    expected = []
    expected << File.join(test_path, "test")
    expected << File.join(test_path, "てすと")
    result = Dir::glob(filter)
    expected.size.times { |i|
      assert_equal(expected[i], result[i])
    }
  end


  # ========================================================================== #
  # File

  def test_File_open_read_unicode_path
    testfile = get_unicode_support_file("test.rb")
    File.open(testfile, "r") { |file|
      result = file.read
      assert_equal(13, result.size)
    }
  end

  def test_File_read_unicode_path
    testfile = get_unicode_support_file("test.rb")
    result = File.read(testfile)
    assert_equal(13, result.size)
  end


  # ========================================================================== #
  # ENV

  # Unicode strings should be UTF-8.

  def test_ENV_derived_string_home
    home = ENV["HOME"]
    File.exist?(home)
  end

  def test_ENV_home_concatenated
    home = ENV["HOME"]
    desktop = File.join(home, "Desktop")
    File.exist?(desktop)
  end

  def test_ENV_home_encoding
    home = ENV["HOME"]

    expected = Encoding.find("UTF-8")
    assert_equal(expected, home.encoding)
  end

  def test_ENV_home_bytes
    home = ENV["HOME"]

    if home.bytes.all? { |byte| byte < 128 }
      skip("Only ASCII bytes, test with a user account with Unicode username")
    else
      # This test needs refinements. `valid_encoding?` might yield incorrect
      # result.
      assert(home.valid_encoding?)
    end
  end


  # ========================================================================== #
  # $LOADED_FEATURES
  # require, load, Sketchup::require, Sketchup::load

  # Unicode

  # require .rb
  def test_require_relative_rb_unicode_path
    testfile = "TC_Ruby_Unicode/てすと/test.rb"
    result = require_relative(testfile)
    assert(result, "`require` failed to load file: #{testfile}")
  end


  # require .rb
  def test_require_rb_unicode_path
    testfile = get_unicode_support_file("test.rb")
    result = require(testfile)
    assert(result, "`require` failed to load file: #{testfile}")
  end

  def test_require_rb_unicode_path_encoding
    testfile = get_unicode_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    result = require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # require .so
  def test_require_so_unicode_path
    testfile = get_unicode_support_file(get_test_c_extension())
    result = require(testfile)
    assert(result, "`require` failed to load file: #{testfile}")
  end

  def test_require_so_unicode_path_encoding
    testfile = get_unicode_support_file(get_test_c_extension())
    loaded_features_size = $LOADED_FEATURES.size
    result = require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # load .rb
  def test_load_rb_unicode_path
    testfile = get_unicode_support_file("test.rb")
    result = load(testfile)
    assert(result, "`load` failed to load file: #{testfile}")
  end


  # Sketchup::require .rb
  def test_Sketchup_require_rb_unicode_path
    testfile = get_unicode_support_file("test.rb")
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  def test_Sketchup_require_rb_unicode_path_encoding
    testfile = get_unicode_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    result = Sketchup::require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end if defined?(Sketchup)

  # Sketchup::require .so
  def test_Sketchup_require_so_unicode_path
    testfile = get_unicode_support_file(get_test_c_extension())
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  def test_Sketchup_require_so_unicode_path_encoding
    testfile = get_unicode_support_file(get_test_c_extension())
    loaded_features_size = $LOADED_FEATURES.size
    result = Sketchup::require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end if defined?(Sketchup)

  # Sketchup::require .rbs
  def test_Sketchup_require_rbs_unicode_path
    testfile = get_unicode_support_file("scrambled")
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  def test_Sketchup_require_rbs_unicode_path_encoding
    testfile = get_unicode_support_file("scrambled")
    loaded_features_size = $LOADED_FEATURES.size
    result = Sketchup::require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end if defined?(Sketchup)

  # Sketchup::load .rb
  def test_Sketchup_load_rb_unicode_path
    testfile = get_unicode_support_file("test.rb")
    result = Sketchup::load(testfile)
    assert(result, "`Sketchup::load` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  # Sketchup::load .rbs
  def test_Sketchup_load_rbs_unicode_path
    testfile = get_unicode_support_file("scrambled")
    result = Sketchup::load(testfile)
    assert(result, "`Sketchup::load` failed to load file: #{testfile}")
  end if defined?(Sketchup)


  # ASCII

  # require .rb
  def test_require_relative_rb_ascii_path
    testfile = "TC_Ruby_Unicode/test/test.rb"
    result = require_relative(testfile)
    assert(result, "`require` failed to load file: #{testfile}")
  end


  # require .rb
  def test_require_rb_ascii_path
    testfile = get_ascii_support_file("test.rb")
    result = require(testfile)
    assert(result, "`require` failed to load file: #{testfile}")
  end

  def test_require_rb_ascii_path_encoding
    testfile = get_ascii_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    result = require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # require .so
  def test_require_so_ascii_path
    testfile = get_ascii_support_file(get_test_c_extension())
    result = require(testfile)
    assert(result, "`require` failed to load file: #{testfile}")
  end

  def test_require_so_ascii_path_encoding
    testfile = get_ascii_support_file(get_test_c_extension())
    loaded_features_size = $LOADED_FEATURES.size
    result = require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end

  # load .rb
  def test_load_rb_ascii_path
    testfile = get_ascii_support_file("test.rb")
    result = load(testfile)
    assert(result, "`load` failed to load file: #{testfile}")
  end


  # Sketchup::require .rb
  def test_Sketchup_require_rb_ascii_path
    testfile = get_ascii_support_file("test.rb")
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  def test_Sketchup_require_rb_ascii_path_encoding
    testfile = get_ascii_support_file("test.rb")
    loaded_features_size = $LOADED_FEATURES.size
    result = Sketchup::require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end if defined?(Sketchup)

  # Sketchup::require .so
  def test_Sketchup_require_so_ascii_path
    testfile = get_ascii_support_file(get_test_c_extension())
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  def test_Sketchup_require_so_ascii_path_encoding
    testfile = get_ascii_support_file(get_test_c_extension())
    loaded_features_size = $LOADED_FEATURES.size
    result = Sketchup::require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end if defined?(Sketchup)

  # Sketchup::require .rbs
  def test_Sketchup_require_rbs_ascii_path
    testfile = get_ascii_support_file("scrambled")
    result = Sketchup::require(testfile)
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  def test_Sketchup_require_rbs_ascii_path_encoding
    testfile = get_ascii_support_file("scrambled")
    loaded_features_size = $LOADED_FEATURES.size
    result = Sketchup::require testfile
    assert(result, "`Sketchup::require` failed to load file: #{testfile}")
    assert_equal(loaded_features_size + 1, $LOADED_FEATURES.size)

    expected = Encoding.find("UTF-8")
    result = $LOADED_FEATURES.last.encoding
    assert_equal(expected, result)
  end if defined?(Sketchup)

  # Sketchup::load .rb
  def test_Sketchup_load_rb_ascii_path
    testfile = get_ascii_support_file("test.rb")
    result = Sketchup::load(testfile)
    assert(result, "`Sketchup::load` failed to load file: #{testfile}")
  end if defined?(Sketchup)

  # Sketchup::load .rbs
  def test_Sketchup_load_rbs_ascii_path
    testfile = get_ascii_support_file("scrambled")
    result = Sketchup::load(testfile)
    assert(result, "`Sketchup::load` failed to load file: #{testfile}")
  end if defined?(Sketchup)


end # class

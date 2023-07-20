# Copyright:: Copyright 2014-2022 Trimble Inc.
# License:: The MIT License (MIT)

require "testup/testcase"
require_relative "utils/feature_switch"

require "fileutils"

# module UI
class TC_UI < TestUp::TestCase

  include TestUp::SketchUpTests::FeatureSwitchHelper

  def self.setup_testcase
    discard_all_models
  end

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup.select_directory

  def test_select_directory_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Default title and folder:
    chosen_folder = UI.select_directory

    # Custom dialog title:
    chosen_folder = UI.select_directory(title: "Select Image Directory")

    # Force a start folder:
    chosen_folder = UI.select_directory(directory: "C:/images")

    # Allow multiple items to the selected:
    chosen_folder = UI.select_directory(select_multiple: true)

    # Custom dialog title and force a start folder:
    chosen_folder = UI.select_directory(
      title: "Select Image Directory",
      directory: "C:/images"
    )
  end

  def test_select_directory_method_exists
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert(UI.respond_to?(:select_directory))
    assert_equal(-1, UI.method(:select_directory).arity)
  end

  def test_select_directory_no_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Pick folder where this RB is located and press ok.
    result = UI.select_directory
    assert_kind_of(String, result)
    assert_equal(__dir__, result)
  end

  def test_select_directory_title_argument
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Ensure the dialog title is set.
    result = UI.select_directory(title: "TestUp Test")
    assert_kind_of(String, result)
  end

  def test_select_directory_select_multiple_argument
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Ensure that multiple items can be selected.
    result = UI.select_directory(select_multiple: true)
    assert_kind_of(Array, result)
    assert(result.all? { |item| item.is_a?(String)})
  end

  def test_select_directory_directory_argument
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Ensure the dialog starting directory is set.
    result = UI.select_directory(directory: __dir__)
    assert_kind_of(String, result)
  end

  def test_select_directory_forward_slashes
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Ensure the dialog starting directory is set.
    directory = __dir__.gsub("\\", "/")
    result = UI.select_directory(directory: directory)
    assert_kind_of(String, result)
  end

  def test_select_directory_backslashes
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Ensure the dialog starting directory is set.
    directory = __dir__.gsub("/", "\\")
    result = UI.select_directory(directory: directory)
    assert_kind_of(String, result)
  end

  def test_select_directory_unicode
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Ensure the dialog starting directory is set even with unicode
    # characters and that it return unicode characters.

    # Create a Unicode character folder under TC_UI support folder.
    basename = File.basename(__FILE__, ".*")
    directory = File.join(__dir__, basename, "てすと")
    unless File.directory?(directory)
      FileUtils.mkdir_p(directory)
    end

    result = UI.select_directory(directory: directory)
    assert_kind_of(String, result)
    assert_equal(directory, result)
  end

  def test_select_directory_cancel
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Automate: Cancel the dialog.
    result = UI.select_directory
    assert_nil(result)
  end

  def test_select_directory_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    assert_raises ArgumentError do
      UI.select_directory(nil, nil)
    end
  end

  def test_select_directory_invalid_first_argument_number
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    assert_raises TypeError do
      UI.select_directory(123)
    end
  end

  def test_select_directory_invalid_first_argument_point
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    assert_raises TypeError do
      UI.select_directory(ORIGIN)
    end
  end

  def test_select_directory_invalid_options
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Needs manual testing until we can automate UI.")
    # Unknown options should be silently ignored.
    UI.select_directory(bogus: 123)
  end


  # ========================================================================== #
  # method Sketchup.inspector_names

  def test_inspector_names
    expected = %w[
      Components
      Fog
      Instructor
      Layers
      MatchPhoto
      Materials
      Outliner
      Scenes
      Shadows
      SoftenEdges
      Styles
    ]
    expected << 'EntityInfo' if Sketchup.version.to_i >= 21
    expected << 'Overlays' if Sketchup.version.to_f >= 23.0
    expected.sort!
    result =  UI.inspector_names
    assert_kind_of(Array, result)
    result.each { |item|
      assert_kind_of(String, item)
    }
    sorted_result = result.sort
    assert_equal(expected, sorted_result, expected.difference(sorted_result))
  end

  def test_inspector_names_incorrect_number_of_arguments
    assert_raises(ArgumentError) do
      UI.inspector_names(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup.get_clipboard_data

  def test_get_clipboard_data
    skip("Implemented in SU2023.1") if Sketchup.version.to_f < 23.1
    expected = "Hello get_clipboard_data #{Time.now.to_i}"
    UI.set_clipboard_data(expected)

    text = UI.get_clipboard_data
    assert_kind_of(String, text)
    assert_equal(expected, text)
  end

  def test_get_clipboard_data_too_number_of_arguments
    skip("Implemented in SU2023.1") if Sketchup.version.to_f < 23.1
    assert_raises(ArgumentError) do
      UI.get_clipboard_data(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup.set_clipboard_data

  def test_set_clipboard_data
    skip("Implemented in SU2023.1") if Sketchup.version.to_f < 23.1
    expected = "Hello set_clipboard_data #{Time.now.to_i}"
    result = UI.set_clipboard_data(expected)
    assert_kind_of(TrueClass, result)

    actual = UI.get_clipboard_data
    assert_equal(expected, actual)
  end

  def test_set_clipboard_data_too_number_of_arguments
    skip("Implemented in SU2023.1") if Sketchup.version.to_f < 23.1
    assert_raises(ArgumentError) do
      UI.set_clipboard_data('Hello', nil)
    end
  end

  def test_set_clipboard_data_invalid_argument_nil
    skip("Implemented in SU2023.1") if Sketchup.version.to_f < 23.1
    assert_raises(TypeError) do
      UI.set_clipboard_data(nil)
    end
  end

  def test_set_clipboard_data_invalid_argument_number
    skip("Implemented in SU2023.1") if Sketchup.version.to_f < 23.1
    assert_raises(TypeError) do
      UI.set_clipboard_data(123456)
    end
  end

end # class

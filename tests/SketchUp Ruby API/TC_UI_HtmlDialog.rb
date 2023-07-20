# Copyright:: Copyright 2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Christina Eneroth


require "testup/testcase"


# class UI::HtmlDialog
# https://ruby.sketchup.com/UI/HtmlDialog.html
class TC_UI_HtmlDialog < TestUp::TestCase

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
  # method UI::HtmlDialog.get_position

  def test_get_position_visible
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(left: 300, top: 200)
    dialog.set_html("Hello World")
    dialog.show

    left, top = dialog.get_position
    # Use delta to allow for rounding when converting
    # between logical and physical pixels.
    assert_in_delta(300, left, 1)
    assert_in_delta(200, top, 1)

    dialog.close
  ensure
    dialog.close if dialog
  end

  def test_get_position_not_shown
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(left: 300, top: 200)
    dialog.set_html("Hello World")
    # Not calling show.

    position = dialog.get_position
    assert_nil(position)
  end

  def test_get_position_hidden
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(left: 300, top: 200)
    dialog.set_html("Hello World")
    dialog.show
    dialog.close

    position = dialog.get_position
    assert_nil(position)

    dialog.close
  ensure
    dialog.close if dialog
  end

  def test_read_guid_too_many_arguments
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(left: 300, top: 200)
    dialog.set_html("Hello World")

    assert_raises(ArgumentError) do
      dialog.get_position(100)
    end
  end

  # ========================================================================== #
  # method UI::HtmlDialog.get_size

  def test_get_size_visible
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(width: 300, height: 200)
    dialog.set_html("Hello World")
    dialog.show

    left, top = dialog.get_size
    # Use delta to allow for rounding when converting
    # between logical and physical pixels.
    assert_in_delta(300, width, 1)
    assert_in_delta(200, height, 1)

    dialog.close
  ensure
    dialog.close if dialog
  end

  def test_get_size_not_shown
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(width: 300, height: 200)
    dialog.set_html("Hello World")
    # Not calling show.

    size = dialog.get_size
    assert_nil(size)
  end

  def test_get_size_hidden
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(width: 300, height: 200)
    dialog.set_html("Hello World")
    dialog.show
    dialog.close

    size = dialog.get_size
    assert_nil(size)

    dialog.close
  ensure
    dialog.close if dialog
  end

    def test_get_size_too_many_arguments
    skip("Implemented in SU 2021.1") if Sketchup.version.to_f < 21.1
    skip("Causes crash (SKEXT-2811)")

    dialog = UI::HtmlDialog.new(width: 300, height: 200)
    dialog.set_html("Hello World")

    assert_raises(ArgumentError) do
      dialog.get_size(100)
    end
  end

end # class

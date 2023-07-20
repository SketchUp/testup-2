# Copyright:: Copyright 2015 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Page
class TC_Sketchup_Pages < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::Pages.erase

  def test_erase_api_example
    page = Sketchup.active_model.pages.add('FooBar')
    Sketchup.active_model.pages.erase(page)
  end

  def test_erase
    pages = Sketchup.active_model.pages
    page = pages.add('TC_Sketchup_Pages')

    pages.erase(page)
    assert_equal(0, pages.size)
  end

  def test_erase_ensure_no_zombie
    skip('Fixed in SU2016') if Sketchup.version.to_i < 16
    pages = Sketchup.active_model.pages
    page = pages.add('TC_Sketchup_Pages')
    page.set_attribute('Test', 'foo', 'bar')
    attributes = page.attribute_dictionaries
    dictionary = page.attribute_dictionaries['Test']
    axes = page.axes

    pages.erase(page)
    assert(page.deleted?)
    assert(attributes.deleted?)
    assert(dictionary.deleted?)
    assert(axes.deleted?)
  end

  def test_erase_incorrect_number_of_arguments_zero
    pages = Sketchup.active_model.pages
    page = pages.add('TC_Sketchup_Pages')

    assert_raises(ArgumentError) do
      pages.erase
    end
  end

  def test_erase_incorrect_number_of_arguments_two
    pages = Sketchup.active_model.pages
    page = pages.add('TC_Sketchup_Pages')

    assert_raises(ArgumentError) do
      pages.erase('TC_Sketchup_Pages', 'Bar')
    end
  end

  def test_erase_invalid_argument_nil
    pages = Sketchup.active_model.pages
    page = pages.add('TC_Sketchup_Pages')

    assert_raises(TypeError) do
      pages.erase(nil)
    end
  end

  def test_erase_invalid_argument_number
    pages = Sketchup.active_model.pages
    page = pages.add('TC_Sketchup_Pages')

    assert_raises(TypeError) do
      pages.erase(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Pages.show_frame_at

  def test_show_frame_at_api_example
    model = Sketchup.active_model
    pages = model.pages
    pages.add("Page 1")
    pages.add("Page 2")
    page, ratio = pages.show_frame_at(1.8)
  end

  def test_show_frame_at_with_pages
    model = Sketchup.active_model
    model.options["SlideshowOptions"]["SlideTime"] = 1.0
    model.options["PageOptions"]["ShowTransition"] = true
    model.options["PageOptions"]["TransitionTime"] = 2.0
    pages = model.pages
    page1 = pages.add("Page 1")
    page2 = pages.add("Page 2")
    result = pages.show_frame_at(1.8)
    assert_kind_of(Array, result)
    page, ratio = result
    assert_kind_of(Sketchup::Page, page)
    assert_equal(page1, page)
    assert_kind_of(Float, ratio)
    assert_equal(0.4, ratio)
  end

  def test_show_frame_at_without_pages
    # skip('Crash fixed in SketchUp 2019') if Sketchup.version.to_i < 19
    # TODO(thomthom): The client version isn't bumped to 2019 yet, which cause
    #   challenges for conditional tests like this.
    skip('Crash fixed in SketchUp 2019') if Sketchup.version.to_f < 18.1
    pages = Sketchup.active_model.pages
    result = pages.show_frame_at(1.8)
    assert_nil(result)
  end

  def test_show_frame_at_incorrect_number_of_arguments_zero
    pages = Sketchup.active_model.pages
    assert_raises(ArgumentError) do
      result = pages.show_frame_at
    end
  end

  def test_show_frame_at_incorrect_number_of_arguments_two
    pages = Sketchup.active_model.pages
    assert_raises(ArgumentError) do
      result = pages.show_frame_at(1.8, 'and another one')
    end
  end

  def test_show_frame_at_invalid_argument_string
    pages = Sketchup.active_model.pages
    assert_raises(TypeError) do
      result = pages.show_frame_at('not a number')
    end
  end

  def test_show_frame_at_invalid_argument_nil
    pages = Sketchup.active_model.pages
    assert_raises(TypeError) do
      result = pages.show_frame_at(nil)
    end
  end

end # class

# Copyright:: Copyright 2015 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Page
# http://www.sketchup.com/intl/developer/docs/ourdoc/pages
class TC_Sketchup_Pages < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::Pages.erase
  # http://www.sketchup.com/intl/developer/docs/ourdoc/pages#erase

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

end # class

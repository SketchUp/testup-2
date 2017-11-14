# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"

# class Sketchup::Page
class TC_Sketchup_Page < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::Page.include_in_animation?

  def test_include_in_animation_Query_api_example
    model = Sketchup.active_model
    in_animation = model.pages.select { |page| page.include_in_animation? }
  end

  def test_include_in_animation_Query
    page = Sketchup.active_model.pages.add('FooBar')
    assert(page.include_in_animation?)
    assert_kind_of(TrueClass, page.include_in_animation?)

    page.include_in_animation = false
    refute(page.include_in_animation?)
    assert_kind_of(FalseClass, page.include_in_animation?)
  end

  def test_include_in_animation_Query_incorrect_number_of_arguments
    page_method = Sketchup::Page.instance_method(:include_in_animation?)
    assert_equal(0, page_method.arity)

    page = Sketchup.active_model.pages.add('FooBar')
    assert_raises(ArgumentError) do
      page.include_in_animation?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Page.include_in_animation=

  def test_include_in_animation_Set_api_example
    model = Sketchup.active_model
    model.pages.each { |page|
      page.include_in_animation = false
    }
  end

  def test_include_in_animation_Set
    page = Sketchup.active_model.pages.add('FooBar')
    assert(page.include_in_animation?)

    page.include_in_animation = false
    refute(page.include_in_animation?)

    page.include_in_animation = true
    assert(page.include_in_animation?)
  end

  def test_include_in_animation_Set_number_of_arguments
    page_method = Sketchup::Page.instance_method(:include_in_animation=)
    assert_equal(1, page_method.arity)
  end

end # class

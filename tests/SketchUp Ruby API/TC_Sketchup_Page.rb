# Copyright:: Copyright 2017-2020 Trimble Inc.
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

  def test_page_set_drawingelement_invalid_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    page = Sketchup.active_model.pages.add('FooBar')
    assert_raises(TypeError, "wrong argument type (expected Sketchup::Drawingelement).") do
      page.set_drawingelement_visibility(nil, true)
    end
  end

  def test_page_get_drawingelement_invalid_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    page = Sketchup.active_model.pages.add('FooBar')
    assert_raises(TypeError, "wrong argument type (expected Sketchup::Drawingelement).") do
      page.get_drawingelement_visibility(nil)
    end
  end

  def test_page_get_drawingelement_get_and_set
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    entities = Sketchup.active_model.entities
    point1 = Geom::Point3d.new(10,0,0)
    constpoint = entities.add_cpoint(point1)
    page1 = Sketchup.active_model.pages.add('page1')
    page2 = Sketchup.active_model.pages.add('page2')

    page1.set_drawingelement_visibility(constpoint, true)
    page2.set_drawingelement_visibility(constpoint, false)

    assert_equal(true, page1.get_drawingelement_visibility(constpoint))
    assert_equal(false, page2.get_drawingelement_visibility(constpoint))

    Sketchup.active_model.pages.selected_page = page1
    assert_equal(false, constpoint.hidden?)

    Sketchup.active_model.pages.selected_page = page2
    assert_equal(true, constpoint.hidden?)
  end

  # ========================================================================== #
  # method Sketchup::Page.use_hidden_geometry?

  def test_use_hidden_geometry_Query_api_example
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    model = Sketchup.active_model
    use_hidden_geometry =
        model.pages.select { |page| page.use_hidden_geometry? }
  end

  def test_use_hidden_geometry_Query
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page = Sketchup.active_model.pages.add('HiddenGeomPage')
    assert(page.use_hidden_geometry?)
    assert_kind_of(TrueClass, page.use_hidden_geometry?)

    page.use_hidden_geometry = false
    refute(page.use_hidden_geometry?)
    assert_kind_of(FalseClass, page.use_hidden_geometry?)
  end

  def test_use_hidden_geometry_Query_incorrect_number_of_arguments
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page_method = Sketchup::Page.instance_method(:use_hidden_geometry?)
    assert_equal(0, page_method.arity)

    page = Sketchup.active_model.pages.add('HiddenGeomPage')
    assert_raises(ArgumentError) do
      page.use_hidden_geometry?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Page.use_hidden_geometry=

  def test_use_hidden_geometry_Set_api_example
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    model = Sketchup.active_model
    model.pages.each { |page|
      page.use_hidden_geometry = false
    }
  end

  def test_use_hidden_geometry_Set
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page = Sketchup.active_model.pages.add('HiddenGeomPage1')
    assert(page.use_hidden_geometry?)

    page.use_hidden_geometry = false
    refute(page.use_hidden_geometry?)

    page.use_hidden_geometry = true
    assert(page.use_hidden_geometry?)
  end

  def test_use_hidden_geometry_Set_number_of_arguments
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page_method = Sketchup::Page.instance_method(:use_hidden_geometry=)
    assert_equal(1, page_method.arity)
  end

  # ========================================================================== #
  # method Sketchup::Page.use_hidden_objects?

  def test_use_hidden_objects_Query_api_example
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    model = Sketchup.active_model
    use_hidden_objects =
        model.pages.select { |page| page.use_hidden_objects? }
  end

  def test_use_hidden_objects_Query
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page = Sketchup.active_model.pages.add('HiddenObjectsPage')
    assert(page.use_hidden_objects?)
    assert_kind_of(TrueClass, page.use_hidden_objects?)

    page.use_hidden_objects = false
    refute(page.use_hidden_objects?)
    assert_kind_of(FalseClass, page.use_hidden_objects?)
  end

  def test_use_hidden_objects_Query_incorrect_number_of_arguments
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page_method = Sketchup::Page.instance_method(:use_hidden_objects?)
    assert_equal(0, page_method.arity)

    page = Sketchup.active_model.pages.add('HiddenObjectsPage')
    assert_raises(ArgumentError) do
      page.use_hidden_objects?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Page.use_hidden_objects=

  def test_use_hidden_objects_Set_api_example
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    model = Sketchup.active_model
    model.pages.each { |page|
      page.use_hidden_objects = false
    }
  end

  def test_use_hidden_objects_Set
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page = Sketchup.active_model.pages.add('HiddenObjectsPage1')
    assert(page.use_hidden_objects?)

    page.use_hidden_objects = false
    refute(page.use_hidden_objects?)

    page.use_hidden_objects = true
    assert(page.use_hidden_objects?)
  end

  def test_use_hidden_objects_Set_number_of_arguments
    skip("Added in SU2020.1") if Sketchup.version.to_f < 20.1
    page_method = Sketchup::Page.instance_method(:use_hidden_objects=)
    assert_equal(1, page_method.arity)
  end

end # class

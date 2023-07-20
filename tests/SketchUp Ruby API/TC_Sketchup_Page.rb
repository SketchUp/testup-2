# Copyright:: Copyright 2017-2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"

# class Sketchup::Page
class TC_Sketchup_Page < TestUp::TestCase

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


  # ========================================================================== #
  # method Sketchup::Page.set_drawingelement_visibility

  def test_set_drawingelement_visibility_invalid_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    page = Sketchup.active_model.pages.add('FooBar')
    assert_raises(TypeError, "wrong argument type (expected Sketchup::Drawingelement).") do
      page.set_drawingelement_visibility(nil, true)
    end
  end


  # ========================================================================== #
  # method Sketchup::Page.get_drawingelement_visibility

  def test_get_drawingelement_visibility_invalid_arguments
    skip("Added in SU2020.0") if Sketchup.version.to_i < 20
    page = Sketchup.active_model.pages.add('FooBar')
    assert_raises(TypeError, "wrong argument type (expected Sketchup::Drawingelement).") do
      page.get_drawingelement_visibility(nil)
    end
  end

  def test_get_drawingelement_visibility_get_and_set
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


  # ========================================================================== #
  # method Sketchup::Page.set_visibility

  def test_set_visibility_layer
    model = Sketchup.active_model
    page = model.pages.add('TestUp')
    layer = model.layers.add('Hello')

    result = page.set_visibility(layer, false)
    assert_equal(page, result)
    assert_includes(page.layers, layer)

    if Sketchup.version.to_i >= 20
      model.pages.selected_page = page
      edge = model.entities.add_line([0, 0, 0], [9, 9, 9])
      edge.layer = layer
      refute(model.drawing_element_visible?([edge]))
    end
  end

  def test_set_visibility_layer_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    page = model.pages.add('TestUp')
    folder = model.layers.add_folder('Hello')
    layer = model.layers.add_layer('World')
    layer.folder = folder

    result = page.set_visibility(folder, false)
    assert_equal(page, result)
    assert_includes(page.layer_folders, folder)

    model.pages.selected_page = page
    edge = model.entities.add_line([0, 0, 0], [9, 9, 9])
    edge.layer = layer
    refute(model.drawing_element_visible?([edge]))
  end

  def test_set_visibility_too_many_arguments
    model = Sketchup.active_model
    pages = model.pages
    page = pages.add('TestUp')
    layer = model.layers.add('Hello')

    assert_raises(ArgumentError) do
      page.set_visibility(layer, false, nil)
    end
  end

  def test_set_visibility_too_few_arguments
    model = Sketchup.active_model
    pages = model.pages
    page = pages.add('TestUp')
    layer = model.layers.add('Hello')

    assert_raises(ArgumentError) do
      page.set_visibility(layer)
    end
  end

  def test_set_visibility_invalid_argument_nil
    skip("Fixed in SU2021.0") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    pages = model.pages
    page = pages.add('TestUp')

    assert_raises(TypeError) do
      page.set_visibility(nil, false)
    end
  end

  def test_set_visibility_invalid_argument_string
    skip("Fixed in SU2021.0") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    pages = model.pages
    page = pages.add('TestUp')
    model.layers.add('Hello')

    assert_raises(TypeError) do
      page.set_visibility("Hello", false)
    end
  end

  def test_set_visibility_invalid_argument_integer
    skip("Fixed in SU2021.0") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    pages = model.pages
    page = pages.add('TestUp')
    model.layers.add('Hello')

    assert_raises(TypeError) do
      page.set_visibility(1, false)
    end
  end

  # ========================================================================== #
  # method Sketchup::Page.layers

  def test_layers
    model = Sketchup.active_model
    page = model.pages.add('TestUp')
    layer = model.layers.add('Hello')
    page.set_visibility(layer, false)

    result = page.layers
    assert_kind_of(Array, result)
    result.each { |item|
      assert_kind_of(Sketchup::Layer, item)
    }
    assert_includes(result, layer)

    if Sketchup.version.to_i >= 20
      model.pages.selected_page = page

      edge = model.entities.add_line([0, 0, 0], [9, 9, 9])
      edge.layer = layer
      refute(model.drawing_element_visible?([edge]))
    end
  end

  def test_layers_too_many_arguments
    model = Sketchup.active_model
    pages = model.pages
    page = pages.add('TestUp')

    assert_raises(ArgumentError) do
      page.layers(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Page.layer_folders

  def test_layer_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    page = model.pages.add('TestUp')
    folder = model.layers.add_folder('Hello')
    layer = model.layers.add_layer('World')
    layer.folder = folder
    page.set_visibility(folder, false)

    result = page.layer_folders
    assert_kind_of(Array, result)
    result.each { |item|
      assert_kind_of(Sketchup::LayerFolder, item)
    }
    assert_includes(result, folder)

    model.pages.selected_page = page

    edge = model.entities.add_line([0, 0, 0], [9, 9, 9])
    edge.layer = layer
    refute(model.drawing_element_visible?([edge]))
  end

  def test_layer_folders_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    pages = model.pages
    page = pages.add('TestUp')

    assert_raises(ArgumentError) do
      page.layer_folders(nil)
    end
  end

end # class

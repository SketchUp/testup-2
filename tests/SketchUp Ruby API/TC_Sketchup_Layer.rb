# Copyright:: Copyright 2018-2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi

require "testup/testcase"

# class Sketchup::Layer
class TC_Sketchup_Layer < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # class Sketchup::Layer

  def test_class
    layers = Sketchup.active_model.layers
    layer = layers.add('Hello')
    assert_kind_of(Sketchup::Layer, layer)
    assert_kind_of(Sketchup::Entity, layer)
    assert_kind_of(Comparable, layer)
  end


  # ========================================================================== #
  # method Sketchup::Layer#==

  def test_Operator_Equal
    layers = Sketchup.active_model.layers
    layer1 = layers.add('bacon')
    layer2 = layers.add('pork')
    status = layer1 == layer2
    refute(status)

    bacon_layer = layers['bacon']
    status = layer1 == bacon_layer
    assert_equal(true, status)
  end

  def test_Operator_Equal_different_data_types
    layers = Sketchup.active_model.layers
    layer1 = layers.add('bacon')
    status = layer1 == Geom::Point3d.new(0, 0, 0)
    refute(status)

    status = layer1 == 'bacon'
    refute(status)
  end


  # ========================================================================== #
  # method Sketchup::Layer#<=>

  def test_Operator_Sort
    layers = Sketchup.active_model.layers
    layer1 = layers[0] # the infamous layer0

    # Create a layer with a name that is alphabetically prior to "Layer0"
    bacon_layer = layers.add('bacon')
    status = layer1 <=> bacon_layer
    assert_equal(1, status)
    assert_kind_of(Integer, status)

    status = bacon_layer <=> layer1
    assert_equal(-1, status)
 
    # Create a layer with a name that is alphabetically after "Untagged"
    vinegar_layer = layers.add('vinegar')
    status = layer1 <=> vinegar_layer
    assert_equal(-1, status)

    status = vinegar_layer <=> layer1
    assert_equal(1, status)

    status = layer1 <=> 'vinegar'
    assert_equal(-1, status)
  end

  def test_Operator_Sort_Layer0
    # This test is for pre SketchUp 2020, using Layer0 display name "Layer0"
    skip("Layers renamed to Tags in 2020") if Sketchup.version.to_i >= 20

    layers = Sketchup.active_model.layers
    layer1 = layers[0] # the infamous layer0
    pork_layer = layers.add('pork')
    status = layer1 <=> pork_layer
    assert_equal(-1, status)
    status = pork_layer <=> layer1
    assert_equal(1, status)
  end

  def test_Operator_Sort_Untagged
    # This test is for SketchUp 2020 and beyond, using Layer0 display name "Untagged"
    skip("Layers renamed to Tags in 2020") if Sketchup.version.to_i < 20

    layers = Sketchup.active_model.layers
    layer1 = layers[0] # the infamous layer0, display name "Untagged"

    pork_layer = layers.add('pork')
    status = layer1 <=> pork_layer
    assert_equal(1, status)
    status = pork_layer <=> layer1
    assert_equal(-1, status)
  end

  def test_Operator_Sort_different_data_types
    layers = Sketchup.active_model.layers
    layer1 = layers[0] # the infamous layer0
    bacon_layer = layers.add('bacon')
    pork_layer = layers.add('pork')

    # NOTE: This should have been returning `nil`
    assert_raises(ArgumentError) do
      layer1 <=> 1
    end

    assert_raises(ArgumentError) do
      layer1 <=> Geom::Point3d.new(0, 0, 0)
    end

    assert_raises(ArgumentError) do
      layer1 <=> 'steak'
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#color

  def test_color
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    color = bacon_layer.color
    assert_kind_of(Sketchup::Color, color)
    # can't unit test the RGBA since the layer gets assigned a random color
    # there's another test that will test a setting of a color and getting
    # the color to check the RGBA values
  end

  def test_color_too_many_arguments
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    assert_raises(ArgumentError) do
      bacon_layer.color(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#color=

  def test_color_Set_no_alpha
    skip("Color Transparency Changed in 2020") if Sketchup.version.to_i < 20
    # New behaviour from SU2020
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    bacon_layer.color = Sketchup::Color.new(100, 150, 200, 250)
    color = bacon_layer.color
    assert_kind_of(Sketchup::Color, color)
    assert_equal(100, color.red)
    assert_equal(150, color.green)
    assert_equal(200, color.blue)
    assert_equal(255, color.alpha)
  end

  def test_color_Set_alpha
    skip("Color Transparency Changed in 2020") if Sketchup.version.to_i >= 20
    # Old behaviour prior to SU2020.
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    bacon_layer.color = Sketchup::Color.new(100, 150, 200, 250)
    color = bacon_layer.color
    assert_kind_of(Sketchup::Color, color)
    assert_equal(100, color.red)
    assert_equal(150, color.green)
    assert_equal(200, color.blue)
    assert_equal(250, color.alpha)
  end

  def test_color_Set_by_color_name
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    # Chocolate	210,105,30
    bacon_layer.color = 'Chocolate'
    color = bacon_layer.color
    assert_kind_of(Sketchup::Color, color)
    assert_equal(210, color.red)
    assert_equal(105, color.green)
    assert_equal(30, color.blue)
    assert_equal(255, color.alpha)
  end

  def test_color_Set_by_index
    # interesting...
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    bacon_layer.color = 1
    color = bacon_layer.color
    assert_kind_of(Sketchup::Color, color)
    assert_equal(1, color.red)
    assert_equal(0, color.green)
    assert_equal(0, color.blue)
    assert_equal(255, color.alpha)

    bacon_layer.color = -1
    color = bacon_layer.color
    assert_kind_of(Sketchup::Color, color)
    assert_equal(255, color.red)
    assert_equal(255, color.green)
    assert_equal(255, color.blue)
    assert_equal(255, color.alpha)
  end

  def test_color_Set_invalid_arguments
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    
    assert_raises(TypeError) do
      bacon_layer.color = nil
    end

    assert_raises(ArgumentError) do
      bacon_layer.color = 'porkfat'
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#name

  def test_name
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    name = bacon_layer.name
    assert_equal('bacon', name)
  end

  def test_name_too_many_arguments
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    assert_raises(ArgumentError) do
      bacon_layer.name(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#name=

  def test_name_Set
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    name = bacon_layer.name
    assert_equal('bacon', name)
    bacon_layer.name = 'pork'
    name = bacon_layer.name
    assert_equal('pork', name)
  end

  def test_name_Set_invalid_arguments
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    assert_raises(ArgumentError) do 
      bacon_layer.name = 1
    end

    assert_raises(ArgumentError) do
      bacon_layer.name = nil
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#display_name

  def test_display_name_Layer0
    # This test is for pre SketchUp 2020, using Layer0 display name "Layer0"
    skip("Added in 2020.0") if Sketchup.version.to_i >= 20

    layers = Sketchup.active_model.layers
    layer0 = layers[0] # the infamous layer0
    
    name = layer0.name
    assert_equal(name, "Layer0")
  end

  def test_display_name_Untagged0
    # This test is for post SketchUp 2020, using Layer0 display name "Untagged"
    skip("Added in 2020.0") if Sketchup.version.to_i < 20

    layers = Sketchup.active_model.layers
    layer0 = layers[0] # the infamous layer0
    
    name = layer0.name
    assert_equal(name, "Layer0")
    
    display_name = layer0.display_name
    assert_equal(display_name, "Untagged")
  end


  # ========================================================================== #
  # method Sketchup::Layer#page_behavior

  def test_page_behavior
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    val = bacon_layer.page_behavior
    assert_equal(LAYER_VISIBLE_BY_DEFAULT, bacon_layer.page_behavior)
  end

  def test_page_behavior_too_many_arguments
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    assert_raises(ArgumentError) do
      bacon_layer.page_behavior(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#page_behavior=

  def test_page_behavior_Set
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    val = bacon_layer.page_behavior
    bacon_layer.page_behavior = LAYER_HIDDEN_BY_DEFAULT
    assert_equal(LAYER_HIDDEN_BY_DEFAULT, bacon_layer.page_behavior)

    bacon_layer.page_behavior = LAYER_IS_VISIBLE_ON_NEW_PAGES | LAYER_HIDDEN_BY_DEFAULT
    assert_equal(0x0011, bacon_layer.page_behavior)
  end

  def test_page_behavior_Set_invalid_arguments
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')

    assert_raises(TypeError) do
      bacon_layer.page_behavior = 'steak'
    end

    assert_raises(TypeError) do
      bacon_layer.page_behavior = nil
    end

    assert_raises(TypeError) do
      bacon_layer.page_behavior = Geom::Point3d.new(0, 0, 0)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#visible?

  def test_visible_Query
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    val = bacon_layer.visible?
    assert_equal(true, val)
    assert_kind_of(TrueClass, val)
    bacon_layer.visible = false
    val = bacon_layer.visible?
    refute(val)
    assert_kind_of(FalseClass, val)
  end

  def test_visible_Query_too_many_arguments
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    assert_raises(ArgumentError) do
      bacon_layer.visible?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#visible=

  def test_visible_Set
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')

    bacon_layer.visible = false
    refute(bacon_layer.visible?)

    bacon_layer.visible = true
    assert_equal(true, bacon_layer.visible?)
  end

  def test_visible_Set_integer
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    bacon_layer.visible = 1
    assert_equal(true, bacon_layer.visible?)
    bacon_layer.visible = 0
    assert_equal(true, bacon_layer.visible?)
  end

  def test_visible_Set_nil
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    assert_equal(true, bacon_layer.visible?)
    bacon_layer.visible = nil
    assert_equal(false, bacon_layer.visible?)
  end

  def test_visible_Set_string
    layers = Sketchup.active_model.layers
    bacon_layer = layers.add('bacon')
    bacon_layer.visible = 'what'
    assert_equal(true, bacon_layer.visible?)
    bacon_layer.visible = ''
    assert_equal(true, bacon_layer.visible?)
  end

  def test_visible_Set_deselect_hidden
    model = Sketchup.active_model
    layer = model.layers.add_layer('World')
    face = model.entities.add_face(
      [0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0]
    )
    face.layer = layer
    model.selection.add(model.entities.to_a)
    assert_equal(5, model.selection.size)

    layer.visible = false

    assert_equal(4, model.selection.size)
    expected = model.entities.to_a - [face]
    actual = model.selection.to_a
    assert(expected.sort_by(&:entityID), actual.sort_by(&:entityID))
  end

  def test_visible_Set_active_path
    skip('TODO(thomthom): Pending common helper function')
    skip('Testable in 2020.0') if Sketchup.version.to_f < 20.0
    model = Sketchup.active_model
    layers = model.layers
    bacon_layer = layers.add('bacon')
    group = model.entities.add_group
    group.entities.add_line([0, 0, 0], [9, 9, 9])
    group.layer = bacon_layer
    model.active_path = [group]

    assert_raises(ArgumentError) do
      bacon_layer.visible = false
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#line_style

  def test_line_style_default
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    Sketchup.active_model.layers[0].line_style = nil
    line_style = Sketchup.active_model.layers[0].line_style
    assert_nil(line_style)
  end

  def test_line_style_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers[0].line_style(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer#line_style=

  def test_line_style_Set
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    line_style = Sketchup.active_model.line_styles['Dot']
    Sketchup.active_model.layers[0].line_style = line_style

    get_line_style = Sketchup.active_model.layers[0].line_style
    assert_kind_of(Sketchup::LineStyle, get_line_style)
    assert_kind_of(Sketchup::Entity, get_line_style)
    assert_equal('Dot', get_line_style.name)
  end

  def test_line_style_Set_invalid_type
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(TypeError) do
      Sketchup.active_model.layers[0].line_style = "String"
    end
  end

  def test_line_style_object_id
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    line_style = Sketchup.active_model.line_styles['Dot']
    Sketchup.active_model.layers[0].line_style = line_style
    assert_equal(Sketchup.active_model.layers[0].line_style.object_id,
        Sketchup.active_model.layers[0].line_style.object_id)
  end


  # ========================================================================== #
  # method Sketchup::Layer.folder

  def test_folder_without_folder
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    layer = layers.add('World')
    assert_nil(layer.folder)
  end

  def test_folder_with_folder
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    layer = layers.add('World')
    folder = layers.add_folder('Hello')
    folder.add_layer(layer)

    result = layer.folder
    assert_kind_of(Sketchup::LayerFolder, result)
    assert_equal(folder, result)
  end

  def test_folder_too_many_arguments
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    layer = layers.add('World')
    folder = layers.add_folder('Hello')
    folder.add_layer(layer)

    assert_raises(ArgumentError) do
      layer.folder(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layer.folder=

  def test_folder_Set_folder
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    layer = layers.add('World')

    layer.folder = folder
    assert_equal(folder, layer.folder)
  end

  def test_folder_Set_nil
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    layer = layers.add('World')
    layer.folder = folder
    assert_equal(1, folder.size)

    layer.folder = nil
    assert_nil(layer.folder)
    assert_equal(0, folder.size)
  end

  def test_folder_Set_layer0
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    layer0 = layers[0]

    assert_raises(ArgumentError) do
      layer0.folder = folder
    end
  end

  def test_folder_Set_invalid_argument_string
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    layer = layers.add('World')

    assert_raises(TypeError) do
      layer.folder = 'Hello'
    end
  end

  def test_folder_Set_invalid_argument_numeric
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    layer = layers.add('World')

    assert_raises(TypeError) do
      layer.folder = 123
    end
  end

end
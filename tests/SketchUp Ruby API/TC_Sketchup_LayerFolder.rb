# Copyright:: Copyright 2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"

# class Sketchup::LayerFolder
class TC_Sketchup_LayerFolder < TestUp::TestCase

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
  # class Sketchup::LayerFolder

  def test_class
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    assert_kind_of(Sketchup::LayerFolder, folder)
    assert_kind_of(Sketchup::Entity, folder)
    assert_kind_of(Comparable, folder)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#==

  def test_Operator_Equal
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = layers.add_folder('World')

    refute_equal(folder1.entityID, folder2.entityID)
    refute(folder1 == folder2)

    # Grab a second reference
    folder_hello = layers.folders.find { |folder| folder.name == 'Hello' }
    assert(folder1 == folder_hello)
  end

  def test_Operator_Equal_same_name
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = layers.add_folder('Hello')

    refute_equal(folder1.entityID, folder2.entityID)
    refute(folder1 == folder2, "folders should not be considered equal")
  end

  def test_Operator_Equal_deleted_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = layers.add_folder('World')
    layers.remove_folder(folder2)

    refute(folder1 == folder2, "folders should not be considered equal")
  end

  def test_Operator_Equal_different_type_string
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    refute(folder == 'Hello')
  end

  def test_Operator_Equal_different_type_number
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    refute(folder == 123)
  end

  def test_Operator_Equal_different_type_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    refute(folder == nil)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#<=>

  def test_Operator_Sort
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = layers.add_folder('Hello')
    folder3 = layers.add_folder('World')

    assert_equal(0, folder1 <=> folder1)
    assert_equal(0, folder1 <=> folder2)

    assert_equal(-1, folder2 <=> folder3)
    assert_equal( 1, folder3 <=> folder2)
  end

  def test_Operator_Sort_against_deleted_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    folder1 = model.layers.add_folder('Hello')
    folder2 = model.layers.add_folder('World')
    model.layers.remove_folder(folder2)
    # Sort deleted folders to the end, as we don't have any name to sort by.
    assert_nil(folder1 <=> folder2)
  end

  def test_Operator_Sort_different_types_number
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_nil(folder <=> 1)
  end

  def test_Operator_Sort_different_types_number_string
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_nil(folder <=> 'Hello')
  end

  def test_Operator_Sort_different_types_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_nil(folder <=> nil)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#name

  def test_name
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')

    name = folder.name
    assert_kind_of(String, name)
    assert_equal('Hello', name)
  end

  def test_name_duplicate_allowed
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = layers.add_folder('Hello')

    assert_equal('Hello', folder1.name)
    assert_equal('Hello', folder2.name)
    refute_equal(folder1.entityID, folder2.entityID)
  end

  def test_name_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(ArgumentError) do
      folder.name(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#name=

  def test_name_Set
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    assert_equal('Hello', folder.name)

    folder.name = 'World'
    assert_equal('World', folder.name)
  end

  def test_name_Set_same_name
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    assert_equal('Hello', folder.name)

    folder.name = 'Hello'
    assert_equal('Hello', folder.name)
  end

  def test_name_Set_empty_string
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(ArgumentError) do 
      folder.name = ''
    end
    assert_equal('Hello', folder.name)
  end

  def test_name_Set_invalid_arguments_numeric
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(TypeError) do 
      folder.name = 1
    end
    assert_equal('Hello', folder.name)
  end

  def test_name_Set_invalid_arguments_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(TypeError) do
      folder.name = nil
    end
    assert_equal('Hello', folder.name)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#display_name (alias: #name)

  def test_display_name
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    original_method = Sketchup::LayerFolder.instance_method(:name)
    aliased_method = Sketchup::LayerFolder.instance_method(:display_name)
    assert_equal(original_method.name, aliased_method.original_name)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#visible?

  def test_visible_Query_root_level
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    assert(folder.visible?)
  end

  def test_visible_Query_nested
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = folder1.add_folder('World')
    folder1.visible = false

    refute(folder1.visible?)
    assert(folder2.visible?)
  end

  def test_visible_Query_invalid_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(ArgumentError) do 
      folder.visible?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#visible=

  def test_visible_Set
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert(folder.visible?) # Default state

    folder.visible = false
    refute(folder.visible?)

    folder.visible = true
    assert(folder.visible?)
  end

  def test_visible_Set_falsy
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    folder.visible = nil
    refute(folder.visible?)
  end

  def test_visible_Set_truthy_string
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    # Anything that isn't `false` or `nil` is truthy in Ruby.
    folder = Sketchup.active_model.layers.add_folder('Hello')
    folder.visible = false

    folder.visible = 'false'
    assert(folder.visible?)
  end

  def test_visible_Set_truthy_number
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    folder.visible = false

    folder.visible = 0
    assert(folder.visible?)
  end

  def test_visible_Set_deselect_hidden
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    folder = model.layers.add_folder('Hello')
    layer = model.layers.add_layer('World')
    folder.add_layer(layer)
    face = model.entities.add_face(
      [0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0]
    )
    face.layer = layer
    model.selection.add(model.entities.to_a)
    assert_equal(5, model.selection.size)

    folder.visible = false

    assert_equal(4, model.selection.size)
    expected = model.entities.to_a - [face]
    actual = model.selection.to_a
    assert(expected.sort_by(&:entityID), actual.sort_by(&:entityID))
  end

  def test_visible_Set_active_path
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    layers = model.layers
    bacon_layer = layers.add('World')
    group = model.entities.add_group
    group.entities.add_line([0, 0, 0], [9, 9, 9])
    group.layer = bacon_layer
    model.active_path = [group]
    folder = layers.add_folder('Hello')
    folder.add_layer(bacon_layer)

    assert_raises(ArgumentError) do
      folder.visible = false
    end
    assert(folder.visible?, "layer folder did not remain visible")
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder.folder

  def test_folder_without_folder
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    assert_nil(folder.folder)
  end

  def test_folder_with_folder
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = folder1.add_folder('World')

    result = folder2.folder
    assert_kind_of(Sketchup::LayerFolder, result)
    assert_equal(folder1, result)
  end

  def test_folder_too_many_arguments
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')

    assert_raises(ArgumentError) do
      folder.folder(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder.folder=

  def test_folder_Set_folder
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = layers.add_folder('World')

    folder2.folder = folder1
    assert_equal(folder1, folder2.folder)
    assert_includes(folder1.folders, folder2)
    refute_includes(layers.folders, folder2)
  end

  def test_folder_Set_nil
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = folder1.add_folder('World')

    folder2.folder = nil
    assert_nil(folder2.folder)
    refute_includes(folder1.folders, folder2)
    assert_includes(layers.folders, folder2)
  end

  def test_folder_Set_invalid_argument_string
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    
    assert_raises(TypeError) do
      folder.folder = 'World'
    end
  end

  def test_folder_Set_invalid_argument_numeric
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    
    assert_raises(TypeError) do
      folder.folder = 123
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#add_layer

  def test_add_layer
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    layer = manager.add_layer('World')
    assert_nil(layer.folder)
    assert_includes(manager.layers, layer)

    result = folder.add_layer(layer)
    assert_nil(result)
    assert_equal(folder, layer.folder)
    assert_includes(folder.layers, layer)
    refute_includes(manager.layers, layer)
  end

  def test_add_layer_already_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    layer = manager.add_layer('World')
    folder.add_layer(layer)

    # Ensures no errors are raised.
    folder.add_layer(layer)
  end

  def test_add_layer_layer0
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    layer0 = manager[0]

    assert_raises(ArgumentError) do
      folder.add_layer(layer0)
    end
  end

  def test_add_layer_invalid_argument_string
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    # Should have been TypeError, but existing to check for Sketchup::Layer
    # type logic uses ArgumentError.
    assert_raises(ArgumentError) do
      folder.add_layer('World')
    end
  end

  def test_add_layer_invalid_argument_number
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    # Should have been TypeError, but existing to check for Sketchup::Layer
    # type logic uses ArgumentError.
    assert_raises(ArgumentError) do
      folder.add_layer(123)
    end
  end

  def test_add_layer_invalid_argument_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    # Should have been TypeError, but existing to check for Sketchup::Layer
    # type logic uses ArgumentError.
    assert_raises(ArgumentError) do
      folder.add_layer(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#remove_layer

  def test_remove_layer_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    layer = manager.add_layer('World')
    folder.add_layer(layer)

    result = folder.remove_layer(layer)
    assert_nil(result)
    assert_nil(layer.folder)
    refute_includes(folder.layers, layer)
    assert_includes(manager.layers, layer)
  end

  def test_remove_layer_not_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    layer = manager.add_layer('World')

    assert_raises(ArgumentError) do
      folder.remove_layer(layer)
    end
  end

  def test_remove_layer_invalid_argument_string
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    # Should have been TypeError, but existing to check for Sketchup::Layer
    # type logic uses ArgumentError.
    assert_raises(ArgumentError) do
      folder.remove_layer('World')
    end
  end

  def test_remove_layer_invalid_argument_number
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    # Should have been TypeError, but existing to check for Sketchup::Layer
    # type logic uses ArgumentError.
    assert_raises(ArgumentError) do
      folder.remove_layer(123)
    end
  end

  def test_remove_layer_invalid_argument_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    # Should have been TypeError, but existing to check for Sketchup::Layer
    # type logic uses ArgumentError.
    assert_raises(ArgumentError) do
      folder.remove_layer(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#layers

  def test_layers
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    assert_empty(folder.layers)

    layer = manager.add('World')
    folder.add_layer(layer)
    result = folder.layers
    assert_kind_of(Array, result)
    assert_equal(1, result.size)
    assert_includes(result, layer)
  end

  def test_layers_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(ArgumentError) do
      folder.layers(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#add_folder

  def test_add_folder_create
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder1 = manager.add_folder('Hello')

    folder2 = folder1.add_folder('World')
    assert_kind_of(Sketchup::LayerFolder, folder2)
    assert_equal(folder1, folder2.folder)
    assert_includes(folder1.folders, folder2)
    refute_includes(manager.folders, folder2)
  end

  def test_add_folder_move
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    layer1 = manager.add_layer('Foo')
    layer2 = manager.add_layer('Bar')
    folder1 = manager.add_folder('Hello')
    folder2 = manager.add_folder('World')
    folder2.add_layer(layer1)
    folder2.add_layer(layer2)
    assert_nil(folder2.folder)
    assert_includes(manager.folders, folder2)

    result = folder1.add_folder(folder2)
    assert_kind_of(Sketchup::LayerFolder, result)
    assert_equal(folder1, folder2.folder)
    assert_includes(folder1.folders, folder2)
    refute_includes(manager.folders, folder2)
    assert_includes(folder2.layers, layer1)
    assert_includes(folder2.layers, layer2)
  end

  def test_add_folder_already_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder1 = manager.add_folder('Hello')
    folder2 = folder1.add_folder('World')

    # Ensures no errors are raised.
    folder1.add_folder(folder2)
  end

  def test_add_folder_empty_name
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(ArgumentError) do
      folder.add_folder('')
    end
  end

  def test_add_folder_invalid_argument_number
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(TypeError) do
      folder.add_folder(123)
    end
  end

  def test_add_folder_invalid_argument_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(TypeError) do
      folder.add_folder(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#remove_folder

  def test_remove_folder_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    # <manager>
    # +- [Hello]
    #    +- [World]
    #       +- [Universe]
    #       |  +- Layer3
    #       |  +- Layer4
    #       +- Layer1
    #       +- Layer2

    # Hello
    folder1 = manager.add_folder('Hello')

    # World
    folder2 = folder1.add_folder('World')
    folder2_children = %w[Layer1 Layer2].map { |name|
      layer = manager.add(name)
      folder2.add_layer(layer)
      layer
    }

    # Universe
    folder3 = folder2.add_folder('Universe')
    folder3_children = %w[Layer3 Layer4].map { |name|
      layer = manager.add(name)
      folder3.add_layer(layer)
      layer
    }

    folder1.remove_folder(folder2)

    # Anything that was parent to `folder2` should now be parent to `folder1`.
    assert_equal(folder1, folder3.folder)
    folder2_children.each { |layer|
      assert_equal(folder1, layer.folder)
    }

    # The sub-children should remain relative to their parent.
    folder3_children.each { |layer|
      assert_equal(folder3, layer.folder)
    }
  end

  def test_remove_folder_not_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder1 = manager.add_folder('Hello')
    folder2 = manager.add_folder('World') 

    assert_raises(ArgumentError) do
      folder1.remove_folder(folder2)
    end
  end

  def test_remove_folder_too_few_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    assert_raises(ArgumentError) do
      folder.remove_folder
    end
  end

  def test_remove_folder_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder1 = manager.add_folder('Hello')
    folder2 = folder1.add_folder('Hello')

    assert_raises(ArgumentError) do
      folder1.remove_folder(folder2, 'World')
    end
  end

  def test_remove_folder_invalid_argument_string
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(TypeError) do
      folder.remove_folder('World')
    end
  end

  def test_remove_folder_invalid_argument_number
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(TypeError) do
      folder.remove_folder(123)
    end
  end

  def test_remove_folder_invalid_argument_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(TypeError) do
      folder.remove_folder(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#folders

  def test_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder1 = manager.add_folder('Hello')
    assert_empty(folder1.folders)

    folder2 = folder1.add_folder('World')
    result = folder1.folders
    assert_kind_of(Array, result)
    assert_equal(1, result.size)
    assert_includes(result, folder2)
  end

  def test_folders_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    folder = Sketchup.active_model.layers.add_folder('Hello')
    assert_raises(ArgumentError) do
      folder.folders(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::LayerFolder#parent

  def test_parent
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    folder1 = model.layers.add_folder("Folder1")
    folder2 =  folder1.add_folder("Folder2")
    manager = Sketchup.active_model.layers
    assert_kind_of(Sketchup::Layers, folder1.parent)
    assert_equal(manager, folder1.parent)
    assert_kind_of(Sketchup::LayerFolder, folder2.parent)
    assert_equal(folder1, folder2.parent)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#each (alias: #each_layer)

  def test_each
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    original_method = Sketchup::LayerFolder.instance_method(:each_layer)
    aliased_method = Sketchup::LayerFolder.instance_method(:each)
    assert_equal(original_method.name, aliased_method.original_name)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#each_layer

  def test_each_layer
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    layer1 = manager.add('Layer1')
    layer2 = manager.add('Layer2')
    layer3 = manager.add('Layer3')
    folder = manager.add_folder('Folder1')
    folder.add_layer(layer1)
    folder.add_layer(layer2)

    expected = %w[Layer1 Layer2]
    actual = []
    folder.each_layer { |layer|
      assert_kind_of(Sketchup::Layer, layer)
      actual << layer.name
    }
    assert_equal(expected.sort, actual.sort)
  end

  def test_each_layer_empty
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Folder1')

    layers = []
    folder.each_layer { |layer|
      layers << layer
    }
    assert_empty(layers)
  end

  def test_each_layer_modify_collection
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Folder1')
    3.times { |i|
      layer = manager.add_layer("Layer#{i + 1}")
      folder.add_layer(layer)
    }
    surprise = manager.add_layer('Surprise!')

    # Ensure modifying the collection iterated doesn't crash.
    assert_output('', /don't modify the collection while iterating/) do
      folder.each_layer { |layer|
        folder.add_layer(surprise) if layer.name.end_with?('1')
      }
      folder.each_layer { |layer|
        folder.remove_layer(layer) if layer.name.end_with?('2')
      }
    end
  end

  def test_each_layer_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    
    assert_raises(ArgumentError) do
      manager.each_layer(nil) {}
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#each_folder

  def test_each_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    folder1 = manager.add_folder('Folder1')
    folder2 = manager.add_folder('Folder2')
    folder3 = folder1.add_folder('Folder3')
    folder4 = folder1.add_folder('Folder4')

    names = %w[Hello SketchUp World]
    names.each { |name|
      layer = manager.add(name)
      folder1.add_layer(layer)
    }

    expected = %w[Folder3 Folder4]
    actual = []
    folder1.each_folder { |folder|
      assert_kind_of(Sketchup::LayerFolder, folder)
      actual << folder.name
    }
    assert_equal(expected.sort, actual.sort)
  end

  def test_each_folder_empty
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')

    folders = []
    folder.each_folder { |folder|
      folders << folder
    }
    assert_empty(folders)
  end

  def test_each_folder_modify_collection
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder1 = manager.add_folder('Hello')
    3.times { |i| folder1.add_folder("Folder#{i}") }

    # Ensure modifying the collection iterated doesn't crash.
    assert_output('', /don't modify the collection while iterating/) do
      folder1.each_folder { |folder|
        folder1.add_folder("Surprise!") if folder.name.end_with?('1')
      }
      folder1.each_folder { |folder|
        folder1.remove_folder(folder) if folder.name.end_with?('2')
      }
    end
  end

  def test_each_folder_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    
    assert_raises(ArgumentError) do
      folder.each_folder(nil) {}
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#size

  def test_size
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    folder1 = manager.add_folder('Folder1')
    folder2 = manager.add_folder('Folder2')
    folder3 = folder1.add_folder('Folder3')
    folder4 = folder1.add_folder('Folder4')

    names = %w[Hello SketchUp World]
    names.each { |name|
      layer = manager.add(name)
      folder1.add_layer(layer)
    }

    num_layers = folder1.size
    assert_kind_of(Integer, num_layers)
    assert_equal(names.size, num_layers)
  end

  def test_size_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    
    assert_raises(ArgumentError) do
      folder.size(nil) {}
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#length (alias: #size)

  def test_length
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    original_method = Sketchup::LayerFolder.instance_method(:count_layers)
    aliased_method = Sketchup::LayerFolder.instance_method(:length)
    assert_equal(original_method.name, aliased_method.original_name)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#count_layers (alias: #size)

  def test_count_layers
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    original_method = Sketchup::LayerFolder.instance_method(:count_layers)
    aliased_method = Sketchup::LayerFolder.instance_method(:size)
    assert_equal(original_method.name, aliased_method.original_name)
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder#count_folders

  def test_count_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    folder1 = manager.add_folder('Folder1')
    folder2 = manager.add_folder('Folder2')
    folder3 = folder1.add_folder('Folder3')
    folder4 = folder1.add_folder('Folder4')

    names = %w[Hello SketchUp World]
    names.each { |name|
      layer = manager.add(name)
      folder1.add_layer(layer)
    }

    num_folders = folder1.count_folders
    assert_kind_of(Integer, num_folders)
    assert_equal(2, num_folders)
  end

  def test_count_folders_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    
    assert_raises(ArgumentError) do
      folder.count_folders(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder.visible_on_new_pages?

  def test_visible_on_new_pages_Query_default
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    manager = model.layers
    folder = manager.add_folder('Hello')
    layer = manager.add_layer('World')
    layer.folder = folder

    result = folder.visible_on_new_pages?
    assert_kind_of(TrueClass, result)

    # Ensure the folder really is visible on new pages.
    pages = model.pages
    page = pages.add('TestUp')
    refute_includes(page.layer_folders, folder)
    pages.selected_page = page

    edge = model.entities.add_line([0, 0, 0], [9, 9, 9])
    edge.layer = layer
    assert(model.drawing_element_visible?([edge]))
  end

  def test_visible_on_new_pages_Query_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder = manager.add_folder('Hello')
    
    assert_raises(ArgumentError) do
      folder.visible_on_new_pages?(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::LayerFolder.visible_on_new_pages=

  def test_visible_on_new_pages_Set_default
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    manager = model.layers
    folder = manager.add_folder('Hello')
    layer = manager.add_layer('World')
    layer.folder = folder

    folder.visible_on_new_pages = false

    result = folder.visible_on_new_pages?
    assert_kind_of(FalseClass, result)

    # Ensure the folder really is hidden on new pages.
    pages = model.pages
    page = pages.add('TestUp')
    assert_includes(page.layer_folders, folder)
    pages.selected_page = page

    edge = model.entities.add_line([0, 0, 0], [9, 9, 9])
    edge.layer = layer
    refute(model.drawing_element_visible?([edge]))
  end

end
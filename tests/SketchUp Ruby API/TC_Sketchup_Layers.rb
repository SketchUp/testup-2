# Copyright:: Copyright 2014-2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"


# class Sketchup::Layers
class TC_Sketchup_Layers < TestUp::TestCase

  def setup
    model = start_with_empty_model()
    5.times { |index|
      layer = model.layers.add("TestUp %02i" % index)
      create_test_tube(layer)
    }
  end

  def teardown
    # ...
  end


  def create_test_tube(layer)
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation("TestUp2 - Test Tube", true)
    group = entities.add_group
    group.layer = layer
    circle = group.entities.add_circle(ORIGIN, Z_AXIS, 10, 8)
    circle[0].find_faces
    face = group.entities.grep(Sketchup::Face)[0]
    face.pushpull(-50)
    model.commit_operation
    nil
  end


  # ========================================================================== #
  # class Sketchup::Layers

  def test_class
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_kind_of(Sketchup::Layers, layers)
    assert_kind_of(Enumerable, layers)
  end

  # ========================================================================== #
  # method Sketchup::Layers#at

  def test_at_api_example
    layers = Sketchup.active_model.layers
    new_layer = layers.add("MyLayer")
    layer_by_number = layers.at(1)
    layer_by_name = layers.at("MyLayer")
  end

  def test_at_index
    layer = Sketchup.active_model.layers.at(2)
    assert_kind_of(Sketchup::Layer, layer)
  end

  def test_at_string
    layer = Sketchup.active_model.layers.at("TestUp 02")
    assert_kind_of(Sketchup::Layer, layer)
    assert_equal("TestUp 02", layer.name, "Incorrect layer name")
  end

  def test_at_nil
    # Odd, when setting active layer to nil you set it to layer0. But asking
    # for nil cause Argument error. So much for consistency.
    assert_raises(TypeError) do
      Sketchup.active_model.layers.at(nil)
    end
  end

  def test_at_incorrect_number_of_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.at()
    end
  end

  def test_at_incorrect_number_of_arguments_two
    layer = Sketchup.active_model.layers["TestUp 02"]
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.at(layer, nil)
    end
  end

  def test_at_invalid_arguments
    assert_raises(TypeError) do
      Sketchup.active_model.layers.at(ORIGIN)
    end
  end

  def test_at_layer0_equal_untagged
    # Get the default unique name after the Layer->Tag change
    skip("Layers renamed to Tags in 2020") if Sketchup.version.to_i < 20

    untagged = Sketchup.active_model.layers.at('Untagged')
    layer0 = Sketchup.active_model.layers.at('Layer0')

    assert_equal(layer0, untagged);
  end

  def test_at_index_with_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    expected = manager.at(2)

    folder = manager.add_folder('Folder')
    folder.add_layer(manager[1])
    folder.add_layer(manager[2])

    actual = manager.at(2)
    assert_equal(expected, actual)
  end


  # ========================================================================== #
  # method Sketchup::Layers#[] (alias: #at)

  def test_Operator_Get
    model = start_with_empty_model
    layers = Sketchup.active_model.layers
    layer = layers.add("MyLayer")

    assert_equal(layer, layers[1])
    assert_equal(layer, layers["MyLayer"])
  end


  # ========================================================================== #
  # method Sketchup::Layers#add

  def test_add_api_example
    layers = Sketchup.active_model.layers
    layer = layers.add("Test New Layer")
  end

  def test_add_new
    layer_name = "Test New Layer"
    layers = Sketchup.active_model.layers

    layer = layers.add(layer_name)
    assert_kind_of(Sketchup::Layer, layer)
    assert_equal(layer_name, layer.name)
  end

  def test_add_existing
    layer_name = "Test New Layer"
    layers = Sketchup.active_model.layers
    layer1 = layers.add(layer_name)

    layer2 = layers.add(layer_name)
    assert_kind_of(Sketchup::Layer, layer2)
    assert_equal(layer1, layer2)
  end

  def test_add_incorrect_number_of_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add
    end
  end

  def test_add_incorrect_number_of_arguments_two
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add("Hello", "World")
    end
  end

  def test_add_invalid_argument_nil
    # Meh! Should have been TypeError...
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add(nil)
    end
  end

  def test_add_invalid_argument_number
    # Meh! Should have been TypeError...
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#add_layer (alias: #add)

  def test_add_layer
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    original_method = Sketchup::Layers.instance_method(:add)
    aliased_method = Sketchup::Layers.instance_method(:add_layer)
    assert_equal(original_method.name, aliased_method.original_name)
  end


  # ========================================================================== #
  # method Sketchup::Layers#remove

  def test_remove_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    # Remove layer by layer reference.
    layer = Sketchup.active_model.layers.add("MyLayer")
    Sketchup.active_model.layers.remove(layer)

    # Remove layer by name.
    Sketchup.active_model.layers.add("MyLayer")
    Sketchup.active_model.layers.remove("MyLayer")

    # Remove layer by index.
    Sketchup.active_model.layers.remove(1)

    # Remove layer and the entities on the layer.
    edge = Sketchup.active_model.entities.add_line([0, 0, 0], [9, 9, 9])
    edge.layer = Sketchup.active_model.layers.add("MyLayer")
    Sketchup.active_model.layers.remove("MyLayer", true)
  end

  def test_remove_index
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = Sketchup.active_model.layers[2]
    layer_name = layer.name
    Sketchup.active_model.layers.remove(2)
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert_equal(num_entities, Sketchup.active_model.entities.size,
      "Entities was erased")
    assert(layer.deleted?, "Layer not marked as deleted")
    assert_nil(Sketchup.active_model.layers[layer_name])
  end

  def test_remove_name
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.layers.remove("TestUp 02")
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert_equal(num_entities, Sketchup.active_model.entities.size,
      "Entities was erased")
    assert(layer.deleted?, "Layer not marked as deleted")
    assert_nil(Sketchup.active_model.layers["TestUp 02"])
  end

  def test_remove_layer
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.layers.remove(layer)
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert_equal(num_entities, Sketchup.active_model.entities.size,
      "Entities was erased")
    assert(layer.deleted?)
    assert_nil(Sketchup.active_model.layers["TestUp 02"])
  end

  def test_remove_index_erase_entities
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = Sketchup.active_model.layers[2]
    layer_name = layer.name
    Sketchup.active_model.layers.remove(2, true)
     assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert(Sketchup.active_model.entities.size < num_entities,
      "No entities erased")
    assert(layer.deleted?, "Layer not marked as deleted")
    assert_nil(Sketchup.active_model.layers[layer_name],
      "Layer should have been removed")
  end

  def test_remove_name_erase_entities
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.layers.remove("TestUp 02", true)
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert(Sketchup.active_model.entities.size < num_entities,
      "No entities erased")
    assert(layer.deleted?, "Layer not marked as deleted")
    assert_nil(Sketchup.active_model.layers["TestUp 02"],
      "Layer should have been removed")
  end

  def test_remove_layer_erase_entities
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.layers.remove(layer, true)
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert(Sketchup.active_model.entities.size < num_entities,
      "No entities erased")
    assert(layer.deleted?, "Layer not marked as deleted")
    assert_nil(Sketchup.active_model.layers["TestUp 02"],
      "Layer should have been removed")
  end

  def test_remove_layer0
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    layer = Sketchup.active_model.layers[0]
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.remove(layer)
    end
  end

  def test_remove_invalid_first_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.remove(nil)
    end
  end

  def test_remove_current
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    layer0 = Sketchup.active_model.layers[0]
    current_layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.active_layer = current_layer
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    Sketchup.active_model.layers.remove(current_layer)
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert_equal(num_entities, Sketchup.active_model.entities.size,
      "Entities was erased")
    assert_nil(Sketchup.active_model.layers["TestUp 02"],
      "Layer should have been removed")
    assert_equal(layer0, Sketchup.active_model.active_layer,
      "Current layer should be Layer0")
  end

  # TODO(thomthom): When Ruby API allow to open up groups/components, set up
  # tests that tests when one try to remove a layer that is used by the
  # active path.
  def test_remove_layer_used_by_active_path
    skip("Testable since SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    group = model.entities.grep(Sketchup::Group).first

    layer0 = model.layers[0]
    group_layer = group.layer
    group_layer_name = group.layer.name

    Sketchup.active_model.active_path = [group]

    num_entities = model.entities.size
    num_layers = model.layers.size
    assert_raises(RuntimeError) do
      model.layers.remove(group_layer, false)
    end
    assert_equal(num_layers, model.layers.size,
      "Layers was erased")
    assert_equal(num_entities, model.entities.size,
      "Entities was erased")
    refute(group_layer.deleted?, "Layer should not have been removed")
  end

  def test_remove_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.remove()
    end
  end

  def test_remove_incorrect_number_of_arguments_three
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    layer = Sketchup.active_model.layers["TestUp 02"]
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.remove(layer, false, nil)
    end
  end

  # TODO(thomthom): When Ruby API allow iterating open models, set up tests
  # for OSX to ensure that passing Layer objects from other models doesn't
  # screw up things. It will throw an error, but at the moment one need to
  # manually test this.

  def test_remove_second_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.layers.remove(layer, nil)
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert_equal(num_entities, Sketchup.active_model.entities.size,
      "Entities was erased")
    assert_nil(Sketchup.active_model.layers["TestUp 02"],
      "Layer should have been removed")
  end

  def test_remove_invalid_first_argument_point3d
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    # Should be TypeError, but the existing utility methods used ArgumentError.
    # Didn't want to introduce duplicate code just for this.
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.remove(ORIGIN)
    end
  end

  def test_remove_invalid_first_argument_deleted_layer
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.layers.remove("TestUp 02")
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.remove(layer)
    end
  end

  def test_remove_invalid_first_argument_entity
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities[0]
    # Should be TypeError, but the existing utility methods used ArgumentError.
    # Didn't want to introduce duplicate code just for this.
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.remove(entity)
    end
  end

  def test_remove_invalid_second_argument_point3d
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    num_entities = Sketchup.active_model.entities.size
    num_layers = Sketchup.active_model.layers.size
    layer = Sketchup.active_model.layers["TestUp 02"]
    Sketchup.active_model.layers.remove(layer, ORIGIN)
    assert_equal(num_layers - 1, Sketchup.active_model.layers.size,
      "No layers erased")
    assert(Sketchup.active_model.entities.size < num_entities,
      "No entities erased")
    assert(layer.deleted?, "Layer not marked as deleted")
    assert_nil(Sketchup.active_model.layers["TestUp 02"],
      "Layer should have been removed")
  end


  # ========================================================================== #
  # method Sketchup::Layers#remove_layer (alias: #remove)

  def test_remove_layer_alias
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    original_method = Sketchup::Layers.instance_method(:remove)
    aliased_method = Sketchup::Layers.instance_method(:remove_layer)
    assert_equal(original_method.name, aliased_method.original_name)
  end


  # ========================================================================== #
  # method Sketchup::Layers#unique_name

  def test_unique_name_layers
    # Get the default unique name prior the Layer->Tag change
    skip("Layers renamed to Tags in 2020") if Sketchup.version.to_i >= 20

    name = Sketchup.active_model.layers.unique_name
    assert_equal(name, 'Layer01');
  end

  def test_unique_name_tags
    # Get the default unique name after the Layer->Tag change
    skip("Layers renamed to Tags in 2020") if Sketchup.version.to_i < 20

    # check the next unique name
    next_unique_name = Sketchup.active_model.layers.unique_name
    assert_equal(next_unique_name, 'Tag');

    # add a layer and make sure it gets the next unique name
    layer = Sketchup.active_model.layers.add(next_unique_name)
    assert_equal(next_unique_name, layer.name)

    # check the next unique name to test for numerical increment
    next_unique_name = Sketchup.active_model.layers.unique_name
    assert_equal(next_unique_name, 'Tag1');
  end

  def test_unique_name_layer0
   # Unique name for Layer0 should return Layer01
   name = Sketchup.active_model.layers.unique_name('Layer0')
   assert_equal(name, 'Layer01');
  end

  def test_unique_name_across_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    layer1 = manager.add('Hello')

    folder = manager.add_folder('Folder')
    layer2 = manager.add('World')
    folder.add_layer(layer2)

    assert_equal('Hello1', manager.unique_name('Hello'))
    assert_equal('World1', manager.unique_name('World'))
  end


  # ========================================================================== #
  # method Sketchup::Layers#each

  def test_each
    start_with_empty_model
    layers = Sketchup.active_model.layers
    names = %w[Hello SketchUp World]
    names.each { |name| layers.add(name) }
    names << 'Layer0'
    
    actual = []
    layers.each { |layer|
      assert_kind_of(Sketchup::Layer, layer)
      actual << layer.name
    }
    assert_equal(names.sort, actual.sort)
  end

  def test_each_too_many_arguments
    layers = Sketchup.active_model.layers

    assert_raises(ArgumentError) do
      layers.each(nil) {}
    end
  end

  def test_each_with_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    # #each should still return all layers regardless of folders for the sake
    # of compatibility.
    start_with_empty_model
    layers = Sketchup.active_model.layers
    names = %w[Hello SketchUp World]
    names.each { |name| layers.add(name) }
    names << 'Layer0'

    folder = layers.add_folder('Folder')
    folder.add_layer(layers[1])
    folder.add_layer(layers[2])

    actual = []
    layers.each { |layer|
      assert_kind_of(Sketchup::Layer, layer)
      actual << layer.name
    }
    assert_equal(names.sort, actual.sort)
  end


  # ========================================================================== #
  # method Sketchup::Layers#folders

  def test_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    start_with_empty_model
    layers = Sketchup.active_model.layers
    names = %w[Hello SketchUp World]
    expected_folders = names.map { |name| layers.add_folder(name) }

    folders = layers.folders
    assert_kind_of(Array, folders)
    assert_equal(expected_folders.sort, folders.sort)
  end

  def test_folders_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(ArgumentError) do
      layers.folders(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#add_folder

  def test_add_folder_create
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')
    assert_kind_of(Sketchup::LayerFolder, folder)
    assert_equal('Hello', folder.name)
  end

  def test_add_folder_move
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder1 = layers.add_folder('Hello')
    folder2 = folder1.add_folder('World')

    layers.add_folder(folder2)
    assert(layers.folders.include?(folder2))
    refute(folder1.folders.include?(folder2))
  end

  def test_add_folder_empty_name
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(ArgumentError) do
      layers.add_folder('')
    end
  end

  def test_add_folder_too_few_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(ArgumentError) do
      layers.add_folder
    end
  end

  def test_add_folder_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(ArgumentError) do
      layers.add_folder('Hello', 'World')
    end
  end

  def test_add_folder_invalid_argument_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(TypeError) do
      layers.add_folder(nil)
    end
  end

  def test_add_folder_invalid_argument_numeric
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(TypeError) do
      layers.add_folder(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#remove_folder

  def test_remove_folder_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')

    assert_nil(layers.remove_folder(folder))
    assert_equal(0, layers.count_folders)
  end

  def test_remove_folder_not_in_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    folder1 = manager.add_folder('Hello')
    folder2 = folder1.add_folder('World')

    assert_raises(ArgumentError) do
      manager.remove_folder(folder2)
    end
  end

  def test_remove_folder_with_children
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    # <manager>
    # +- [Hello]
    #    +- [World]
    #    |  +- Layer3
    #    |  +- Layer4
    #    +- [Universe]
    #    +- Layer1
    #    +- Layer2

    folder1 = manager.add_folder('Hello')
    direct_children = %w[Layer1 Layer2].map { |name|
      layer = manager.add(name)
      folder1.add_layer(layer)
      layer
    }

    folder2 = folder1.add_folder('World')
    sub_children = %w[Layer3 Layer4].map { |name|
      layer = manager.add(name)
      folder2.add_layer(layer)
      layer
    }

    folder3 = folder1.add_folder('Universe')

    manager.remove_folder(folder1)

    # Anything that was parent to `folder1` should now be parent to the manager.
    assert_nil(folder2.folder)
    direct_children.each { |layer|
      assert_nil(layer.folder)
    }

    assert_nil(folder3.folder)

    # The sub-children should remain relative to their parent.
    sub_children.each { |layer|
      assert_equal(folder2, layer.folder)
    }
  end

  def test_remove_folder_too_few_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(ArgumentError) do
      layers.remove_folder
    end
  end

  def test_remove_folder_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    folder = layers.add_folder('Hello')

    assert_raises(ArgumentError) do
      layers.remove_folder(folder, 'World')
    end
  end

  def test_remove_folder_invalid_argument_nil
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(TypeError) do
      layers.remove_folder(nil)
    end
  end

  def test_remove_folder_invalid_argument_numeric
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers
    assert_raises(TypeError) do
      layers.remove_folder(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#each_folder

  def test_each_folder
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    folder1 = manager.add_folder('Folder1')
    folder2 = manager.add_folder('Folder2')
    folder3 = folder2.add_folder('Folder3')

    names = %w[Hello SketchUp World]
    names.each { |name| manager.add(name) }

    expected = %w[Folder1 Folder2]
    actual = []
    manager.each_folder { |folder|
      assert_kind_of(Sketchup::LayerFolder, folder)
      actual << folder.name
    }
    assert_equal(expected.sort, actual.sort)
  end

  def test_each_folder_empty
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    folders = []
    manager.each_folder { |folder|
      folders << folder
    }
    assert_empty(folders)
  end

  def test_each_folder_modify_collection
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers
    3.times { |i| manager.add_folder("Folder#{i}") }

    # Ensure modifying the collection iterated doesn't crash.
    assert_output('', /don't modify the collection while iterating/) do
      manager.each_folder { |folder|
        manager.add_folder("Surprise!") if folder.name.end_with?('1')
      }
      manager.each_folder { |folder|
        manager.remove_folder(folder) if folder.name.end_with?('2')
      }
    end
  end

  def test_each_folder_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    manager = Sketchup.active_model.layers

    assert_raises(ArgumentError) do
      manager.each_folder(nil) {}
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#each_layer

  def test_each_layer
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    start_with_empty_model
    manager = Sketchup.active_model.layers
    layer1 = manager.add_layer('Layer1')
    layer2 = manager.add_layer('Layer2')
    layer3 = manager.add_layer('Layer3')
    folder = manager.add_folder('Folder1')
    folder.add_layer(layer1)
    folder.add_layer(layer2)
    
    expected_names = %w[Layer0 Layer3]
    actual = []
    manager.each_layer { |layer|
      assert_kind_of(Sketchup::Layer, layer)
      actual << layer.name
    }
    assert_equal(expected_names.sort, actual.sort)
  end

  def test_each_layer_modify_collection
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0

    # The layer iterator is not able to handle this scenario.
    skip('Disabled')

    manager = Sketchup.active_model.layers
    3.times { |i| manager.add_layer("Layer#{i}") }

    # Ensure modifying the collection iterated doesn't crash.
    assert_output('', /don't modify the collection while iterating/) do
      manager.each_layer { |layer|
        manager.add_layer("Surprise!") if layer.name.end_with?('1')
      }
      manager.each_layer { |layer|
        manager.remove_layer(layer) if layer.name.end_with?('2')
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
  # method Sketchup::Layers#purge_unused

  def test_purge_unused
    start_with_empty_model
    layers = Sketchup.active_model.layers
    layers.add('Layer1')
    layers.add('Layer2')
    assert_equal(3, layers.size)
    
    num_removed = layers.purge_unused
    assert_kind_of(Integer, num_removed)
    assert_equal(2, num_removed)
    assert_equal(1, layers.size)
  end

  def test_purge_unused_with_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    start_with_empty_model
    layers = Sketchup.active_model.layers

    folder1 = layers.add_folder('Hello')
    folder1.add_layer(layers.add('Layer1'))

    folder2 = layers.add_folder('SketchUp')
    folder2.add_layer(layers.add('Layer2'))

    folder3 = layers.add_folder('World')

    assert_equal(3, layers.count_folders)
    assert_equal(3, layers.size) # layers

    num_removed = layers.purge_unused

    assert_kind_of(Integer, num_removed)
    assert_equal(2, num_removed)
    assert_equal(1, layers.size)
    assert_equal(3, layers.count_folders)
  end

  def test_purge_unused_too_many_arguments
    layers = Sketchup.active_model.layers
    assert_raises(ArgumentError) do
      layers.purge_unused(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#purge_unused_layers (alias: #purge_unused)

  def test_purge_unused_layers
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    original_method = Sketchup::Layers.instance_method(:purge_unused)
    aliased_method = Sketchup::Layers.instance_method(:purge_unused_layers)
    assert_equal(original_method.name, aliased_method.original_name)
  end


  # ========================================================================== #
  # method Sketchup::Layers#purge_unused_folders

  def test_purge_unused_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers

    folder1 = layers.add_folder('Hello')
    folder1.add_layer(layers.add('Layer1'))

    folder2 = layers.add_folder('SketchUp')
    folder2.add_layer(layers.add('Layer2'))

    folder3 = layers.add_folder('World')

    assert_equal(3, layers.count_folders)
    num_removed = layers.purge_unused_folders
    assert_kind_of(Integer, num_removed)
    assert_equal(1, num_removed)
    assert_equal(2, layers.count_folders)
  end

  def test_purge_unused_folders_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers

    assert_raises(ArgumentError) do
      layers.purge_unused_folders(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#count_folders

  def test_count_folders
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    start_with_empty_model
    layers = Sketchup.active_model.layers
    assert_equal(0, layers.count_folders)

    folder1 = layers.add_folder('Hello')
    folder2 = layers.add_folder('SketchUp')
    folder3 = layers.add_folder('World')
    num_folders = layers.count_folders
    assert_kind_of(Integer, num_folders)
    assert_equal(3, num_folders)
  end

  def test_count_folders_too_many_arguments
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    layers = Sketchup.active_model.layers

    assert_raises(ArgumentError) do
      layers.count_folders(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#size

  def test_size
    start_with_empty_model
    layers = Sketchup.active_model.layers
    assert_equal(1, layers.size)

    layers.add('Hello')
    layers.add('World')
    layers.add_folder('Folder') if Sketchup.version.to_f >= 21.0

    num_layers = layers.size
    assert_kind_of(Integer, num_layers)
    assert_equal(3, num_layers)
  end

  def test_size_too_many_arguments
    layers = Sketchup.active_model.layers
    
    assert_raises(ArgumentError) do
      layers.size(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers#length (alias: #size)

  def test_length
    start_with_empty_model
    layers = Sketchup.active_model.layers
    assert_equal(1, layers.size)

    layers.add('Hello')
    layers.add('World')
    layers.add_folder('Folder') if Sketchup.version.to_f >= 21.0

    num_layers = layers.length
    assert_kind_of(Integer, num_layers)
    assert_equal(3, num_layers)
  end


  # ========================================================================== #
  # method Sketchup::Layers#count_layers (alias: #size)

  def test_count_layers
    skip('Added in 2021.0') if Sketchup.version.to_f < 21.0
    start_with_empty_model
    layers = Sketchup.active_model.layers
    assert_equal(1, layers.size)

    layers.add('Hello')
    layers.add('World')
    layers.add_folder('Folder')

    num_layers = layers.count_layers
    assert_kind_of(Integer, num_layers)
    assert_equal(3, num_layers)
  end


  # ========================================================================== #
  # method Sketchup::Layers#add_observer

  class TestObserver < Sketchup::LayersObserver; end

  def test_add_observer
    # More complete observer tests are found in the "Observers 2.0" test suite.
    layers = Sketchup.active_model.layers
    observer = TestObserver.new
    layers.add_observer(observer)
  ensure
    layers.remove_observer(observer)
  end


  # ========================================================================== #
  # method Sketchup::Layers#remove_observer

  def test_remove_observer
    # More complete observer tests are found in the "Observers 2.0" test suite.
    layers = Sketchup.active_model.layers
    observer = TestObserver.new
    layers.add_observer(observer)
    layers.remove_observer(observer)
  end

end # class

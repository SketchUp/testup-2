# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Layers
# http://www.sketchup.com/intl/developer/docs/ourdoc/layers
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
  # method Sketchup::Layers.at
  # method Sketchup::Layers.[]
  # http://www.sketchup.com/intl/developer/docs/ourdoc/layers#at

  def test_at_api_example
    layers = Sketchup.active_model.layers
    new_layer = layers.add("MyLayer")
    layer_by_number = layers.at(1)
    layer_by_name = layers.at("MyLayer")
  end

  def test_at_api_example_alias
    layers = Sketchup.active_model.layers
    new_layer = layers.add("MyLayer")
    layer_by_number = layers[1]
    layer_by_name = layers["MyLayer"]
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


  # ========================================================================== #
  # method Sketchup::Layers.add
  # http://www.sketchup.com/intl/developer/docs/ourdoc/layers#add

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

  def test_remove_incorrect_number_of_arguments_zero
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add
    end
  end

  def test_remove_incorrect_number_of_arguments_two
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add("Hello", "World")
    end
  end

  def test_remove_invalid_argument_nil
    # Meh! Should have been TypeError... 
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add(nil)
    end
  end

  def test_remove_invalid_argument_number
    # Meh! Should have been TypeError... 
    assert_raises(ArgumentError) do
      Sketchup.active_model.layers.add(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Layers.remove
  # http://www.sketchup.com/intl/developer/docs/ourdoc/layers#remove

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
    Sketchup.active_model.layers.remove(current_layer, nil)
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


end # class

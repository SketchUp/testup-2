# Copyright:: Copyright 2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::ComponentDefinition
class TC_Sketchup_ComponentDefinition < TestUp::TestCase

 def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model()
    # Ensure "IFC 2x3" is loaded.
    file = Sketchup.find_support_file("IFC 2x3.skc", "Classifications")
    Sketchup.active_model.classifications.load_schema(file)
  end

  def teardown
    # ...
  end


  class TestUpEvilEntityObserver < Sketchup::EntityObserver

    def onChangeEntity(entity)
      puts "#{self.class.name}.onChangeEntity(#{entity})"
      Sketchup.active_model.definitions.purge_unused
    end

  end # class


  class TestUpEvilDefinitionsObserver < Sketchup::DefinitionsObserver

    def onComponentPropertiesChanged(definitions, definition)
      puts "#{self.class.name}.onComponentPropertiesChanged(#{definition})"
      definitions.purge_unused
    end

  end # class


  def testcase_file(filename)
    File.join(__dir__, File.basename(__FILE__, ".*"), filename)
  end

  def load_testcase_definition(filename)
    model = Sketchup.active_model
    path = testcase_file(filename)
    model.definitions.load(path)
  end

  def create_test_image
    entities = Sketchup.active_model.entities
    filename = testcase_file("test.jpg")
    image = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)
    image
  end

  def create_test_instance
    entities = Sketchup.active_model.entities
    definition = Sketchup.active_model.definitions.add("Door")
    definition.entities.add_line(ORIGIN, [0, 0, 10])
    transformation = Geom::Transformation.new(ORIGIN)
    instance = entities.add_instance(definition, transformation)
    instance
  end

  def create_classified_test_instance
    instance = create_test_instance()
    instance.definition.add_classification("IFC 2x3", "IfcDoor")
    # TODO(thomthom): Replace with set_classification_value when implemented.
    schema = instance.definition.attribute_dictionary("IFC 2x3", false)
    object_type = schema.attribute_dictionary("ObjectType", false)
    object_type.set_attribute("IfcLabel", "value", "TestUp Door")
    instance
  end

  def corrupt_attribute_data(definition, path, value, key = "value")
    # Naive path interpreter, doesn't account for keys with escaped : character.
    keys = path.dup

    schema_name = keys.shift
    schema = definition.attribute_dictionary(schema_name, false)
    schema_type = keys.shift

    dictionary = schema
    until dictionary.nil? || keys.empty?
      dictionary = dictionary.attribute_dictionary(keys.shift, false)
    end
    dictionary[key] = value

    nil
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.count_used_instances

  def test_count_used_instances_api_example
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16

    path = Sketchup.find_support_file('Bed.skp',
      'Components/Components Sampler/')
    definitions = Sketchup.active_model.definitions
    definition = definitions.load(path)
    number = definition.count_used_instances
  end

  def test_count_used_instances
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16

    model = Sketchup.active_model
    definitions = model.definitions

    # Create a definition but don't add it to the model.
    definition1 = definitions.add('Foo')
    definition1.entities.add_cpoint(ORIGIN)
    assert_equal(0, definition1.count_used_instances)

    # Create a new definition and add the first one a couple of time.
    definition2 = definitions.add('Foo')
    definition2.entities.add_cpoint(ORIGIN)
    definition2.entities.add_instance(definition1, ORIGIN)
    definition2.entities.add_instance(definition1, ORIGIN)
    assert_equal(0, definition1.count_used_instances)
    assert_equal(0, definition2.count_used_instances)

    # Add the definitions to the model - this will make them 'used'.
    model.entities.add_instance(definition1, ORIGIN)
    assert_equal(1, definition1.count_used_instances)
    model.entities.add_instance(definition2, ORIGIN)
    assert_equal(3, definition1.count_used_instances)
    assert_equal(1, definition2.count_used_instances)
  end

  def test_count_used_instances_incorrect_number_of_arguments_one
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16

    model = Sketchup.active_model
    definitions = model.definitions
    definition = definitions.add('Foo')
    definition.entities.add_cpoint(ORIGIN)
    assert_raises(ArgumentError) do
      definition.count_used_instances(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.load

  def test_load_evil_definitions_observer_without_operation
    model = Sketchup.active_model
    entities = model.entities

    observer = TestUpEvilDefinitionsObserver.new
    model.definitions.add_observer(observer)

    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.skp")
    definition = model.definitions.load(filename)

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) do
      definition.name
    end
  ensure
    model.definitions.remove_observer(observer)
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.name=

  def test_name_Set_evil_entities_observer_without_operation
    model = Sketchup.active_model
    entities = model.entities
    definition = model.definitions.add("TestUp")
    definition.entities.add_line(ORIGIN, [0, 0, 10])

    observer = TestUpEvilEntityObserver.new
    definition.add_observer(observer)

    definition.name = "Cheese"

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) do
      definition.name
    end
  ensure
    definition.remove_observer(observer) if definition.valid?
  end

  def test_name_Set_evil_definitions_observer_without_operation
    model = Sketchup.active_model
    entities = model.entities
    definition = model.definitions.add("TestUp")
    definition.entities.add_line(ORIGIN, [0, 0, 10])

    observer = TestUpEvilDefinitionsObserver.new
    model.definitions.add_observer(observer)

    definition.name = "Cheese"

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) do
      definition.name
    end
  ensure
    model.definitions.remove_observer(observer)
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.save_as

  def test_save_as
    definition = create_test_instance.definition

    temp_dir = Sketchup.temp_dir
    path = "#{temp_dir}/my component.skp"

    assert(definition.save_as(path))
    assert(File.exist?(path))
    assert_equal(definition.path, path)
  ensure
    File.delete(path)
  end

  def test_save_as_invalid_path
    definition = create_test_instance.definition

    assert_raises(TypeError) do
      definition.save_as(1234)
    end
  end

  def test_save_as_custom_version
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    definition = create_test_instance.definition

    temp_dir = Sketchup.temp_dir
    path = "#{temp_dir}/my component.skp"

    assert(definition.save_as(path, Sketchup::Model::VERSION_2017))
    assert(File.exist?(path))
    assert_equal(definition.path, path)
  ensure
    File.delete(path)
  end

  def test_save_as_invalid_version
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    definition = create_test_instance.definition

    assert_raises(ArgumentError) do
      definition.save_as("dir/file.skp", 1337)
    end

    assert_raises(TypeError) do
      definition.save_as("dir/file.skp", "A string")
    end
  end

  def test_save_as_too_few_arguments
    definition = create_test_instance.definition
    assert_raises(ArgumentError) do
      definition.save_as
    end
  end

  def test_save_as_too_many_arguments
    definition = create_test_instance.definition
    assert_raises(ArgumentError) do
      definition.save_as("path", Sketchup::Model::VERSION_2017, true)
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.save_copy

  def test_save_copy
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    definition = create_test_instance.definition

    temp_dir = Sketchup.temp_dir
    path = "#{temp_dir}/my component.skp"

    assert(definition.save_copy(path))
    assert(File.exist?(path))
    assert(definition.path != path)
  ensure
    File.delete(path)
  end

  def test_save_copy_invalid_path
    definition = create_test_instance.definition

    assert_raises(TypeError) do
      definition.save_copy(1234)
    end
  end

  def test_save_copy_custom_version
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    definition = create_test_instance.definition

    temp_dir = Sketchup.temp_dir
    path = "#{temp_dir}/my component.skp"

    assert(definition.save_copy(path, Sketchup::Model::VERSION_2017))
    assert(File.exist?(path))
    assert(definition.path != path)
  ensure
    File.delete(path)
  end

  def test_save_copy_invalid_version
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    definition = create_test_instance.definition

    assert_raises(ArgumentError) do
      definition.save_copy("dir/file.skp", 1337)
    end

    assert_raises(TypeError) do
      definition.save_copy("dir/file.skp", "A string")
    end
  end

  def test_save_copy_too_few_arguments
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    definition = create_test_instance.definition
    assert_raises(ArgumentError) do
      definition.save_copy
    end
  end

  def test_save_copy_too_many_arguments
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    definition = create_test_instance.definition
    assert_raises(ArgumentError) do
      definition.save_copy("path", Sketchup::Model::VERSION_2017, true)
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.thumbnail_camera

  def test_thumbnail_camera
    skip('Added in SU2023.0') if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    definitions = model.definitions
    # Make a test cube component
    vertices = [
      [-1 ,-1, 0], [1 ,-1, 0], [1 ,1, 0], [-1 ,1, 0],
      [-1 ,-1, 2], [1 ,-1, 2], [1 ,1, 2], [-1 ,1, 2]
    ]
    faces = [
      [3, 2, 1, 0], [0, 1, 5, 4], [2, 3, 7, 6],
      [4, 5, 6, 7], [4, 7, 3, 0], [6, 5, 1, 2]
    ]
    definition = definitions.add
    faces.each do |indices|
      vts = indices.map { |i| vertices[i] }
      face = definition.entities.add_face(vts)
    end

    try_count = 5
    try_count.times do |i|
      camera = Sketchup::Camera.new(3.times.map { rand(-0.5) }, [0, 0, 0], Z_AXIS)
      definition.thumbnail_camera = camera
      # Check if the thumbnails images are same
      thumbnail_camera = definition.thumbnail_camera
      assert_equal(thumbnail_camera.eye.to_a, camera.eye.to_a)
      assert_equal(thumbnail_camera.target.to_a, camera.target.to_a)
      assert_equal(thumbnail_camera.up.to_a, camera.up.to_a)
    end

  end

 def test_thumbnail_camera_incorrect_arguments_type
    skip('Added in SU2023.0') if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    definition = Sketchup.active_model.definitions.add
    assert_raises(TypeError) do
      definition.thumbnail_camera = "Incorrect object type"
    end
 end

 def test_thumbnail_camera_nil_argument_type
    skip('Added in SU2023.0') if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    definition = Sketchup.active_model.definitions.add
    assert_raises(TypeError) do
      definition.thumbnail_camera = nil
    end
 end

 def test_thumbnail_camera_check_camera_ref
     skip('Added in SU2023.0') if Sketchup.version.to_f < 23.0
     model = Sketchup.active_model
     definition = Sketchup.active_model.definitions.add
     camera = Sketchup::Camera.new([1000, 1000, 1000], [0, 0, 0], [0, 0, 1])
     # Set thumbnail camera.
     definition.thumbnail_camera = camera
     # Get thumbnail camera
     camera1 = definition.thumbnail_camera
     # Change the values of eye, target and up
     camera1.set([2000, 2000, 2000], [0, 0, 2], [1, 0, 0])
     # Get the thumbnail camera
     camera2 = definition.thumbnail_camera
     # Ensure that the attributes weren't modified for the thumbnail camera
     # associated with the definition.
     refute_equal(camera1.eye, camera2.eye)
     refute_equal(camera1.target, camera2.target)
     refute_equal(camera1.up, camera2.up)
 end

  # ========================================================================== #
  # method Sketchup::ComponentDefinition.add_classification

  def test_add_classification_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_test_instance()
    # API Example starts here:
    definition = Sketchup.active_model.definitions.first
    definition.add_classification("IFC 2x3", "IfcDoor")
  end

  def test_add_classification_success
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    result = definition.add_classification("IFC 2x3", "IfcDoor")
    assert(result)
    dictionary = definition.attribute_dictionary("IFC 2x3", false)
    assert_kind_of(Sketchup::AttributeDictionary, dictionary)
  end

  def test_add_classification_failure
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    result = definition.add_classification("FooBar", "IfcDoor")
    assert_equal(false, result)
    dictionaries = definition.attribute_dictionaries
    if Sketchup.version.to_i < 18
      assert_nil(dictionaries)
    else
      assert_equal(1, dictionaries.size)
      assert_equal('SU_DefinitionSet', dictionaries.first.name)
    end
  end

  def test_add_classification_failure_image_definition
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_test_image()
    definition = Sketchup.active_model.definitions.first
    assert(definition.image?, "Failed to set up test.")
    result = definition.add_classification("FooBar", "IfcDoor")
    assert_equal(false, result)
    dictionaries = definition.attribute_dictionaries
    assert_nil(dictionaries)
  end

  def test_add_classification_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises ArgumentError do
      definition.add_classification
    end
  end

  def test_add_classification_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises ArgumentError do
      definition.add_classification("IFC 2x3")
    end
  end

  def test_add_classification_incorrect_number_of_arguments_thee
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises ArgumentError do
      definition.add_classification("IFC 2x3", "IfcDoor", "BogusArgument")
    end
  end

  def test_add_classification_invalid_first_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.add_classification(nil, "IfcDoor")
    end
  end

  def test_add_classification_invalid_second_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.add_classification("IFC 2x3", nil)
    end
  end

  def test_add_classification_invalid_first_argument_number
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.add_classification(3.14, "IfcDoor")
    end
  end

  def test_add_classification_invalid_second_argument_number
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.add_classification("IFC 2x3", 3.14)
    end
  end

  def test_add_classification_invalid_first_argument_point
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.add_classification(ORIGIN, "IfcDoor")
    end
  end

  def test_add_classification_invalid_second_argument_point
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.add_classification("IFC 2x3", ORIGIN)
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.get_classification_value

  def test_get_classification_value_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_test_instance()
    # API Example starts here:
    entities = Sketchup.active_model.entities
    definition = entities.grep(Sketchup::ComponentInstance).first.definition
    definition.add_classification("IFC 2x3", "IfcDoor")

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    value = definition.get_classification_value(path)
  end

  def test_get_classification_value_string
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    value = definition.get_classification_value(path)
    assert_kind_of(String, value)
    assert_equal("TestUp Door", value)
  end

  def test_get_classification_value_invalid_key
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    path = ["ClassifierPathToHeaven"]
    value = definition.get_classification_value(path)
    assert_nil(value)
  end

  def test_get_classification_image_definition
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_test_image()
    definition = Sketchup.active_model.definitions.first
    assert(definition.image?, "Failed to set up test.")

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    value = definition.get_classification_value(path)
    assert_nil(value)
  end

  def test_get_classification_value_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises ArgumentError do
      definition.get_classification_value()
    end
  end

  def test_get_classification_value_incorrect_number_of_arguments_two
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises ArgumentError do
      definition.get_classification_value(["IFC 2x3", "IfcDoor"], "Two")
    end
  end

  def test_get_classification_value_invalid_arguments_string
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.get_classification_value("IFC 2x3")
    end
  end

  def test_get_classification_value_invalid_arguments_number
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.get_classification_value(123)
    end
  end

  def test_get_classification_value_invalid_arguments_point
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.get_classification_value(ORIGIN)
    end
  end

  def test_get_classification_value_invalid_arguments_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.get_classification_value(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.remove_classification

  def test_remove_classification_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_classified_test_instance()
    # API Example starts here:
    definition = Sketchup.active_model.definitions.first
    success = definition.remove_classification("IFC 2x3", "IfcDoor")
  end

  def test_remove_classification_success
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition
    if Sketchup.version.to_i < 15
      # SketchUp 2014 was a little bit different.
      result = definition.remove_classification("IFC 2x3", "ifc:IfcDoor")
    else
      result = definition.remove_classification("IFC 2x3", "IfcDoor")
    end
    assert(result)
    dictionary = definition.attribute_dictionary("IFC 2x3", false)
    assert_nil(dictionary)
  end

  def test_remove_classification_success_only_schema_name
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition
    result = definition.remove_classification("IFC 2x3")
    assert(result)
    dictionary = definition.attribute_dictionary("IFC 2x3", false)
    assert_nil(dictionary)
  end

  def test_remove_classification_failure
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition
    result = definition.remove_classification("FooBar", "IfcDoor")
    assert_equal(false, result)
    dictionaries = definition.attribute_dictionaries
    if Sketchup.version.to_i < 18
      # Should be two dictionaries, "AppliedSchemaTypes" and "IFC 2x3".
      assert_equal(2, dictionaries.size)
    else
      # Since SU2018 there always is a "SU_DefinitionSet" dictionary.
      assert_equal(3, dictionaries.size)
    end
  end

  def test_remove_classification_failure_image_definition
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_test_image()
    definition = Sketchup.active_model.definitions.first
    assert(definition.image?, "Failed to set up test.")
    result = definition.remove_classification("FooBar", "IfcDoor")
    assert_equal(false, result)
  end

  def test_remove_classification_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises ArgumentError do
      definition.remove_classification
    end
  end

  def test_remove_classification_incorrect_number_of_arguments_thee
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises ArgumentError do
      definition.remove_classification("IFC 2x3", "IfcDoor", "BogusArgument")
    end
  end

  def test_remove_classification_invalid_first_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.remove_classification(nil, "IfcDoor")
    end
  end

  def test_remove_classification_invalid_second_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.remove_classification("IFC 2x3", nil)
    end
  end

  def test_remove_classification_invalid_first_argument_number
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.remove_classification(3.14, "IfcDoor")
    end
  end

  def test_remove_classification_invalid_second_argument_number
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.remove_classification("IFC 2x3", 3.14)
    end
  end

  def test_remove_classification_invalid_first_argument_point
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.remove_classification(ORIGIN, "IfcDoor")
    end
  end

  def test_remove_classification_invalid_second_argument_point
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition
    assert_raises TypeError do
      definition.remove_classification("IFC 2x3", ORIGIN)
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.set_classification_value

  def test_set_classification_value_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_test_instance()
    # API Example starts here:
    definition = Sketchup.active_model.definitions.first
    definition.add_classification("IFC 2x3", "IfcDoor")

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    success = definition.set_classification_value(path, "Room 101")
  end

  def test_set_classification_value_string
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    result = definition.set_classification_value(path, "Room 101")
    assert_equal(true, result)
    value = definition.get_classification_value(path)
    assert_equal("Room 101", value)
  end

  def test_set_classification_value_invalid_key
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    path = ["ClassifierPathToHeaven"]
    result = definition.set_classification_value(path, "Room 101")
    assert_equal(false, result)
  end

  def test_set_classification_value_not_classified
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_test_instance().definition

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    result = definition.set_classification_value(path, "Room 101")
    assert_equal(false, result)
  end

  def test_set_classification_image_definition
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    create_test_image()
    definition = Sketchup.active_model.definitions.first
    assert(definition.image?, "Failed to set up test.")

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    result = definition.set_classification_value(path, "Room 101")
    assert_equal(false, result)
    dictionaries = definition.attribute_dictionaries
    assert_nil(dictionaries)
  end

  def test_set_classification_value_invalid_value
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition
    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]

    assert_raises TypeError do
      definition.set_classification_value(path, 123)
    end
  end

  def test_set_classification_value_corrupt_attribute_data
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition
    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    corrupt_attribute_data(definition, path, 123, "attribute_type")

    assert_raises RuntimeError do
      definition.set_classification_value(path, "Room 101")
    end
  end

  def test_set_classification_value_valid_choice_value
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition
    path = ["IFC 2x3", "IfcDoor", "OverallHeight", "instanceAttributes", "pos"]

    assert_raises NotImplementedError do
      definition.set_classification_value(path, "integer")
    end
  end

  def test_set_classification_value_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises ArgumentError do
      definition.set_classification_value()
    end
  end

  def test_set_classification_value_incorrect_number_of_arguments_three
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition
    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]

    assert_raises ArgumentError do
      definition.set_classification_value(path, "Room 101", "Tree")
    end
  end

  def test_set_classification_value_invalid_path_argument_string
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.set_classification_value("IFC 2x3", "Room 101")
    end
  end

  def test_set_classification_value_invalid_path_argument_number
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.set_classification_value(123, "Room 101")
    end
  end

  def test_set_classification_value_invalid_path_argument_point
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.set_classification_value(ORIGIN, "Room 101")
    end
  end

  def test_set_classification_value_invalid_path_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    definition = create_classified_test_instance().definition

    assert_raises TypeError do
      definition.set_classification_value(nil, "Room 101")
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.live_component?

  def test_live_component_Query_is_not_live_component
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    load_testcase_definition("2021_lc.skp")
    model = Sketchup.active_model
    definition = model.definitions['Laura']

    refute(definition.live_component?)
  end

  def test_live_component_Query_is_live_component
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    load_testcase_definition("2021_lc.skp")
    model = Sketchup.active_model
    definition = model.definitions['Exterior Sliding Door']

    assert(definition.live_component?)
  end

  def test_live_component_Query_is_live_component_sub_component
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    load_testcase_definition("2021_lc.skp")
    model = Sketchup.active_model
    definition = model.definitions["e11686e2-0c1b-4fe3-91c4-020887c23961:27"]

    assert(definition.live_component?)
  end

  def test_live_component_Query_too_many_arguments
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    definition = model.definitions.add('TestUp')

    assert_raises(ArgumentError) do
      definition.live_component?(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.name=

  def test_Set_name_enforce_unique_names
    model = Sketchup.active_model

    definition1 = model.definitions.add("Foo")
    definition2 = model.definitions.add("Bar")
    assert_equal("Foo", definition1.name)
    assert_equal("Bar", definition2.name)

    definition1.name = "TestUp"
    definition2.name = "TestUp"
    assert_equal("TestUp", definition1.name)
    assert_equal("TestUp#1", definition2.name)

    # Ensure that names a freed up once renamed.
    definition1.name = "Foo"
    definition2.name = "TestUp"
    assert_equal("Foo", definition1.name)
    assert_equal("TestUp", definition2.name)
  end

end # class

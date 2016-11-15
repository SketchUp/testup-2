# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::ComponentDefinition
# http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition
class TC_Sketchup_ComponentDefinition < TestUp::TestCase

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


  def create_test_image
    entities = Sketchup.active_model.entities
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
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
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#count_used_instances

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
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#load

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
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#name=

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
  # method Sketchup::ComponentDefinition.add_classification
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#add_classification

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
    assert_nil(dictionaries)
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
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#get_classification_value

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
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#remove_classification

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
    # Should be two dictionaries, "AppliedSchemaTypes" and "IFC 2x3".
    assert_equal(2, dictionaries.size)
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
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#set_classification_value

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


end # class

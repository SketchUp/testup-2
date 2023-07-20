# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Entity
class TC_Sketchup_Entity < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end


  class TestUpEvilEntityObserver < Sketchup::EntityObserver

    def onChangeEntity(entity)
      puts "#{self.class.name}.onChangeEntity(#{entity})"
      entity.attribute_dictionaries.delete("TestUp")
    end

  end # class


  # ========================================================================== #
  # method Sketchup::Entity.attribute_dictionary

  def test_attribute_dictionary_evil_observer_without_operation
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    observer = TestUpEvilEntityObserver.new
    edge.add_observer(observer)

    dictionary = edge.attribute_dictionary("TestUp", true)

    assert_kind_of(Sketchup::AttributeDictionary, dictionary)
    assert(dictionary.deleted?, "Dictionary not deleted")

    assert_raises(TypeError) do
      dictionary.parent
    end
  ensure
    edge.remove_observer(observer)
  end

  def test_attribute_dictionary_evil_observer_with_operation
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    observer = TestUpEvilEntityObserver.new
    edge.add_observer(observer)

    model.start_operation("TestUp", true)

    dictionary = edge.attribute_dictionary("TestUp", true)
    assert_kind_of(Sketchup::AttributeDictionary, dictionary)
    assert_equal("TestUp", dictionary.name)
    assert(dictionary.valid?, "Dictionary deleted")

    model.commit_operation

    assert_kind_of(Sketchup::AttributeDictionary, dictionary)
    assert(dictionary.deleted?, "Dictionary not deleted")
  ensure
    edge.remove_observer(observer)
  end


  # ========================================================================== #
  # method Sketchup::Entity.persistent_id

  def test_persistent_id_edge
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    result = edge.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_vertex
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    result = edge.start.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_page
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    model = Sketchup.active_model
    page = model.pages.add("TestUp")

    result = page.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_line_style
    skip("Implemented in SU2020.0") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    line_style = model.line_styles[0]

    result = line_style.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    assert_raises(ArgumentError) {
      edge.persistent_id(nil) {}
    }
  end

  def test_delete_attribute
    start_with_empty_model
    entities = Sketchup.active_model.entities
    group = entities.add_group
    group.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    group.set_attribute("SU_DefinitionSet", "hazoo", 15)
    result = group.delete_attribute("SU_DefinitionSet", "hazoo")
    assert_equal(true, result)
  end

  def test_delete_attribute_invalid_key
    start_with_empty_model
    entities = Sketchup.active_model.entities
    group = entities.add_group
    group.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    result = group.delete_attribute("SU_DefinitionSet", "hazoo")
    assert_equal(false, result)
  end

  def test_set_attribute_on_readonly_dictionary
    start_with_empty_model
    test_file = File.join(__dir__, 'misc_test_files', 'Laura.skp')
    definition = Sketchup.active_model.definitions.load(test_file)
    assert_raises(Sketchup.version.to_i < 21 ? RuntimeError : ArgumentError) {
      definition.set_attribute('GSU_ContributorsInfo', 'some_key', 'some_value')
    }
  end

  def test_delete_all_attributes_on_dynamic_property_dictionary
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    start_with_empty_model
    test_file = File.join(__dir__, 'misc_test_files', 'Laura.skp')
    definition = Sketchup.active_model.definitions.load(test_file)
    dict = definition.attribute_dictionary('SU_DefinitionSet')
    dict.each_key{ |key|
      definition.delete_attribute('SU_DefinitionSet', key)
    }
    # Dictionary shouldn't have been deleted even though we deleted its keys.
    dict = definition.attribute_dictionary('SU_DefinitionSet')
    assert(!dict.nil?)
  end

  def test_delete_attribute_on_readonly_dictionary
    skip("Implemented in SU2021") if Sketchup.version.to_i < 21
    start_with_empty_model
    test_file = File.join(__dir__, 'misc_test_files', 'LiveComponent.skp')
    definition = Sketchup.active_model.definitions.load(test_file)
    assert_raises(ArgumentError) {
      definition.delete_attribute('SU_LiveComponent', 'Parameters')
    }
  end

  def test_delete_readonly_dictionary_from_entity
    skip("Implemented in SU2021") if Sketchup.version.to_i < 21
    start_with_empty_model
    test_file = File.join(__dir__, 'misc_test_files', 'LiveComponent.skp')
    definition = Sketchup.active_model.definitions.load(test_file)
    assert_raises(ArgumentError) {
      # Trying to delete the entire dictionary (without the second parameter)
      definition.delete_attribute('SU_LiveComponent')
    }
  end

  def test_delete_readonly_dictionary_from_attributes_collection
    skip("Implemented in SU2021") if Sketchup.version.to_i < 21
    start_with_empty_model
    test_file = File.join(__dir__, 'misc_test_files', 'LiveComponent.skp')
    definition = Sketchup.active_model.definitions.load(test_file)
    assert_raises(ArgumentError) {
      # Trying to delete the entire dictionary (without the second parameter)
      # This deletes by name.
      definition.attribute_dictionaries.delete('SU_LiveComponent')
    }
    assert_raises(ArgumentError) {
      # Same thing but this time we try to delete by passing in the dictionary.
      dicts = definition.attribute_dictionaries
      dict = dicts['SU_LiveComponent']
      dicts.delete(dict)
    }
  end

end # class

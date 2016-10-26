# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Entity
class TC_Sketchup_Entity < TestUp::TestCase

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
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    result = edge.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_vertex
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    result = edge.start.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_incorrect_number_of_arguments_one
    model = Sketchup.active_model
    edge = model.entities.add_line(ORIGIN, [5,5,5])

    assert_raises(ArgumentError) {
      edge.persistent_id(nil) {}
    }
  end


end # class

# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::DefinitionList
# http://www.sketchup.com/intl/developer/docs/ourdoc/definitionlist
class TC_Sketchup_DefinitionList < TestUp::TestCase

  def setup
    start_with_empty_model()
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

    def onComponentAdded(definitions, definition)
      puts "#{self.class.name}.onComponentAdded(#{definition})"
      definitions.purge_unused
    end

  end # class



  # ========================================================================== #
  # method Sketchup::DefinitionList.add
  # http://www.sketchup.com/intl/developer/docs/ourdoc/definitionlist#add

  def test_add_evil_definitions_observer_without_operation
    model = Sketchup.active_model
    entities = model.entities

    observer = TestUpEvilDefinitionsObserver.new
    model.definitions.add_observer(observer)

    definition = model.definitions.add("TestUp")

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) do
      definition.name
    end
  ensure
    model.definitions.remove_observer(observer) if definition.valid?
  end


end # class

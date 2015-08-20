# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Group
# http://www.sketchup.com/intl/developer/docs/ourdoc/group
class TC_Sketchup_Group < TestUp::TestCase

  def setup
    start_with_empty_model()
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::Group.definition
  # http://www.sketchup.com/intl/developer/docs/ourdoc/group#definition

  def test_definition_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities.add_group
    definition = group.definition
  end

  def test_definition_success
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities.add_group
    expected = Sketchup.active_model.definitions.first
    result = group.definition
    result.is_a?(Sketchup::ComponentDefinition)
    assert(result.group?)
    assert_equal(expected, result)
    assert_equal(1, result.instances.size)
    assert_equal(group, result.instances.first)
  end

  def test_definition_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities.add_group
    assert_raises ArgumentError do
      group.definition("ZOMG we finally added Group.definition!!")
    end
  end


end # class

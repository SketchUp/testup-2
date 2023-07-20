# Copyright:: Copyright 2014-2022 Trimble Inc Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen (thomthom@sketchup.com)


require "testup/testcase"


# class Sketchup::Group
class TC_Sketchup_Group < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model()
  end

  def teardown
    # ...
  end

  def testcase_file(filename)
    File.join(__dir__, File.basename(__FILE__, ".*"), filename)
  end

  def named_group(name)
    Sketchup.active_model.entities.grep(Sketchup::Group).find { |g| g.name == name }
  end

  # ========================================================================== #
  # method Sketchup::Group.definition

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

  # ========================================================================== #
  # method Sketchup::Group.glued_to

  def test_glued_to
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    path = testcase_file("glued_groups.skp")
    Sketchup.open_file(path)
    
    assert_nil(named_group("Not glued").glued_to)
    assert_kind_of(Sketchup::Face, named_group("Glued to face").glued_to)
    assert_kind_of(Sketchup::ComponentInstance, named_group("Glued to component").glued_to)
    assert_kind_of(Sketchup::Group, named_group("Glued to group").glued_to)
    assert_kind_of(Sketchup::Image, named_group("Glued to image").glued_to)
  ensure
    close_active_model
  end

  def test_glued_to_too_many_arguments
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_raises(ArgumentError) {
      group.glued_to(3048)
    }
  end

  # ========================================================================== #
  # method Sketchup::Group.glued_to=

  def test_glued_to_Set_face
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_equal(group.glued_to = face, face)
    assert_equal(group.glued_to, face)
  end

  def test_glued_to_Set_component
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    definition = Sketchup.active_model.definitions.add
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_equal(group.glued_to = instance, instance)
    assert_equal(group.glued_to, instance)
  end

  def test_glued_to_Set_group
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    group1 = Sketchup.active_model.entities.add_group

    group2 = Sketchup.active_model.entities.add_group
    group2.definition.behavior.is2d = true

    assert_equal(group2.glued_to = group1, group1)
    assert_equal(group2.glued_to, group1)
  end

  def test_glued_to_Set_image
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_equal(group.glued_to = image, image)
    assert_equal(group.glued_to, image)
  end

  def test_glued_to_Set_nested_gluing
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance1 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance2 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_equal(instance2.glued_to = instance1, instance1)
    assert_equal(instance2.glued_to, instance1)

    assert_equal(group.glued_to = instance2, instance2)
    assert_equal(group.glued_to, instance2)
  end

  def test_glued_to_Set_unglue
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_equal(group.glued_to = face, face)
    assert_equal(group.glued_to, face)

    assert_nil(group.glued_to = nil)
    assert_nil(group.glued_to)
  end

  def test_glued_to_Set_ungluable
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = false

    assert_raises(ArgumentError){
      group.glued_to = face
    }
  end

  def test_glued_to_Set_invalid_argument
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    edge = Sketchup.active_model.entities.add_edges(
      [0, 0, 0], [10, 0, 0]
    ).first

    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_raises(TypeError) {
      group.glued_to = 3048
    }

    assert_raises(ArgumentError) {
      group.glued_to = edge
    }
  end

  def test_glued_to_Set_self
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_raises(ArgumentError) {
      group.glued_to = group
    }
  end

  def test_glued_to_Set_circular
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance1 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance2 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    group = Sketchup.active_model.entities.add_group
    group.definition.behavior.is2d = true

    assert_equal(instance2.glued_to = instance1, instance1)
    assert_equal(instance2.glued_to, instance1)

    assert_equal(group.glued_to = instance2, instance2)
    assert_equal(group.glued_to, instance2)

    assert_raises(ArgumentError) {
      instance1.glued_to = group
    }
  end

  # ========================================================================== #
  # method Sketchup::Group.explode

  def test_explode
    model = Sketchup.active_model
    model.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    group = model.entities.add_group
    group.entities.add_face([0,0,0], [5,0,0], [5,9,0], [0,9,0])
    
    assert_kind_of(Array, group.explode)
    assert(group.deleted?)
    assert_equal(2, model.entities.grep(Sketchup::Face).size)
    assert_equal(7, model.entities.grep(Sketchup::Edge).size)
    assert_equal(9, model.entities.size)
  end

  def test_explode_active_entities
    skip("Fixed in SU2023.0") if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    model.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    group = model.entities.add_group
    group.entities.add_face([0,0,0], [5,0,0], [5,9,0], [0,9,0])
    model.active_path = [group]
    
    assert_kind_of(FalseClass, group.explode)
    refute(group.deleted?)
    assert_equal(1, model.entities.grep(Sketchup::Face).size)
    assert_equal(4, model.entities.grep(Sketchup::Edge).size)
    assert_equal(6, model.entities.size)
  ensure
    model.active_path = nil if model
  end

end # class

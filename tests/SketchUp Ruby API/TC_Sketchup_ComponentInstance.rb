# Copyright:: Copyright 2021 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Christina Eneroth


require "testup/testcase"


# class Sketchup::ComponentInstance
class TC_Sketchup_ComponentInstance < TestUp::TestCase

 def self.setup_testcase
    # ...
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

  def named_component(name)
    Sketchup.active_model.entities.grep(Sketchup::ComponentInstance).find { |c| c.name == name }
  end

  # ========================================================================== #
  # method Sketchup::ComponentInstance.glued_to

  def test_glued_to
    path = testcase_file("glued_instances.skp")
    Sketchup.open_file(path)
    
    assert_nil(named_component("Not glued").glued_to)
    assert_kind_of(Sketchup::Face, named_component("Glued to face").glued_to)
    assert_kind_of(Sketchup::ComponentInstance, named_component("Glued to component").glued_to)
    assert_kind_of(Sketchup::Group, named_component("Glued to group").glued_to)
    assert_kind_of(Sketchup::Image, named_component("Glued to image").glued_to)
  ensure
    close_active_model
  end

  def test_glued_to_too_many_arguments
    definition = Sketchup.active_model.definitions.add
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_raises(ArgumentError) {
      instance.glued_to(3048)
    }
  end

  # ========================================================================== #
  # method Sketchup::ComponentInstance.glued_to=

  def test_glued_to_Set_face
    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_equal(instance.glued_to = face, face)
    assert_equal(instance.glued_to, face)
  end

  def test_glued_to_Set_component
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance1 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance2 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_equal(instance2.glued_to = instance1, instance1)
    assert_equal(instance2.glued_to, instance1)
  end

  def test_glued_to_Set_group
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    group = Sketchup.active_model.entities.add_group

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_equal(instance.glued_to = group, group)
    assert_equal(instance.glued_to, group)
  end

  def test_glued_to_Set_image
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_equal(instance.glued_to = image, image)
    assert_equal(instance.glued_to, image)
  end

  def test_glued_to_Set_nested_gluing
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance1 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance2 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance3 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_equal(instance2.glued_to = instance1, instance1)
    assert_equal(instance2.glued_to, instance1)

    assert_equal(instance3.glued_to = instance2, instance2)
    assert_equal(instance3.glued_to, instance2)
  end

  def test_glued_to_Set_unglue
    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_equal(instance.glued_to = face, face)
    assert_equal(instance.glued_to, face)

    assert_nil(instance.glued_to = nil)
    assert_nil(instance.glued_to)
  end

  def test_glued_to_Set_ungluable
    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = false
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_raises(ArgumentError){
      instance.glued_to = face
    }
  end

  def test_glued_to_Set_invalid_argument
    edge = Sketchup.active_model.entities.add_edges(
      [0, 0, 0], [10, 0, 0]
    ).first

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_raises(TypeError) {
      instance.glued_to = 3048
    }

    assert_raises(ArgumentError) {
      instance.glued_to = edge
    }
  end

  def test_glued_to_Set_self
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_raises(ArgumentError) {
      instance.glued_to = instance
    }
  end

  def test_glued_to_Set_circular
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1
    
    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance1 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance2 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance3 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    assert_equal(instance2.glued_to = instance1, instance1)
    assert_equal(instance2.glued_to, instance1)

    assert_equal(instance3.glued_to = instance2, instance2)
    assert_equal(instance3.glued_to, instance2)

    assert_raises(ArgumentError) {
      instance1.glued_to = instance3
    }
  end

  # ========================================================================== #
  # method Sketchup::ComponentInstance.explode

  def test_explode
    model = Sketchup.active_model
    model.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    definition = model.definitions.add('Gonna go boom!')
    definition.entities.add_face([0,0,0], [5,0,0], [5,9,0], [0,9,0])
    instance = model.entities.add_instance(definition, IDENTITY)
    
    assert_kind_of(Array, instance.explode)
    assert(instance.deleted?)
    assert_equal(2, model.entities.grep(Sketchup::Face).size)
    assert_equal(7, model.entities.grep(Sketchup::Edge).size)
    assert_equal(9, model.entities.size)
  end

  def test_explode_active_entities
    skip("Fixed in SU2023.0") if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    model.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    definition = model.definitions.add('Danger! TNT inside!')
    definition.entities.add_face([0,0,0], [5,0,0], [5,9,0], [0,9,0])
    instance = model.entities.add_instance(definition, IDENTITY)
    model.active_path = [instance]
    
    assert_kind_of(FalseClass, instance.explode)
    refute(instance.deleted?)
    assert_equal(1, model.entities.grep(Sketchup::Face).size)
    assert_equal(4, model.entities.grep(Sketchup::Edge).size)
    assert_equal(6, model.entities.size)
  ensure
    model.active_path = nil if model
  end

end # class

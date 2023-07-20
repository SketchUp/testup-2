# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen (thomthom@sketchup.com)


require "testup/testcase"


# class Sketchup::Image
class TC_Sketchup_Image < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model()
  end

  def teardown
    # ...
  end


  def create_test_image
    entities = Sketchup.active_model.entities
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
    image = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)
    image
  end

  def testcase_file(filename)
    File.join(__dir__, File.basename(__FILE__, ".*"), filename)
  end

  def tagged_image(tag_name)
    Sketchup.active_model.entities.grep(Sketchup::Image).find { |i| i.layer.name == tag_name }
  end


  # ========================================================================== #
  # method Sketchup::Image.explode

  def test_explode_api_example
    model = Sketchup.active_model
    path = "Plugins/su_dynamiccomponents/images"
    image_file = Sketchup.find_support_file("report_tool.png", path)
    image = model.active_entities.add_image(image_file, ORIGIN, 300)
    entities = image.explode
  end

  def test_explode
    image = create_test_image()
    result = image.explode
    assert_kind_of(Array, result)
    assert(image.deleted?)
  end

  def test_explode_return_entities
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    image = create_test_image()
    result = image.explode
    assert_kind_of(Array, result)
    assert(!result.empty?, "Returned array wasn't empty.")
    assert(result.all? { |entity| entity.is_a?(Sketchup::Entity)})
  end

  def test_explode_incorrect_number_of_arguments_one
    image = create_test_image()
    assert_raises ArgumentError do
      image.explode(123)
    end
  end

  def test_image_rep
    skip("New in SU2018") if Sketchup.version.to_i < 18
    entities = Sketchup.active_model.entities
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
    image = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)
    image_rep = image.image_rep
    assert_kind_of(Sketchup::ImageRep, image_rep)
  end

  def test_image_rep_too_many_arguments
    skip("New in SU2018") if Sketchup.version.to_i < 18
    entities = Sketchup.active_model.entities
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
    image = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)
    assert_raises(ArgumentError) do
      image.image_rep(nil)
    end
  end

  def test_image_rep_missing_material
    skip("Fixed crash in SketchUp 2021.1") if Sketchup.version.to_f < 21.1

    path = testcase_file("missing_material.skp")
    Sketchup.open_file(path)
    image = Sketchup.active_model.entities.grep(Sketchup::Image).first

    assert_raises(ArgumentError) do
      image.image_rep
    end
  end

  # ========================================================================== #
  # method Sketchup::Image.glued_to

  def test_glued_to
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    path = testcase_file("glued_images.skp")
    Sketchup.open_file(path)

    assert_nil(tagged_image("Not glued").glued_to)
    assert_kind_of(Sketchup::Face, tagged_image("Glued to face").glued_to)
    assert_kind_of(Sketchup::ComponentInstance, tagged_image("Glued to component").glued_to)
    assert_kind_of(Sketchup::Group, tagged_image("Glued to group").glued_to)
    assert_kind_of(Sketchup::Image, tagged_image("Glued to image").glued_to)
  ensure
    close_active_model
  end

  def test_glued_to_too_many_arguments
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_raises(ArgumentError) {
      image.glued_to(3048)
    }
  end

  # ========================================================================== #
  # method Sketchup::Group.glued_to=

  def test_glued_to_Set_face
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_equal(image.glued_to = face, face)
    assert_equal(image.glued_to, face)
  end

  def test_glued_to_Set_component
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    definition = Sketchup.active_model.definitions.add
    instance = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_equal(image.glued_to = instance, instance)
    assert_equal(image.glued_to, instance)
  end

  def test_glued_to_Set_group
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    group = Sketchup.active_model.entities.add_group

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_equal(image.glued_to = group, group)
    assert_equal(image.glued_to, group)
  end

  def test_glued_to_Set_image
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image1 = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    image2 = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_equal(image1.glued_to = image2, image2)
    assert_equal(image1.glued_to, image2)
  end

  def test_glued_to_Set_nested_gluing
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance1 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance2 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_equal(instance2.glued_to = instance1, instance1)
    assert_equal(instance2.glued_to, instance1)

    assert_equal(image.glued_to = instance2, instance2)
    assert_equal(image.glued_to, instance2)
  end

  def test_glued_to_Set_unglue
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    face = Sketchup.active_model.entities.add_face(
      [[0, 0, 0], [10, 0, 0], [10, 10, 0,], [0, 10, 0]]
    )

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_equal(image.glued_to = face, face)
    assert_equal(image.glued_to, face)

    assert_nil(image.glued_to = nil)
    assert_nil(image.glued_to)
  end

  def test_glued_to_Set_invalid_argument
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    edge = Sketchup.active_model.entities.add_edges(
      [0, 0, 0], [10, 0, 0]
    ).first

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_raises(TypeError) {
      image.glued_to = 3048
    }

    assert_raises(ArgumentError) {
      image.glued_to = edge
    }
  end

  def test_glued_to_Set_self
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_raises(ArgumentError) {
      image.glued_to = image
    }
  end

  def test_glued_to_Set_circular
    skip("Implemented in 2021.1") if Sketchup.version.to_f < 21.1

    definition = Sketchup.active_model.definitions.add
    definition.behavior.is2d = true
    instance1 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)
    instance2 = Sketchup.active_model.entities.add_instance(definition, IDENTITY)

    dir = "Plugins/su_dynamiccomponents/images"
    path = Sketchup.find_support_file("report_tool.png", dir)
    image = Sketchup.active_model.active_entities.add_image(path, ORIGIN, 300)

    assert_equal(instance2.glued_to = instance1, instance1)
    assert_equal(instance2.glued_to, instance1)

    assert_equal(image.glued_to = instance2, instance2)
    assert_equal(image.glued_to, instance2)

    assert_raises(ArgumentError) {
      instance1.glued_to = image
    }
  end

end # class

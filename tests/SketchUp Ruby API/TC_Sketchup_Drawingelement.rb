# Copyright:: Copyright 2019-2022 Trimble Inc.
# License:: The MIT License (MIT)

require "testup/testcase"
require_relative "utils/image_helper"


# class Sketchup::Drawingelement
class TC_Sketchup_Drawingelement < TestUp::TestCase

  include TestUp::SketchUpTests::ImageHelper

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end


  def create_face
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0, 0, 0], [100, 0, 0], [100, 100, 0], [0, 100, 0])
    face.reverse!
    face
  end

  def create_material
    path = Sketchup.temp_dir
    full_name = File.join(path, "temp_image.jpg")
    Sketchup.active_model.active_view.write_image(
      full_name, 500, 500, false, 0.0)
    material = Sketchup.active_model.materials.add("Test Material")
    material.texture = full_name
    material
  end


  # ========================================================================== #
  # method Sketchup::Face.material

  def test_material_api_example
    depth = 100
    width = 100
    model = Sketchup.active_model
    entities = model.active_entities
    pts = []
    pts[0] = [0, 0, 0]
    pts[1] = [width, 0, 0]
    pts[2] = [width, depth, 0]
    pts[3] = [0, depth, 0]

    # Add the face to the entities in the model
    face = entities.add_face(pts)

    # Add a material to the back face, then check to see that it was added
    face.material = "red"
    material = face.material
  end

  def test_material
    face = create_face
    face.material = "red"
    result = face.material

    assert_kind_of(Sketchup::Material, result)
  end

  def test_material_arity
    assert_equal(0, Sketchup::Face.instance_method(:material).arity)
  end

  def test_material_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.material("String!")
    end

    assert_raises(ArgumentError) do
      face.material(["Array"])
    end

    assert_raises(ArgumentError) do
      face.material(false)
    end

    assert_raises(ArgumentError) do
      face.material(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Drawingelement.material=

  def test_material_Set_api_example
    depth = 100
    width = 100
    model = Sketchup.active_model
    entities = model.active_entities
    pts = []
    pts[0] = [0, 0, 0]
    pts[1] = [width, 0, 0]
    pts[2] = [width, depth, 0]
    pts[3] = [0, depth, 0]
    # Add the face to the entities in the model
    face = entities.add_face(pts)
    status = face.material = "red"
  end

  def test_material_Set_Integer
    face = create_face
    result = face.material = 255
    assert_kind_of(Integer, result)
  end

  def test_material_Set_HexInteger
    face = create_face
    result = face.material = 0xff
    assert_kind_of(Integer, result)
  end

  def test_material_Set_HexString
    face = create_face
    result = face.material = '#ff0000'
    assert_kind_of(String, result)
  end

  def test_material_Set_ArrayFloat
    face = create_face
    result = face.material = [1.0, 0.0, 0.0]
    assert_kind_of(Array, result)
  end

  def test_material_Set_ArrayInteger
    face = create_face
    result = face.material = [255, 0, 0]
    assert_kind_of(Array, result)
  end

  def test_material_Set_string
    face = create_face
    result = face.material = "red"
    assert_kind_of(String, result)
  end

  def test_material_Set_material_object
    face = create_face
    material = Sketchup.active_model.materials.add("Material")
    material.color = "red"
    result = face.material = material
    assert_kind_of(Sketchup::Material, result)
  end

  def test_material_Set_image_material
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    face = create_face
    image_material = create_image_material
    assert_raises(ArgumentError) do
      face.material = image_material
    end
    assert_nil(face.material)
  end

  def test_material_Set_sketchupcolor
    face = create_face
    result = face.material = (Sketchup::Color.new("red"))
    assert_kind_of(Sketchup::Color, result)
  end

  def test_material_Set_deleted_material
    face = create_face
    material = create_material
    Sketchup.active_model.materials.remove(material)
    assert_raises(ArgumentError) do
      face.back_material = material
    end
  end

  def test_material_Set_arity
    assert_equal(1, Sketchup::Face.instance_method(:material=).arity)
  end

  def test_material_Set_invalid_arguments
    skip("Fix this!") if Sketchup.version.to_i < 18
    # SU-30036 - Leaves open operation upon raising errors.
    skip("Broken in SU2014") if Sketchup.version.to_i == 14 # SU-30036
    face = create_face

    assert_raises(ArgumentError) do
      face.material = "invalid color name"
    end

    assert_raises(ArgumentError) do
      face.material = ["Array"]
    end

    #assert_raises(TypeError) do
    #  face.material = nil
    #end
  end

  # ========================================================================== #
  # method Sketchup::Drawingelement.erase!

  def test_erase_Bang
    model = Sketchup.active_model
    group = model.entities.add_group
    group.entities.add_line([0,0,0], [9,9,9])
    group.erase!
    assert(group.deleted?)
    assert_equal(0, model.entities.size)
  end

  def test_erase_Bang_active_entities
    skip("Fixed in SU2023.0") if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    group = model.entities.add_group
    group.entities.add_line([0,0,0], [9,9,9])
    model.active_path = [group]
    assert_raises(ArgumentError) do
      group.erase!
    end
    refute(group.deleted?)
  ensure
    model.active_path = nil if model
  end

end

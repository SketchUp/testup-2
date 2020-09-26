# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"
require_relative "utils/image_helper"


# class Sketchup::Material
# http://www.sketchup.com/intl/developer/docs/ourdoc/material
class TC_Sketchup_Material < TestUp::TestCase

  include TestUp::SketchUpTests::ImageHelper

  def setup
    disable_read_only_flag_for_test_models()
    open_test_model()
  end

  def teardown
    restore_read_only_flag_for_test_models()
  end


  # TODO(thomthom): Move to TestUp2 utility methods and merge with
  # TC_Sketchup_Classifications.
  def open_test_model
    basename = File.basename(__FILE__, ".*")
    path = File.dirname(__FILE__)
    test_model = File.join(path, basename, "MaterialTests.skp")
    # To speed up tests the model is reused is possible. Tests that modify the
    # model should discard the model changes: close_active_model()
    # TODO(thomthom): Add a Ruby API method to expose the `dirty` state of the
    # model - whether it's been modified since last save/open.
    # Model.path must be converted to Ruby style path as SketchUp returns an
    # OS dependant path string.
    model = Sketchup.active_model
    if model.nil? || File.expand_path(model.path) != test_model
      close_active_model()
      Sketchup.open_file(test_model)
    end
    Sketchup.active_model
  end

  def get_test_file(filename)
    File.join(__dir__, "TC_Sketchup_Material", filename)
  end


  # ========================================================================== #
  # method Sketchup::Material.colorize_deltas
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#colorize_deltas

  def test_colorize_deltas_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials[0]
    h, l, s = material.colorize_deltas
  end

  def test_colorize_deltas_solid_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Solid"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_equal([0.0, 0.0, 0.0], result)
  end

  def test_colorize_deltas_textured_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Textured"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_equal([0.0, 0.0, 0.0], result)
  end

  def test_colorize_deltas_colorized_textured_material_shifted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedShifted"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_in_delta(-124.15384917569565,    result[0], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(-0.0019607990980148315, result[1], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta( 0.27996034147878235,   result[2], SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_colorize_deltas_colorized_textured_material_tinted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedTinted"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_in_delta(38.04878252219892,     result[0], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(0.0039215534925460815, result[1], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(0.3604408195287968,    result[2], SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_colorize_deltas_incorrect_number_of_arguments_one
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.colorize_deltas(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Material.name
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#name

  def test_name
    materials = Sketchup.active_model.materials
    assert_equal("Textured", materials[0].name)
    assert_equal("TexturedShifted", materials[1].name)
  end

  def test_name_incorrect_number_of_arguments_one
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.name(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Material.name=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#name=

  def test_set_name
    materials = Sketchup.active_model.materials
    test_mat = materials.add("test_name")
    assert_equal("test_name", test_mat.name)
    test_mat.name = "test_name0"
    assert_equal("test_name0", test_mat.name)
    test_mat.name = "Textured0"
    assert_equal("Textured0", test_mat.name)
  ensure
    discard_model_changes()
  end

  def test_set_name_duplicate_failure
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.name = "Textured"
    end
  ensure
    discard_model_changes()
  end

  def test_set_name_reuse_old_name
    material = Sketchup.active_model.materials.add('OriginalName')
    material.name = "NewUnusedName"
    material.name = "OriginalName"
  end

  def test_set_name_invalid_argument
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(TypeError) do
      material.name = nil
    end
    assert_raises(TypeError) do
      material.name = material
    end
  ensure
    discard_model_changes()
  end

  def test_set_name_to_same_name
    skip("Bugged in SU2018") if Sketchup.version.to_i == 18
    start_with_empty_model
    name = "thenameisthegame"
    material = Sketchup.active_model.materials.add(name)
    returned_name = material.name = name
    assert_equal(returned_name, name)
    assert_equal(material.name, name)
  ensure
    discard_model_changes()
  end

  # ========================================================================== #
  # method Sketchup::Material.colorize_type
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#colorize_type

  def test_colorize_type_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials[0]
    type = material.colorize_type
  end

  def test_colorize_type_solid_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Solid"]
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_SHIFT, result)
  end

  def test_colorize_type_textured_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Textured"]
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_SHIFT, result)
  end

  def test_colorize_type_colorized_textured_material_shifted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedShifted"]
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_SHIFT, result)
  end

  def test_colorize_type_colorized_textured_material_tinted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedTinted"]
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_TINT, result)
  end

  def test_colorize_type_incorrect_number_of_arguments_one
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.colorize_type(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Material.colorize_type=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#colorize_type=

  def test_colorize_type_Set_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials[0]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_solid_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Solid"]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_TINT, result)
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_textured_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Textured"]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_TINT, result)
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_colorized_textured_material_shifted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedShifted"]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_TINT, result)
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_colorized_textured_material_tinted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedTinted"]
    material.colorize_type = Sketchup::Material::COLORIZE_SHIFT
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_SHIFT, result)
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_invalid_argument_nil
    material = Sketchup.active_model.materials["TexturedShifted"]
    assert_raises(TypeError) do
      material.colorize_type = nil
    end
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_invalid_argument_point
    material = Sketchup.active_model.materials["TexturedShifted"]
    assert_raises(TypeError) do
      material.colorize_type = ORIGIN
    end
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_invalid_argument_string
    material = Sketchup.active_model.materials["TexturedShifted"]
    assert_raises(TypeError) do
      material.colorize_type = "FooBar"
    end
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_invalid_argument_negative_integer
    material = Sketchup.active_model.materials["TexturedShifted"]
    assert_raises(RangeError) do
      material.colorize_type = -1
    end
  ensure
    discard_model_changes()
  end

  def test_colorize_type_Set_invalid_argument_invalid_enum
    material = Sketchup.active_model.materials["TexturedShifted"]
    assert_raises(ArgumentError) do
      material.colorize_type = 3
    end
  ensure
    discard_model_changes()
  end


  # ========================================================================== #
  # method Sketchup::Material.materialType
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#materialType

  def test_materialType_api_example
    material = Sketchup.active_model.materials[0]
    type = material.materialType
  end

  def test_materialType_solid_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Solid"]
    result = material.materialType
    assert_equal(0, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    if Sketchup.version.to_i < 15
      assert_equal(Sketchup::Material::MATERIAL_SOLID, result)
    end
  end

  def test_materialType_textured_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["Textured"]
    result = material.materialType
    assert_equal(1, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    if Sketchup.version.to_i < 15
      assert_equal(Sketchup::Material::MATERIAL_TEXTURED, result)
    end
  end

  def test_materialType_colorized_textured_material_shifted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedShifted"]
    result = material.materialType
    assert_equal(2, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    if Sketchup.version.to_i < 15
      assert_equal(Sketchup::Material::MATERIAL_COLORIZED_TEXTURED, result)
    end
  end

  def test_materialType_colorized_textured_material_tinted
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    material = Sketchup.active_model.materials["TexturedTinted"]
    result = material.materialType
    assert_equal(2, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    if Sketchup.version.to_i < 15
      assert_equal(Sketchup::Material::MATERIAL_COLORIZED_TEXTURED, result)
    end
  end

  def test_materialType_incorrect_number_of_arguments_one
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.materialType(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Material.save_as

  def test_save_as_api_example
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    filename = File.join(ENV['HOME'], 'Desktop', 'su_test.skm')
    materials = Sketchup.active_model.materials
    material = materials.add("Hello World")
    material.color = 'red'
    material.save_as(filename)
  ensure
    discard_model_changes()
  end

  def test_save_as
    filename = File.join(Sketchup.temp_dir, 'TC_Sketchup_Material_save_as.skm')
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    material = Sketchup.active_model.materials["Solid"]
    # Make sure there isn't an old version.
    File.delete(filename) if File.exist?(filename)
    refute(File.exist?(filename))
    # Make sure the method actually writes out a material.
    result = material.save_as(filename)
    assert(result)
    assert(File.exist?(filename))
  ensure
    File.delete(filename) if File.exist?(filename)
  end

  def test_save_as_invalid_argument_nil
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(TypeError) do
      material.save_as(nil)
    end
  end

  def test_save_as_invalid_argument_integer
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(TypeError) do
      material.save_as(123)
    end
  end

  def test_save_as_incorrect_number_of_arguments_zero
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.save_as
    end
  end

  def test_save_as_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.save_as('foo', 'bar')
    end
  end

  def test_alpha
    material = Sketchup.active_model.materials[0]
    assert_equal(1.0, material.alpha)
  end

  def test_alpha_Set
    material = Sketchup.active_model.materials[0]
    assert_equal(1.0, material.alpha)
    material.alpha = 0.0
    assert_equal(0.0, material.alpha)
    material.alpha = 0.4
    assert_equal(0.4, material.alpha)
    material.alpha = 1.0
    assert_equal(1.0, material.alpha)
  ensure
    discard_model_changes()
  end

  def test_color
    material = Sketchup.active_model.materials[0]
    color = Sketchup::Color.new(144, 143, 146, 0)
    assert_kind_of(Sketchup::Color, material.color)
    assert_equal(color.to_a, material.color.to_a)
  end

  def test_color_Set
    material = Sketchup.active_model.materials.add('Joe')
    color = Sketchup::Color.new(32, 64, 128, 255)
    assert_equal([0, 0, 0, 0], material.color.to_a)

    material.color = color
    assert_equal(color.to_a, material.color.to_a)
  ensure
    discard_model_changes()
  end

  def test_display_name
    material = Sketchup.active_model.materials[0]
    assert_equal("Textured", material.display_name)

    material = Sketchup.active_model.materials["Solid"]
    assert_equal("Solid", material.display_name)
    assert_kind_of(String, material.display_name)
  end

  def test_name_Set
    material = Sketchup.active_model.materials.add('Joe')
    assert_equal("Joe", material.name)
    material.name = "Woof"
    assert_equal("Woof", material.name)
  ensure
    discard_model_changes()
  end

  def test_texture
    texture = Sketchup.active_model.materials[0].texture
    assert(texture.valid?)
    assert_kind_of(Sketchup::Texture, texture)
  end

  def test_texture_Set
    material = Sketchup.active_model.materials.add("Joe")
    assert_equal([0, 0, 0, 0], material.color.to_a)
    file = get_test_file("test.jpg")
    material.texture = file
    assert_equal([190, 177, 168, 255], material.color.to_a)
    assert_equal(656, material.texture.image_width)
    assert_equal(337, material.texture.image_height)
  ensure
    discard_model_changes()
  end

  def test_texture_Set_properties
    material = Sketchup.active_model.materials.add("Joe")
    assert_equal([0, 0, 0, 0], material.color.to_a)
    file = get_test_file("test.jpg")
    material.texture = [file, 1024, 768]
    assert_equal([190, 177, 168, 255], material.color.to_a)
    assert_equal(1024, material.texture.width)
    assert_equal(768, material.texture.height)
  ensure
    discard_model_changes()
  end

  def test_texture_Set_image_rep
    material = Sketchup.active_model.materials.add("Joe")
    assert_equal([0, 0, 0, 0], material.color.to_a)
    file = get_test_file("test.jpg")
    image_rep = Sketchup::ImageRep.new(file)
    material.texture = image_rep
    assert_equal([190, 177, 168, 255], material.color.to_a)
    assert_equal(656, material.texture.image_width)
    assert_equal(337, material.texture.image_height)
  ensure
    discard_model_changes()
  end

  def test_use_alpha_Query
    material = Sketchup.active_model.materials[0]
    refute(material.use_alpha?)
    assert_kind_of(FalseClass, material.use_alpha?)
  end

  def test_write_thumbnail
    material = Sketchup.active_model.materials.add("Joe")
    filename = File.join(Sketchup.temp_dir, 'TC_Sketchup_Material_test.png')
    File.delete(filename) if File.exist?(filename)
    refute(File.exist?(filename))
    # Make sure the method actually writes out a material.
    result = material.write_thumbnail(filename, 128)
    assert(result)
    assert(File.exist?(filename))
  ensure
    File.delete(filename) if File.exist?(filename)
  end

  def test_Operator_Equal
    material1 = Sketchup.active_model.materials[0]
    material2 = Sketchup.active_model.materials[0]
    assert(material1 == material2)
    material2 = Sketchup.active_model.materials.add("Joe")
    refute(material1 == material2)
  ensure
    discard_model_changes()
  end

  def test_owner_type_normal_material
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    model_material = Sketchup.active_model.materials.add('TestMaterialType')
    model_material.owner_type == Sketchup::Material::OWNER_MANAGER
  ensure
    discard_model_changes()
  end

  def test_owner_type_image_material
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    image_material = create_image_material
    image_material.owner_type == Sketchup::Material::OWNER_IMAGE
  ensure
    discard_model_changes()
  end

  def test_owner_type_incorrect_number_of_arguments_one
    skip('Added in SU2019.2') if Sketchup.version.to_f < 19.2
    material = Sketchup.active_model.materials["Solid"]
    assert_raises(ArgumentError) do
      material.owner_type(123)
    end
  end

end # class

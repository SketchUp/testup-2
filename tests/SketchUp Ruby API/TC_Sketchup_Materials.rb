# Copyright:: Copyright 2016-2019 Trimble Inc Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"
require_relative "utils/image_helper"


# class Sketchup::Materials
class TC_Sketchup_Materials < TestUp::TestCase

  include TestUp::SketchUpTests::ImageHelper

  def setup
    start_with_empty_model
  end

  def teardown
  end

  def add_material_joe
    materials = Sketchup.active_model.materials
    material = materials.add('Joe')
    return material, materials
  end

  # ========================================================================== #
  # method Sketchup::Materials.load

  def test_load_api_example
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    # Load a material from the shipped SketchUp library. (SketchUp 2016)
    filename = 'Materials/Brick, Cladding and Siding/Cinder Block.skm'
    path = Sketchup.find_support_file(filename)
    materials = Sketchup.active_model.materials
    material = materials.load(path)
  end

  def test_load
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    # Load a material from the shipped SketchUp library. (SketchUp 2016)
    filename = 'Materials/Brick, Cladding and Siding/Cinder Block.skm'
    path = Sketchup.find_support_file(filename)
    materials = Sketchup.active_model.materials
    num_materials = materials.size
    result = materials.load(path)
    assert_kind_of(Sketchup::Material, result)
    assert_equal(num_materials + 1, materials.size)
  end

  def test_load_existing
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    # Load a material from the shipped SketchUp library. (SketchUp 2016)
    filename = 'Materials/Brick, Cladding and Siding/Cinder Block.skm'
    path = Sketchup.find_support_file(filename)
    materials = Sketchup.active_model.materials
    num_materials = materials.size
    material = materials.load(path)
    assert_kind_of(Sketchup::Material, material)
    assert_equal(num_materials + 1, materials.size)
    # Now try to load it again and we should get the previous one.
    result = materials.load(path)
    assert_equal(material, result)
    assert_equal(num_materials + 1, materials.size)
  end

  def test_load_non_existing_file
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    materials = Sketchup.active_model.materials
    assert_raises(RuntimeError) do
      materials.load('no_such_file.skm')
    end
  end

  def test_load_invalid_argument_nil
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    materials = Sketchup.active_model.materials
    assert_raises(TypeError) do
      materials.load(nil)
    end
  end

  def test_load_invalid_argument_integer
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    materials = Sketchup.active_model.materials
    assert_raises(TypeError) do
      materials.load(123)
    end
  end

  def test_load_incorrect_number_of_arguments_zero
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    materials = Sketchup.active_model.materials
    assert_raises(ArgumentError) do
      materials.load
    end
  end

  def test_load_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    materials = Sketchup.active_model.materials
    assert_raises(ArgumentError) do
      materials.load('foo', 'bar')
    end
  end

  # ========================================================================== #
  # method Sketchup::Materials.unique_name
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#unique_name

  def test_unique_name
    # Prepopulate the empty model with a material
    materials = Sketchup.active_model.materials
    materials.add("Textured")
	# Test unique and non-unique names
    assert_equal("test", materials.unique_name("test"))
    assert_equal("Textured1", materials.unique_name("Textured"))
    test_mat = materials.add("TEXTURED")
    assert_equal("textureD2", materials.unique_name("textureD"))
  end

  def test_unique_name_invalid_argument
    materials = Sketchup.active_model.materials
    assert_raises(TypeError) do
      materials.unique_name(nil)
    end
    assert_raises(NameError) do
      materials.unique_name(material)
    end
  end

  def test_unique_name_too_many_arguments
    materials = Sketchup.active_model.materials
    assert_raises(ArgumentError) do
      materials.unique_name("test0", "test1")
    end
  end

  def test_add
    material, materials = add_material_joe
    assert_kind_of(Sketchup::Material, material)
    assert_equal("Joe", material.name)
  end

  def test_add_invalid_arguments
    materials = Sketchup.active_model.materials
    assert_raises(ArgumentError) do
      materials.add(123)
    end

    assert_raises(ArgumentError) do
      materials.add(nil)
    end

    assert_raises(ArgumentError) do
      materials.add(Geom::Point3d.new(0, 0, 0))
    end

    cat = materials.add('cat')
    assert_raises(ArgumentError) do
      materials.add(cat)
    end
  end

  def test_add_too_many_arguments
    materials = Sketchup.active_model.materials
    assert_raises(ArgumentError) do
      materials.add(123, 123)
    end

    assert_raises(ArgumentError) do
      materials.add('Joe', 1234)
    end
  end

  def test_add_too_few_arguments
    material = Sketchup.active_model.materials.add
    assert_kind_of(Sketchup::Material, material)
    assert_equal("Material", material.name)

    material2 = Sketchup.active_model.materials.add
    assert_kind_of(Sketchup::Material, material2)
    assert_equal("Material1", material2.name)
  end

  def test_add_same_name
    material, materials = add_material_joe
    assert_kind_of(Sketchup::Material, material)
    assert_equal("Joe", material.name)

    material2 = materials.add('Joe')
    assert_equal("Joe1", material2.name)
  end

  def test_at
    expected_material, materials = add_material_joe
    material = materials.at(0)
    assert_equal(expected_material, material)

    material2 = materials.at('Joe')
    assert_equal(expected_material, material2)
  end

  def test_at_negative_index
    expected_material, materials = add_material_joe
    material = materials.at(-1)
    assert_equal(expected_material, material)

    expected_material2 = materials.add("Bake On")
    material2 = materials.at(-1)
    assert_equal(expected_material2, material2)
  end

  def test_at_unexisting_names
    material, materials = add_material_joe
    val = materials.at('No Bacon')
    assert_kind_of(NilClass, val)
  end

  def test_at_out_of_bounds
    material, materials = add_material_joe
    assert_raises(IndexError) do
      materials.at(1337)
    end
  end

  def test_at_invalid_arguments
    material, materials = add_material_joe
    assert_raises(TypeError) do
      materials.at(nil)
    end

    assert_raises(TypeError) do
      materials.at(['Joe'])
    end
  end

  def test_at_too_many_arguments
    material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.at(0, 0)
    end

    assert_raises(ArgumentError) do
      materials.at('Joe', 'Joe')
    end

    assert_raises(ArgumentError) do
      materials.at(0, nil)
    end
  end

  def test_at_too_few_arguments
    material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.at
    end
  end

  def test_count
    material, materials = add_material_joe
    assert_equal(1, materials.count)

    materials.add('Bacon fat')
    assert_equal(2, materials.count)
  end

  def test_count_invalid_arguments
    skip("Skipped: Expected ArgumentError to be raised but nothing is raised")
    material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.count(1234)
    end
  end

  def test_count_kind_of_enumerable_entity
    material, materials = add_material_joe
    assert_kind_of(Enumerable, materials)
    assert_kind_of(Sketchup::Entity, materials)
  end

  def test_current
    expected_material, materials = add_material_joe
    materials.current = expected_material
    material = materials.current
    assert_equal(expected_material, material)

    material2 = materials.add('bacon')
    material3 = materials.add('delicious')
    materials.current = material2

    assert_equal(material2, materials.current)
  end

  def test_current_invalid_arguments
    expected_material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.current(nil)
    end
  end

  def test_current_Set
    expected_material, materials = add_material_joe
    assert_equal(nil, materials.current)
    materials.current = expected_material
    material = materials.current
    assert_equal(expected_material, material)
  end

  def test_current_Set_by_existing_name
    expected_material, materials = add_material_joe
    materials.current = 'Joe'
    material = materials.current
    assert_equal(expected_material, material)
  end

  def test_current_Set_invalid_arguments
    expected_material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.current = "Bacon wrapping bacon"
    end

    # Jin expected this to fail but this doesn't... the logic surrounding
    # GetRubyMaterial isn't type checking all the way.
    #assert_raises(ArgumentError) do
    #  materials.current = 123
    #end
  end

  def test_each
    material, materials = add_material_joe
    materials.add('Bacon')
    materials.add('wrap')
    materials.add('more')
    materials.add('bacons')

    materials.each { |mat| assert_kind_of(Sketchup::Material, mat) }
  end

  def test_each_invalid_arguments
    material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.each(nil)
    end
  end

  def test_size
    material, materials = add_material_joe
    assert_equal(1, materials.size)
    assert_kind_of(Integer, materials.size)
    materials.add('Baconception')
    assert_equal(2, materials.size)
  end

  def test_size_invalid_arguments
    material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.size(nil)
    end
  end

  def test_length
    material, materials = add_material_joe
    assert_equal(1, materials.length)
    assert_kind_of(Integer, materials.length)
    materials.add('Bacon crispy')
    assert_equal(2, materials.length)
  end

  def test_length_invalid_arguments
    material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.length(nil)
    end
  end

  def test_purge_unused
    material, materials = add_material_joe
    assert_equal(1, materials.count)
    materials.purge_unused
    assert_equal(0, materials.count)
  end

  def test_purge_unused_face_material
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
    face2 = entities.add_face([0, 0, 0], [1, 0, 0], [2, 2, 0], [0, 3, 0])

    # add a few materials
    material, materials = add_material_joe
    bacon_material = materials.add("bacon")
    delicious_material = materials.add("delicious")
    steak_material = materials.add("steak")
    face.material = bacon_material
    face2.material = steak_material
    materials.purge_unused
    assert_equal(2, materials.count)

    # remove a material from a face and purge the materials list
    face.material = nil
    materials.purge_unused
    assert_equal(1, materials.count)
  end

  def test_purge_unused_invalid_arguments
    material, materials = add_material_joe
    assert_raises(ArgumentError) do
      materials.purge_unused(nil)
    end
  end

  def test_remove
    material, materials = add_material_joe
    assert_equal(1, materials.count)
    materials.remove(material)
    assert_equal(0, materials.count)
  end

  def test_remove_by_name
    material, materials = add_material_joe
    assert_equal(1, materials.count)
    result = materials.remove('Joe')
    assert_equal(0, materials.count)
    assert_equal(true, result)
    assert_kind_of(TrueClass, result)
  end

  def test_remove_invalid_arguments
    material, materials = add_material_joe
    result = materials.remove(123)
    refute(result)
    assert_kind_of(FalseClass, result)
  end

  def test_remove_invalid_arguments_image_material
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    materials = Sketchup.active_model.materials
    image_material = create_image_material
    assert_raises(ArgumentError) do
      materials.remove(image_material)
    end
  end

end # class

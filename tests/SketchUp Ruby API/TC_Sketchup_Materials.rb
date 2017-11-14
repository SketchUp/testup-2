# Copyright:: Copyright 2016 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Materials
class TC_Sketchup_Materials < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
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

end # class

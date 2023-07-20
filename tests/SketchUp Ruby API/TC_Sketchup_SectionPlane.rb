# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen (thomthom@sketchup.com)

require "testup/testcase"

# class Sketchup::SectionPlane
class TC_Sketchup_SectionPlane < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end
  
  def setup
    start_with_empty_model
    create_test_cube
    @section_plane = create_test_section_plane
  end

  def teardown
    # ...
  end


  def create_test_cube
    group = Sketchup.active_model.entities.add_group
    entities = group.entities
    face = entities.add_face([0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0])
    face.pushpull(-9)
    group
  end

  def create_test_section_plane
    entities = Sketchup.active_model.entities
    Sketchup.active_model.entities.add_section_plane([50, 50, 0], [1.0, 1.0, 0])
  end


  # ========================================================================== #
  # method Sketchup::SectionPlane.name

  def test_name_api_example
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    model = Sketchup.active_model
    entities = model.active_entities
    # Grab the first section plane from the model.
    section_plane = entities.grep(Sketchup::SectionPlane).first
    name = section_plane.name
  end

  def test_name
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    result = @section_plane.name
    assert_kind_of(String, result)
  end

  def test_name_incorrect_number_of_arguments_one
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @section_plane.name(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::SectionPlane.name=

  def test_name_Set_api_example
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    model = Sketchup.active_model
    entities = Sketchup.active_model.entities
    # Grab the first section plane from the model.
    section_plane = entities.grep(Sketchup::SectionPlane).first
    section_plane.name = "my section plane"
  end

  def test_name_Set
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    @section_plane.name = 'New Section Name'
    assert_equal('New Section Name', @section_plane.name)
  end

  def test_name_Set_invalid_argument_types
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(TypeError) do
      @section_plane.name = nil
    end
    assert_raises(TypeError) do
      @section_plane.name = 123
    end
  end


  # ========================================================================== #
  # method Sketchup::SectionPlane.symbol

  def test_symbol_api_example
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    model = Sketchup.active_model
    entities = model.active_entities
    # Grab the first section plane from the model.
    section_plane = entities.grep(Sketchup::SectionPlane).first
    symbol = section_plane.symbol
  end

  def test_symbol
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    result = @section_plane.symbol
    assert_kind_of(String, result)
  end

  def test_symbol_incorrect_number_of_arguments_one
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @section_plane.symbol(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::SectionPlane.symbol=

  def test_Set_symbol_api_example
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    model = Sketchup.active_model
    entities = Sketchup.active_model.entities
    # Grab the first section plane from the model.
    section_plane = entities.grep(Sketchup::SectionPlane).first
    section_plane.symbol = "AB1"
  end

  def test_Set_symbol
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    @section_plane.symbol = 'AB1'
    assert_equal('AB1', @section_plane.symbol)
  end

  def test_Set_symbol_empty
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    @section_plane.symbol = ''
    assert_equal('', @section_plane.symbol)
  end

  def test_Set_symbol_too_long
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(ArgumentError) do
      @section_plane.symbol = 'ABCD'
    end
  end

  def test_Set_symbol_invalid_argument_types
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    assert_raises(TypeError) do
      @section_plane.symbol = nil
    end
    assert_raises(TypeError) do
      @section_plane.symbol = 123
    end
  end

end # class

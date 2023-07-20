# Copyright:: Copyright 2019 Trimble Inc.
# License:: The MIT License (MIT)

require "testup/testcase"

# class Sketchup::Selection
class TC_Sketchup_Selection < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def before_all
    start_with_empty_model
    create_test_entities
    true
  end

  def setup
    @before_all ||= before_all
    Sketchup.active_model.selection.clear
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

  def create_test_entities
    entities = Sketchup.active_model.entities
    group = create_test_cube
    cube = group.to_component
    tr = Geom::Transformation.new([20, 20, 0])
    instance = entities.add_instance(cube.definition, tr)
    instance.explode
    entities
  end


  # ========================================================================== #
  # method Sketchup::Selection.invert

  def test_invert_api_example
    skip("Implemented in SU2019.2") if Sketchup.version.to_f < 19.2
    model = Sketchup.active_model
    entities = model.active_entities
    selection = model.selection
    # Create a cube
    face = entities.add_face([0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0])
    face.pushpull(-9)
    # Add the first two faces to the selection
    faces = entities.grep(Sketchup::Face).take(2)
    selection.add(faces)
    # Invert selection
    selection.invert
  end

  def test_invert
    skip("Implemented in SU2019.2") if Sketchup.version.to_f < 19.2
    model = Sketchup.active_model
    entities = model.active_entities
    selection = model.selection
    faces = entities.grep(Sketchup::Face).take(2)
    selection.add(faces)
    assert_equal(2, selection.size)

    assert_nil(selection.invert)
    assert_equal(entities.size - 2, selection.size)
    assert((selection.to_a & faces).empty?)
  end

  def test_invert_incorrect_number_of_arguments_one
    skip("Implemented in SU2019.2") if Sketchup.version.to_f < 19.2
    assert_raises(ArgumentError) do
      Sketchup.active_model.selection.clear(123)
    end
  end

end # class

# Copyright:: Copyright 2015-2022 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"


# class Sketchup::DefinitionList
class TC_Sketchup_DefinitionList < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model()
  end

  def teardown
    # ...
  end

  def get_test_case_dir
    File.join(__dir__, File.basename(__FILE__, '.*'))
  end

  def get_test_case_file(filename)
    File.join(get_test_case_dir, filename)
  end

  def get_sketchup_test_case_file(filename)
    File.join(__dir__, "TC_Sketchup", filename)
  end

  class TestUpEvilEntityObserver < Sketchup::EntityObserver
    def onChangeEntity(entity)
      puts "#{self.class.name}.onChangeEntity(#{entity})"
      Sketchup.active_model.definitions.purge_unused
    end
  end # class

  class TestUpEvilDefinitionsObserver < Sketchup::DefinitionsObserver
    def onComponentAdded(definitions, definition)
      puts "#{self.class.name}.onComponentAdded(#{definition})"
      definitions.purge_unused
    end
  end # class


  # ========================================================================== #
  # method Sketchup::DefinitionList.add

  def test_add_evil_definitions_observer_without_operation
    model = Sketchup.active_model
    entities = model.entities

    observer = TestUpEvilDefinitionsObserver.new
    model.definitions.add_observer(observer)

    definition = model.definitions.add("TestUp")

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) do
      definition.name
    end
  ensure
    model.definitions.remove_observer(observer)
  end

  def test_add_enforce_unique_names
    model = Sketchup.active_model

    definition1 = model.definitions.add("TestUp")
    definition2 = model.definitions.add("TestUp")

    assert_kind_of(Sketchup::ComponentDefinition, definition1)
    assert_kind_of(Sketchup::ComponentDefinition, definition2)

    assert_equal("TestUp", definition1.name)
    assert_equal("TestUp#1", definition2.name)
  end


  # ========================================================================== #
  # method Sketchup::DefinitionList.load

  def test_load_newer_SU_version
    skip("Crashes version of SketchUp prior to 19") if Sketchup.version.to_i < 19
    model = Sketchup.active_model
    file = get_test_case_file("SU99.skp")
    assert_raises(RuntimeError) do
      model.definitions.load(file)
    end
    assert_equal(0, model.definitions.size)
  end

  def test_load_valid_file
    model = Sketchup.active_model
    file = get_test_case_file("face.skp")
    definition = model.definitions.load(file)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
  end

  def test_load_invalid_model
    model = Sketchup.active_model
    file = get_test_case_file("invalid.skp")
    assert_raises(IOError) do
      model.definitions.load(file)
    end
    assert_equal(0, model.definitions.size)
  end

  def test_load_empty_model
    model = Sketchup.active_model
    file = get_test_case_file("empty.skp")
    # TODO(thomthom): Failure handling indicate that RuntimeError should be
    #   raised here. But we're getting IOError instead because SU claims the
    #   model is invalid. Maybe something changed at some point before we had
    #   these tests. Investigate later when time isn't so pressing.
    assert_raises(IOError) do
      model.definitions.load(file)
    end
    assert_equal(0, model.definitions.size)
  end

  def test_load_model_with_only_screen_text
    model = Sketchup.active_model
    file = get_test_case_file("screentext.skp")
    assert_raises(RuntimeError) do
      model.definitions.load(file)
    end
    assert_equal(0, model.definitions.size)
  end
  
  def test_load_recursive_model
    file = get_test_case_file("face.skp")
    if Sketchup.version.to_i < 21
      Sketchup.open_file(file)
    else
      Sketchup.open_file(file, with_status: true)
    end

    model = Sketchup.active_model
    assert_raises(RuntimeError) do
      model.definitions.load(file)
    end
    assert_equal(0, model.definitions.size)
  ensure
    discard_model_changes
  end

  def test_load_model_too_many_arguments
    model = Sketchup.active_model
    file = get_test_case_file("face.skp")
    assert_raises(ArgumentError) do
      model.definitions.load(file, 123)
    end
    assert_equal(0, model.definitions.size)
  end

  def test_load_model_invalid_argument_filename_nil
    model = Sketchup.active_model
    file = get_test_case_file("face.skp")
    assert_raises(TypeError) do
      model.definitions.load(nil)
    end
    assert_equal(0, model.definitions.size)
  end

  def test_load_valid_file_soft_block
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    file = get_sketchup_test_case_file("skp-vff-soft-block.skp")
    assert_raises(RuntimeError) do
      model.definitions.load(file)
    end
    assert_equal(0, model.definitions.size)
  end

  def test_load_valid_file_allow_newer_soft_block
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    file = get_sketchup_test_case_file("skp-vff-soft-block.skp")
    definition = model.definitions.load(file, allow_newer: true)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
  end

  def test_load_valid_file_allow_newer_hard_block
    skip("Implemented in SU2021.0") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    file = get_sketchup_test_case_file("skp-vff-hard-block.skp")
    assert_raises(RuntimeError) do
      model.definitions.load(file, allow_newer: true)
    end
    assert_equal(0, model.definitions.size)
  end

  def test_load_same_path
    model = Sketchup.active_model
    path = get_test_case_file("face.skp")

    definition1 = model.definitions.load(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition1)
    
    definition2 = model.definitions.load(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition2)

    assert_equal(definition1, definition2)
  end

  def test_load_same_path_modified_component
    model = Sketchup.active_model
    path = get_test_case_file("face.skp")

    definition1 = model.definitions.load(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition1)

    # Make an arbitrary change so the component no longer matches the file.
    definition1.entities.add_cpoint(ORIGIN)
    
    definition2 = model.definitions.load(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition2)

    refute_equal(definition1, definition2);
  end

  def test_load_same_path_different_files
    skip("Fixed in SU2023.0") if Sketchup.version.to_f < 23.0

    model = Sketchup.active_model
    path1 = get_test_case_file("face.skp")
    path2 = get_test_case_file("other_face.skp")
    # Common path to load both files from
    path = temp_path = File.join(Sketchup.temp_dir, "Some random file name.skp")

    FileUtils.mv(path1, path)
    definition1 = model.definitions.load(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition1)
    FileUtils.mv(path, path1)

    FileUtils.mv(path2, path)
    definition2 = model.definitions.load(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition2)
    FileUtils.mv(path, path2)

    refute_equal(definition1, definition2);
  end

  # ========================================================================== #
  # method Sketchup::DefinitionList.import
  
  def test_import
    skip("Implemented in SU2021.1") if Sketchup.version.to_f < 21.1
    definitions = Sketchup.active_model.definitions
    
    path = get_test_case_file("import_files/circle.dwg")
    definition = definitions.import(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
    
    path = get_test_case_file("import_files/circle.dxf")
    definition = definitions.import(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
    
    path = get_test_case_file("import_files/circle.dae")
    definition = definitions.import(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
    
    path = get_test_case_file("import_files/circle.3ds")
    definition = definitions.import(path)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
  end

  def test_import_options
    skip("Implemented in SU2021.1") if Sketchup.version.to_f < 21.1
    definitions = Sketchup.active_model.definitions

    path = get_test_case_file("import_files/coplanar_faces.dae")

    definition = definitions.import(path, merge_coplanar_faces: false)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert_equal(4, definition.entities.grep(Sketchup::Face).size)

    definition = definitions.import(path, merge_coplanar_faces: true)
    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert_equal(1, definition.entities.grep(Sketchup::Face).size)
  end
  
  def test_import_missing
    skip("Implemented in SU2021.1") if Sketchup.version.to_f < 21.1
    definitions = Sketchup.active_model.definitions
    
    path = get_test_case_file("import_files/no such file.obj")
    assert_raises(IOError) do
      definitions.import(path)
    end
  end
  
  def test_import_invalid
    skip("Implemented in SU2021.1") if Sketchup.version.to_f < 21.1
    definitions = Sketchup.active_model.definitions
    
    path = get_test_case_file("import_files/circle.skp")
    assert_raises(ArgumentError) do
      definitions.import(path)
    end
    
    path = get_test_case_file("import_files/circle.jpg")
    assert_raises(ArgumentError) do
      definitions.import(path)
    end
    
    path = get_test_case_file("import_files/circle.txt")
    assert_raises(ArgumentError) do
      definitions.import(path)
    end
  end

  # ========================================================================== #
  # method Sketchup::DefinitionList.remove

  def test_remove
    model = Sketchup.active_model
    group = model.entities.add_group
    group.entities.add_line([0,0,0], [9,9,9])
    model.definitions.remove(group.definition)
    assert(group.deleted?)
    assert_equal(0, model.entities.size)
  end

  def test_remove_active_entities
    skip("Fixed in SU2023.0") if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    group = model.entities.add_group
    group.entities.add_line([0,0,0], [9,9,9])
    model.active_path = [group]
    assert_raises(ArgumentError) do
      model.definitions.remove(group.definition)
    end
    refute(group.deleted?)
  ensure
    model.active_path = nil if model
  end

end # class

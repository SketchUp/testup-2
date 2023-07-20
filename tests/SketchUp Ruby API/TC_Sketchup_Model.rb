# Copyright:: Copyright 2014-2020 Trimble Inc. All rights reserved.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"
require_relative "utils/feature_switch"

require "stringio"

# class Sketchup::Model
class TC_Sketchup_Model < TestUp::TestCase

  include TestUp::SketchUpTests::FeatureSwitchHelper

  def self.setup_testcase
    discard_all_models
  end

  def setup
    model = start_with_empty_model()
    model.rendering_options["DrawHiddenGeometry"] = false
    model.rendering_options["DrawHiddenObjects"] = false
    create_test_tube()
    Sketchup.active_model.select_tool(nil)
  end

  def teardown
    # Just to make sure no tests leave open Ruby transactions.
    Sketchup.active_model.commit_operation
  end

  def get_test_file(filename)
    File.join(__dir__, "TC_Sketchup_Model", filename)
  end

  def setup_with_jinyi_component
    start_with_empty_model
    import_file = get_test_file("jinyi.skp")
    status = Sketchup.active_model.import(import_file)
    assert_kind_of(TrueClass, status)
  end

  def add_extra_groups_and_components
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation("TestUp2 - Test Groups", true)
    10.times { |i|
      group = entities.add_group
      group.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    }
    definition = model.definitions.add("TestUp2")
    definition.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    10.times { |i|
      origin = ORIGIN.offset(X_AXIS, i * 10)
      tr = Geom::Transformation.new(origin)
      entities.add_instance(definition, tr)
    }
    model.commit_operation
    nil
  end

  def create_test_tube
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation("TestUp2 - Test Tube", true)
    group = entities.add_group
    circle = group.entities.add_circle(ORIGIN, Z_AXIS, 10, 8)
    circle[0].find_faces
    face = group.entities.grep(Sketchup::Face)[0]
    face.pushpull(-50)
    model.commit_operation
    nil
  end

  # @return [Sketchup::InstancePath]
  def create_nested_test_cubes
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation("TestUp2 - Test Cubes Nested", true)
    group1 = entities.add_group
    group2 = group1.entities.add_group
    group3 = group2.entities.add_group
    face = group3.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    face.pushpull(-9)
    model.commit_operation
    Sketchup::InstancePath.new([group1, group2, group3])
  end

  def get_model_entities
    model = Sketchup.active_model
    entities = []
    model.entities.each { |instance|
      entities << instance
      if instance.is_a?(Sketchup::Group)
        entities.concat(instance.entities.to_a)
      else
        entities.concat(instance.definition.entities.to_a)
      end
    }
    entities
  end

  def get_all_pid_entities
    model = Sketchup.active_model
    entities = Set.new
    # Entities & Definitions
    model.entities.each { |entity| entities << entity }
    model.definitions.each { |definition|
      entities << definition
      next if definition.image?
      definition.entities.each { |entity| entities << entity }
    }
    # Layers
    model.layers.each { |entity| entities << entity }
    # LayerFolders
    if model.layers.respond_to?(:each_folder)
      model.layers.each_folder { |entity| entities << entity }
    end
    # Materials
    model.materials.each { |entity| entities << entity }
    # Scenes
    model.pages.each { |entity| entities << entity }
    # Styles
    model.styles.each { |entity| entities << entity }
    entities.to_a
  end

  class TransactionObserver < Sketchup::ModelObserver
    attr_reader :log
    def initialize
      @log = []
    end
    def onTransactionStart(model)
      @log << "onTransactionStart"
    end
    def onTransactionCommit(model)
      @log << "onTransactionCommit"
    end
    def onTransactionUndo(model)
      @log << "onTransactionUndo"
    end
    def onTransactionAbort(model)
      @log << "onTransactionAbort"
    end
    def onTransactionEmpty(model)
      @log << "onTransactionEmpty"
    end
  end

  class ActivePathModelObserver < Sketchup::ModelObserver
    attr_reader :log
    def initialize
      @log = []
    end
    def onActivePathChanged(model)
      @log << "onActivePathChanged"
    end
  end

  class ActivePathInstanceObserver < Sketchup::InstanceObserver
    attr_reader :log
    def initialize
      @log = []
    end
    def onOpen(instance)
      @log << ["onOpen", instance]
    end
    def onClose(instance)
      @log << ["onClose", instance]
    end
  end


  # ========================================================================== #
  # Sketchup::Model type checks

  def test_type_check_singleton_class
    skip("Fixed in SU2019") if Sketchup.version.to_i < 19
    model = Sketchup.active_model
    model.singleton_class # This will break SU2017 and older.
    model.title # This will fail in older SU versions.
    assert_raises(ArgumentError) do
      # This will raise a TypeError if SU isn't doing a is_a? check on the
      # `model` reference.
      model.export('fake-model.fake.extension')
    end
    # This will raise a TypeError if SU isn't doing a is_a? check on the
    # `model` reference.
    result = model.import('fake-model.fake.extension')
    refute(result, "import without a supported importer should return false")
  end


  # ========================================================================== #
  # method Sketchup::Model.start_operation

  def test_start_operation_warn_new_nested_operation
    original_mode = Sketchup.debug_mode?
    skip("Implemented in SU2016") if Sketchup.version.to_i < 16
    Sketchup.debug_mode = true
    model = Sketchup.active_model
    model.start_operation("Hello")
    stderr = capture_stderr(VERBOSE_SOME) {
      model.start_operation("World")
    }
    expected_warning = %{warning: New operation ("World") started while an existing operation ("Hello") was still open}
    result = stderr.string
    assert(result.include?(expected_warning),
      "Expected warning: #{expected_warning}\nResult: #{result}")
  ensure
    Sketchup.debug_mode = original_mode
  end


  # ========================================================================== #
  # method Sketchup::Model.close

  def test_close_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    discard_model_changes()
    # API example starts here:
    Sketchup.file_new
    model = Sketchup.active_model
    model.close
  end

  def test_close_invalid_args
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    discard_model_changes()
    # The first boolean argument can really be anything since anything converts
    # to bool in Ruby. But test too many args
    Sketchup.file_new
    assert_raises(ArgumentError, "Too many arguments") do
      Sketchup.active_model.close(true, "")
    end
  end

  def test_close
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    discard_model_changes()
    m0 = Sketchup.active_model
    Sketchup.file_new
    m1 = Sketchup.active_model
    Sketchup.file_new
    m2 = Sketchup.active_model

    m2.close
    assert_equal(m1, Sketchup.active_model)
    m1.close
    assert_equal(m0, Sketchup.active_model)
  end

  def test_close_inactive_model
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    discard_model_changes()
    # Inapplicable to Windows since there is one document
    skip("Not relevant for Windows") if Sketchup.platform == :platform_win

    Sketchup.file_new
    m0 = Sketchup.active_model
    Sketchup.file_new
    m1 = Sketchup.active_model

    assert_raises(RuntimeError, "Closed inactive model") do
      m0.close
    end

    # Close them in proper order
    m1.close
    m0.close
  end

  # ========================================================================== #
  # method Sketchup::Model.find_entity_by_id

  def test_find_entity_by_id_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    # Init dummy variables to avoid raising errors.
    id1 = id2 = id3 = 0
    guid1 = guid2 = guid3 = ""

    model = Sketchup.active_model
    # Look up by entityID.
    entity_id = model.entities.add_line([0,0,0], [9,9,9]).entityID
    entity = model.find_entity_by_id(entity_id)
    # Look up by GUID.
    guid = model.entities.add_group.guid
    entity = model.find_entity_by_id(guid)
    # Look up multiple.
    entities = model.find_entity_by_id(id1, id2, id3)
    entities = model.find_entity_by_id([id1, id2, id3])
    entities = model.find_entity_by_id(guid1, guid2, guid3)
    entities = model.find_entity_by_id([guid1, guid2, guid3])
  end

  def test_find_entity_by_id_entity_id
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities[0]
    entity = group.entities[0]

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_array_single_item
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities[0]
    entity = group.entities[0]

    result = Sketchup.active_model.find_entity_by_id([entity.entityID])
    assert_equal([entity], result)
  end

  def test_find_entity_by_id_entity_id_array
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    add_extra_groups_and_components()

    entities = get_model_entities()
    ids = entities.map { |entity| entity.entityID }

    result = Sketchup.active_model.find_entity_by_id(ids)
    assert_equal(entities.size, result.size)
    assert_equal(entities, result)
  end

  def test_find_entity_by_id_guid
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities[0]

    add_extra_groups_and_components()

    result = Sketchup.active_model.find_entity_by_id(group.guid)
    assert_equal(group, result)
  end

  def test_find_entity_by_id_guids
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    add_extra_groups_and_components()

    entities = Sketchup.active_model.entities.to_a
    guids = entities.map { |instance| instance.guid }

    result = Sketchup.active_model.find_entity_by_id(guids)
    assert_equal(entities, result)
  end

  def test_find_entity_by_id_not_found
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    result = Sketchup.active_model.find_entity_by_id(-123)
    assert_equal(nil, result)
  end

  def test_find_entity_by_id_not_found_array
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    result = Sketchup.active_model.find_entity_by_id([-1, -2, -3])
    assert_equal([nil, nil, nil], result)
  end

  def test_find_entity_by_id_mixed_search_result_entity_id
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities[0]
    result = Sketchup.active_model.find_entity_by_id([-1, group.entityID, -3])
    assert_equal([nil, group, nil], result)
  end

  def test_find_entity_by_id_mixed_search_result_guid
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities[0]
    add_extra_groups_and_components()
    result = Sketchup.active_model.find_entity_by_id(["", group.guid, ""])
    assert_equal([nil, group, nil], result)
  end

  def test_find_entity_by_id_guid_multiple_identical
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    group = Sketchup.active_model.entities[0]

    add_extra_groups_and_components()

    guids = [group.guid] * 3
    expected = [group] * 3
    result = Sketchup.active_model.find_entity_by_id(guids)
    assert_equal(expected, result)
  end

  def test_find_entity_by_id_entity_id_edge
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_line([0,0,0], [9,9,9])

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_face
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_face([0,0,0], [9,0,0], [9,9,0])

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_group
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_group

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_component_instance
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    add_extra_groups_and_components()
    entity = Sketchup.active_model.entities.grep(Sketchup::ComponentInstance)[0]

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_image
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
    entity = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_cpoint
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_cpoint(ORIGIN)

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_cline
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_cline(ORIGIN, [9,0,0])

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_dimension_linear
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_dimension_linear(
      [50, 10, 0], [100, 10, 0], [0, 20, 0])

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_dimension_radial
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    centerpoint = Geom::Point3d.new(10, 10, 0)
    vector = Geom::Vector3d.new(0, 0, 1)
    edges = Sketchup.active_model.entities.add_circle(centerpoint, vector, 10)
    circle = edges[0].curve
    entity = Sketchup.active_model.entities.add_dimension_radial(
      circle, [30, 30, 0])

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_section_plane
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_section_plane(
      [50, 50, 0], [1.0, 1.0, 0])

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_text
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_text("This is a Test", ORIGIN)

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_vertex
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities.add_line([0,0,0], [9,9,9]).start

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_component_definition
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.entities[0].entities.parent

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_definition_list
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("DefinitionList objects not supported")
    entity = Sketchup.active_model.definitions

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_arc_curve
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    edges = Sketchup.active_model.entities.add_circle(ORIGIN, Z_AXIS, 1.m)
    entity = edges[0].curve

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_curve
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    edges = Sketchup.active_model.entities.add_curve([0,0,0], [0,9,0], [1,9,0])
    entity = edges[0].curve

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_layers
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Layers objects not supported")
    entity = Sketchup.active_model.layers

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_layer
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.active_layer

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_materials
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Materials objects not supported")
    entity = Sketchup.active_model.materials

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_material
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.materials.add("TestUp")

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_pages
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Pages objects not supported")
    entity = Sketchup.active_model.pages

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_page
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.pages.add("TestUp")
    entity = Sketchup.active_model.pages[0]

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_attribute_dictionaries
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("AttributeDictionaries objects not supported")
    Sketchup.active_model.set_attribute("TestUp", "Hello", "World")
    entity = Sketchup.active_model.attribute_dictionaries

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_attribute_dictionary
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("AttributeDictionary objects not supported")
    entity = Sketchup.active_model.attribute_dictionary("TestUp", true)

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_edgeuse
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("EdgeUse objects not supported")
    face = Sketchup.active_model.entities.add_face([0,0,0], [9,0,0], [9,9,0])
    entity = face.outer_loop.edgeuses[0]

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_loop
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Loop objects not supported")
    face = Sketchup.active_model.entities.add_face([0,0,0], [9,0,0], [9,9,0])
    entity = face.outer_loop

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_rendering_options
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("RenderingOptions objects not supported")
    entity = Sketchup.active_model.rendering_options

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_shadow_info
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("ShadowInfo objects not supported")
    entity = Sketchup.active_model.shadow_info

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_styles
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    skip("Styles objects not supported")
    entity = Sketchup.active_model.styles

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_style
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    entity = Sketchup.active_model.styles.selected_style

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_texture
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.entities.clear!
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
    image = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)
    image.explode
    face = Sketchup.active_model.entities.grep(Sketchup::Face)[0]
    entity = face.material.texture

    result = Sketchup.active_model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_invalid_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(TypeError, "Argument with nil") do
      Sketchup.active_model.find_entity_by_id(nil)
    end

    assert_raises(TypeError, "Argument with Point3d") do
      Sketchup.active_model.find_entity_by_id(ORIGIN)
    end
  end

  def test_find_entity_by_id_invalid_arguments_mixed_with_valid
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(TypeError, "Argument with nil") do
      Sketchup.active_model.find_entity_by_id(123, nil)
    end

    assert_raises(TypeError, "Argument with Point3d") do
      Sketchup.active_model.find_entity_by_id(123, ORIGIN)
    end
  end

  def test_find_entity_by_id_invalid_array_arguments_mixed_with_valid
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(TypeError, "Argument with nil") do
      Sketchup.active_model.find_entity_by_id([123, nil])
    end

    assert_raises(TypeError, "Argument with Point3d") do
      Sketchup.active_model.find_entity_by_id([123, ORIGIN])
    end
  end

  def test_find_entity_by_id_invalid_arguments_entity_id_with_guid
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(TypeError, "Array of EntityID with String") do
      Sketchup.active_model.find_entity_by_id(123, "FooBar")
    end
  end

  def test_find_entity_by_id_invalid_arguments_guid_with_entity_id
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(TypeError, "Array of GUID with EntityID") do
      Sketchup.active_model.find_entity_by_id("FooBar", 123)
    end
  end

  def test_find_entity_by_id_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError, "No arguments") do
      Sketchup.active_model.find_entity_by_id()
    end
  end

  def test_find_entity_by_id_invalid_empty_array_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError, "Empty array") do
      Sketchup.active_model.find_entity_by_id([])
    end
  end


  # ========================================================================== #
  # method Sketchup::Model.find_entity_by_persistent_id

  def test_find_entity_by_persistent_id_api_example
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    # Init dummy variables to avoid raising errors.
    id1 = id2 = id3 = 0
    # Example Start:

    # Look up by persistent_id.
    pid = model.entities.add_line([0,0,0], [9,9,9]).persistent_id
    entity = model.find_entity_by_persistent_id(pid)

    # Look up multiple.
    entities = model.find_entity_by_persistent_id(id1, id2, id3)
    entities = model.find_entity_by_persistent_id([id1, id2, id3])
  end

  def test_find_entity_by_persistent_id
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    group = Sketchup.active_model.entities[0]
    entity = group.entities[0]

    result = Sketchup.active_model.find_entity_by_persistent_id(
        entity.persistent_id)
    assert_equal(entity, result)
  end

  def test_find_entity_by_persistent_id_array_single_item
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    group = Sketchup.active_model.entities[0]
    entity = group.entities[0]

    result = Sketchup.active_model.find_entity_by_persistent_id(
        [entity.persistent_id])
    assert_equal([entity], result)
  end

  def test_find_entity_by_persistent_id_array
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    add_extra_groups_and_components()

    entities = get_model_entities()
    ids = entities.map { |entity| entity.persistent_id }

    result = Sketchup.active_model.find_entity_by_persistent_id(ids)
    assert_equal(entities.size, result.size)
    assert_equal(entities, result)
  end

  def test_find_entity_by_persistent_id_multiple_arguments
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    add_extra_groups_and_components()

    entities = get_model_entities()
    ids = entities.map { |entity| entity.persistent_id }

    result = Sketchup.active_model.find_entity_by_persistent_id(*ids)
    assert_equal(entities.size, result.size)
    assert_equal(entities, result)
  end

  def test_find_entity_by_persistent_id_scope_to_entities
    skip("Added in SU2020.2") if Sketchup.version.to_f < 20.2
    add_extra_groups_and_components()

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }
    
    model = Sketchup.active_model
    definition_entities = model.entities.to_a
    model.definitions.each { |definition|
      next if definition.image?
      definition_entities.concat(definition.entities.to_a)
    }
    expected = entities.map { |entity|
      parent = entity.parent
      parent.is_a?(Sketchup::ComponentDefinition) || parent.is_a?(Sketchup::Model) ? entity : nil
    }

    result = Sketchup.active_model.find_entity_by_persistent_id(ids, entities: true)
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end

  def test_find_entity_by_persistent_id_scope_to_layers
    skip("Added in SU2020.2") if Sketchup.version.to_f < 20.2
    model = Sketchup.active_model
    5.times { |i| model.layers.add("TestUp #{i}") }

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }

    expected = entities.map { |entity|
      entity.is_a?(Sketchup::Layer) ? entity : nil
    }
    refute(expected.empty?)

    result = Sketchup.active_model.find_entity_by_persistent_id(ids, layers: true)
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end

  def test_find_entity_by_persistent_id_scope_to_layer_folders
    skip("Added in SU2021.0") if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    5.times { |i| model.layers.add_folder("TestUp #{i}") }

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }

    expected = entities.map { |entity|
      entity.is_a?(Sketchup::LayerFolder) ? entity : nil
    }
    refute(expected.empty?)

    result = Sketchup.active_model.find_entity_by_persistent_id(ids, layer_folders: true)
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end

  def test_find_entity_by_persistent_id_scope_to_materials
    skip("Added in SU2020.2") if Sketchup.version.to_f < 20.2
    model = Sketchup.active_model
    5.times { |i| model.materials.add("TestUp #{i}") }

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }

    expected = entities.map { |entity|
      entity.is_a?(Sketchup::Material) ? entity : nil
    }
    refute(expected.empty?)

    result = Sketchup.active_model.find_entity_by_persistent_id(ids, materials: true)
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end

  def test_find_entity_by_persistent_id_scope_to_pages
    skip("Added in SU2020.2") if Sketchup.version.to_f < 20.2
    model = Sketchup.active_model
    5.times { |i| model.pages.add("TestUp #{i}") }

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }

    expected = entities.map { |entity|
      entity.is_a?(Sketchup::Page) ? entity : nil
    }
    refute(expected.empty?)

    result = Sketchup.active_model.find_entity_by_persistent_id(ids, pages: true)
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end

  def test_find_entity_by_persistent_id_scope_to_styles
    skip("Added in SU2020.2") if Sketchup.version.to_f < 20.2
    model = Sketchup.active_model

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }

    expected = entities.map { |entity|
      entity.is_a?(Sketchup::Style) ? entity : nil
    }
    refute(expected.empty?)

    result = Sketchup.active_model.find_entity_by_persistent_id(ids, styles: true)
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end

  def test_find_entity_by_persistent_id_scope_to_definitions
    skip("Added in SU2020.2") if Sketchup.version.to_f < 20.2
    add_extra_groups_and_components()

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }

    expected = entities.map { |entity|
      entity.is_a?(Sketchup::ComponentDefinition) ? entity : nil
    }
    refute(expected.empty?)

    result = Sketchup.active_model.find_entity_by_persistent_id(ids, definitions: true)
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end

  def test_find_entity_by_persistent_id_scope_to_materials_and_pages
    skip("Added in SU2020.2") if Sketchup.version.to_f < 20.2
    # Simple test to ensure multiple scopes are concatenated.
    model = Sketchup.active_model
    5.times { |i| model.materials.add("TestUp #{i}") }
    5.times { |i| model.pages.add("TestUp #{i}") }

    entities = get_all_pid_entities()
    ids = entities.map { |entity| entity.persistent_id }

    expected = entities.map { |entity|
      entity.is_a?(Sketchup::Material) || entity.is_a?(Sketchup::Page) ? entity : nil
    }
    refute(expected.empty?)

    result = Sketchup.active_model.find_entity_by_persistent_id(ids,
      materials: true,
      pages: true,
    )
    assert_equal(expected.size, result.size)
    assert_equal(expected, result)
  end


  # ========================================================================== #
  # method Sketchup::Model.instance_path_from_pid_path

  def test_instance_path_from_pid_path_api_example
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    points = [
      Geom::Point3d.new( 0,  0, 0),
      Geom::Point3d.new(10,  0, 0),
      Geom::Point3d.new(10, 20, 0),
      Geom::Point3d.new( 0, 20, 0)
    ]
    model = Sketchup.active_model
    entities = model.active_entities
    group = entities.add_group
    face = group.entities.add_face(points)
    pid_path = "#{group.persistent_id}.#{face.persistent_id}"
    # pid_path will look something like this: "658.723"
    instance_path = model.instance_path_from_pid_path(pid_path)
  end

  def test_instance_path_from_pid_path
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    points = [
      Geom::Point3d.new( 0,  0, 0),
      Geom::Point3d.new(10,  0, 0),
      Geom::Point3d.new(10, 20, 0),
      Geom::Point3d.new( 0, 20, 0)
    ]
    model = Sketchup.active_model
    entities = model.active_entities
    group = entities.add_group
    face = group.entities.add_face(points)
    pid_path = "#{group.persistent_id}.#{face.persistent_id}"

    result = model.instance_path_from_pid_path(pid_path)
    assert_kind_of(Sketchup::InstancePath, result)
    assert_equal([group, face], result.to_a)
  end

  def test_instance_path_from_pid_path_invalid_path_invalid_ids
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    assert_raises(ArgumentError) {
      instance_path = model.instance_path_from_pid_path(-1, -2)
    }
  end

  def test_instance_path_from_pid_path_invalid_path
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    assert_raises(ArgumentError) {
      instance_path = model.instance_path_from_pid_path(999998, 999999)
    }
  end

  def test_instance_path_from_pid_path_incorrect_number_of_arguments_zero
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    assert_raises(ArgumentError) {
      instance_path = model.instance_path_from_pid_path
    }
  end

  def test_instance_path_from_pid_path_invalid_argument_nil
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    assert_raises(TypeError) {
      instance_path = model.instance_path_from_pid_path(nil)
    }
  end

  def test_instance_path_from_pid_path_invalid_argument_string
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    assert_raises(ArgumentError) {
      instance_path = model.instance_path_from_pid_path("hello")
    }
  end

  def test_instance_path_from_pid_path_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    assert_raises(ArgumentError) {
      instance_path = model.instance_path_from_pid_path(1, 2)
    }
  end


  # Class to use for tool tests
  class MyTool; end

  def test_select_tool
    mytool = MyTool.new
    Sketchup.active_model.select_tool(mytool)
    assert_operator(Sketchup.active_model.tools.active_tool_id, :>, 50000,
        "Tool ID was invalid")
  end

  def test_select_tool_default
    Sketchup.active_model.select_tool(nil)
    # This magic number is the resource ID for the select tool (ID_DRAW_SELECT)
    assert_equal(21022, Sketchup.active_model.tools.active_tool_id,
        "Tool stack was not cleared")
  end

  def test_select_tool_clear
    mytool = MyTool.new
    Sketchup.active_model.select_tool mytool
    Sketchup.active_model.select_tool(nil)
    assert_equal(21022, Sketchup.active_model.tools.active_tool_id,
        "Tool stack was not cleared")
  end


  def test_select_tool_diff_tools
    mytool = MyTool.new
    Sketchup.active_model.select_tool mytool
    mytool_id = Sketchup.active_model.tools.active_tool_id

    # Add second tool instance and confirm the tool ID is different
    mytool2 = MyTool.new
    Sketchup.active_model.select_tool mytool2
    refute_equal(Sketchup.active_model.tools.active_tool_id, mytool_id,
        "Tool ID did not change")
  end

  def test_select_tool_same_tool_2x
    mytool = MyTool.new
    Sketchup.active_model.select_tool mytool
    mytool_id = Sketchup.active_model.tools.active_tool_id

    # Clear the tool stack
    Sketchup.active_model.select_tool nil

    # Re-add the same tool and confirm the tool ID is different
    Sketchup.active_model.select_tool mytool
    refute_equal(Sketchup.active_model.tools.active_tool_id, mytool_id,
        "Tool ID did not change")
  end

  def test_import_legacy_parameters
    start_with_empty_model
    dae_file = get_test_file("jinyi.dae")
    status = Sketchup.active_model.import(dae_file, false)
    assert_kind_of(TrueClass, status)
    definition_list = Sketchup.active_model.definitions
    assert_equal(3, definition_list.count)
    assert_equal(622, definition_list.at(0).entities.count)
  end

  def test_import_dae_options
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.dae")
    options = { :validate_dae => true,
                :merge_coplanar_faces => true,
                :show_summary => false}
    status = Sketchup.active_model.import(import_file, options)
    assert_kind_of(TrueClass, status)
    definition_list = Sketchup.active_model.definitions
    assert_equal(3, definition_list.count)
    assert_equal(622, definition_list.at(0).entities.count)
  end

  def test_import_3ds_options
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.3ds")
    options = { :merge_coplanar_faces => true,
                :units => "mile",
                :show_summary => false}
    status = Sketchup.active_model.import(import_file, options)
    assert_kind_of(TrueClass, status)
    definitions = Sketchup.active_model.definitions
    assert_equal(5, definitions.size)
    if Sketchup.version.to_i == 18
      assert_equal(826, definitions['Mesh01'].entities.size)
      assert_equal(42, definitions['Mesh02'].entities.size)
    else
      # SketchUp 2019+
      assert_equal(683, definitions['Mesh01'].entities.size)
      assert_equal(38, definitions['Mesh02'].entities.size)
    end
  end

  def test_import_dwg_options
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.dwg")
    options = { :merge_coplanar_faces => true,
                :orient_faces => true,
                :preserve_origin => true,
                :show_summary => false}
    status = Sketchup.active_model.import(import_file, options)
    assert_kind_of(TrueClass, status)
    definitions = Sketchup.active_model.definitions
    if Sketchup.version.to_i == 18
      assert_equal(1, definitions['jinyi.dwg'].entities.size)
      assert_equal(264, definitions['Component_1'].entities.size)
    elsif Sketchup.version.to_i <= 21
      # SketchUp 2019-2021
      assert_equal(1, definitions['jinyi.dwg'].entities.size)
      assert_equal(169, definitions['Component_1'].entities.size)
    else
      # SketchUp 2022+
      assert_equal(1, definitions['jinyi.dwg'].entities.size)
      assert_equal(170, definitions['Component_1'].entities.size)
    end
  end

  def test_import_dwg_material_options
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    import_file = get_test_file("material_texture_import.dwg")
    options = { :import_materials => true,
                :merge_coplanar_faces => true,
                :orient_faces => true,
                :preserve_origin => true,
                :show_summary => false }
    status = Sketchup.active_model.import(import_file, options)
    assert_equal(true, status)
    materials = Sketchup.active_model.materials
    test_material_name = materials[0].name
    assert_equal(2, materials.size)
    assert_equal("test_material", test_material_name)
  end

  def test_import_dxf_options
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.dxf")
    options = { :merge_coplanar_faces => false,
                :orient_faces => true,
                :preserve_origin => true,
                :show_summary => false}
    status = Sketchup.active_model.import(import_file, options)
    assert_kind_of(TrueClass, status)
    definition_list = Sketchup.active_model.definitions
    assert_equal(2, definition_list.size)
    assert_equal(264, definition_list.at(0).entities.size)
  end

  def test_import_ifc_options
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.ifc")
    status = Sketchup.active_model.import(import_file, false)
    assert_kind_of(TrueClass, status)
    definition_list = Sketchup.active_model.definitions
    if Sketchup.version.to_f >= 23.0
      assert_equal(7, definition_list.size)
      assert_equal(250, definition_list['Component'].entities.size)
    else
      assert_equal(6, definition_list.size)
      assert_equal(824, definition_list.at(0).entities.size)
    end
  end

  def test_import_kmz_options
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.kmz")
    options = { :validate_kmz => true,
                :merge_coplanar_faces => true,
                :show_summary => false}
    status = Sketchup.active_model.import(import_file, options)
    assert_kind_of(TrueClass, status)
    definition_list = Sketchup.active_model.definitions
    assert_equal(2, definition_list.count)
    assert_equal(299, definition_list.at(0).entities.count)
  end

  def test_import_stl_options
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.stl")
    options = { :units => "inch",
                :merge_coplanar_faces => false,
                :preserve_origin => true,
                :swap_yz => true}
    status = Sketchup.active_model.import(import_file, options)
    assert_kind_of(TrueClass, status)
    definition_list = Sketchup.active_model.definitions
    assert_equal(1, definition_list.count)
    assert_equal(820, definition_list.at(0).entities.count)
  end

  # ========================================================================== #
  # method Sketchup::Model.export

  def test_export_3ds_otions
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.3ds"

    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component
    options = { :units => "m",
                :geometry => "by_material",
                :doubledsided_faces => true,
                :faces => "not_two_sided",
                :edges => true,
                :texture_maps => true,
                :preserve_texture_coords => true,
                :cameras => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_dae_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.dae"

    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component
    options = { :triangulated_faces => true,
                :doublesided_faces => true,
                :edges => true,
                :author_attribution => true,
                :hidden_geomtry => true,
                :preserve_instancing => true,
                :texture_maps => true,
                :selectionset_only => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_dwg_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.dwg"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :acad_version => "acad_2013",
                :faces_flag => true,
                :construction_geometry => true,
                :dimensions => true,
                :text => true,
                :edges => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_dxf_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.dxf"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :acad_version => "acad_2013",
                :faces_flag => true,
                :construction_geometry => true,
                :dimensions => true,
                :text => true,
                :edges => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_fbx_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.fbx"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :units => "mile",
                :triangulated_faces => true,
                :doublesided_faces => true,
                :texture_maps => true,
                :separate_disconnected_faces => true,
                :swap_yz => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_ifc_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.ifc"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :hidden_geometry => true,
                :doublesided_faces => true,
                :ifc_mapped_items => true,
                :ifc_types => [
                  "IfcBeam",
                  "IfcBuilding",
                  "IfcBuildingElementProxy",
                  "IfcBuildingStorey",
                  "IfcColumn",
                  "IfcCurtainWall",
                  "IfcDoor",
                  "IfcFooting",
                  "IfcFurnishingElement",
                  "IfcMember",
                  "IfcPile",
                  "IfcPlate",
                  "IfcProject",
                  "IfcRailing",
                  "IfcRamp",
                  "IfcRampFlight",
                  "IfcRoof",
                  "IfcSite",
                  "IfcSlab",
                  "IfcSpace",
                  "IfcStair",
                  "IfcStairFlight",
                  "IfcWall",
                  "IfcWallStandardCase",
                  "IfcWindow"],
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_kmz_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.kmz"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :author_attribution => true,
                :hidden_geometry => true,
                :show_summary => true}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_obj_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.obj"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :units => "model",
                :triangulated_faces => true,
                :doublesided_faces => true,
                :edges => true,
                :texture_maps => true,
                :swap_yz => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_xsi_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.xsi"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :units => "model",
                :triangulated_faces => true,
                :doublesided_faces => true,
                :edges => true,
                :texture_maps => true,
                :swap_yz => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_wrl_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.wrl"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :doublesided_faces => true,
                :cameras => true,
                :use_vrml_orientation => true,
                :edges => true,
                :texture_maps => true,
                :allow_mirrored_componenets => true,
                :material_overrides => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_stl_options
    temp_dir = Sketchup.temp_dir
    export_file = temp_dir + "/" + "jinyi.stl"
    skip("Implemented in SU2018") if Sketchup.version.to_i < 18
    setup_with_jinyi_component

    options = { :units => "model",
                :format => "ascii",
                :selectionset_only => true,
                :swap_yz => true,
                :show_summary => false}
    status = Sketchup.active_model.export(export_file, options)
    assert_kind_of(TrueClass, status)
    file_size = File.stat(export_file).size
    assert(File.exist?(export_file) && file_size > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_line_styles
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    line_styles = Sketchup.active_model.line_styles
    assert_kind_of(Sketchup::LineStyles, line_styles)
  end

  def test_line_styles_object_id
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_equal(Sketchup.active_model.line_styles.object_id,
        Sketchup.active_model.line_styles.object_id)
  end

  def test_line_styles_too_many_arguments
    skip("Implemented in SU2019") if Sketchup.version.to_i < 19
    assert_raises(ArgumentError) do
      Sketchup.active_model.line_styles(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Model.active_path=

  def test_active_path_Set_nested_instances_instance_path
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    observer = TransactionObserver.new
    model.add_observer(observer)

    model.active_path = instance_path

    assert_equal(instance_path.to_a, model.active_path)
    assert_equal(2, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_nested_instances_instance_path_with_face_leaf
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    expected_path = instance_path.to_a
    face = instance_path.to_a.last.entities.grep(Sketchup::Face).first
    instance_path = Sketchup::InstancePath.new(instance_path.to_a << face)

    observer = TransactionObserver.new
    model.add_observer(observer)

    model.active_path = instance_path

    assert_equal(expected_path, model.active_path)
    assert_equal(2, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_nested_instances_instance_path_array
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    observer = TransactionObserver.new
    model.add_observer(observer)

    model.active_path = instance_path.to_a

    assert_equal(instance_path.to_a, model.active_path)
    assert_equal(2, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_injected_operation
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    observer = TransactionObserver.new
    model.add_observer(observer)

    model.start_operation("Cube", true)
    entities = model.active_entities
    group = entities.add_group
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(1.m, 0, 0),
      Geom::Point3d.new(1.m, 1.m, 0),
      Geom::Point3d.new(0, 1.m, 0),
    ]
    face = group.entities.add_face(points)

    path = [group]
    instance_path = Sketchup::InstancePath.new(path)
    model.active_path = instance_path

    face.pushpull(-1.m)

    model.commit_operation

    assert_equal(path, model.active_path)
    assert_equal(6, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
      onTransactionStart
      onTransactionCommit
      onTransactionStart
      onTransactionCommit
    ]
    assert_equal(expected, observer.log)
    # assert(observer.log[0] =~ /onTransactionStart/).size)
    # assert(observer.log[1] =~ /onTransactionCommit/).size)
    # assert(observer.log[2] =~ /onTransactionStart/).size)
    # assert(observer.log[3] =~ /onTransactionCommit/).size)
    # assert(observer.log[4] =~ /onTransactionStart/).size)
    # assert(observer.log[5] =~ /onTransactionCommit/).size)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_single_operation
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    observer = TransactionObserver.new
    model.add_observer(observer)
    group = model.entities.grep(Sketchup::Group).first
    path = [group]
    instance_path = Sketchup::InstancePath.new(path)

    model.start_operation("Open Group", true)
    model.active_path = instance_path
    model.commit_operation

    assert_equal(path, model.active_path)
    assert_equal(4, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
      onTransactionStart
      onTransactionEmpty
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_no_operation
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    observer = TransactionObserver.new
    model.add_observer(observer)
    group = model.entities.grep(Sketchup::Group).first
    path = [group]
    instance_path = Sketchup::InstancePath.new(path)

    model.active_path = instance_path

    assert_equal(path, model.active_path)
    assert_equal(2, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_already_open
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    group = model.entities.grep(Sketchup::Group).first
    path = [group]
    instance_path1 = Sketchup::InstancePath.new(path)

    instance_path2 = create_nested_test_cubes
    model.active_path = instance_path2
    observer = TransactionObserver.new
    model.add_observer(observer)

    model.active_path = instance_path1
    assert_equal(instance_path1.to_a, model.active_path)

    assert_equal(2, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_nil_closing_multiple
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    model.active_path = instance_path
    observer = TransactionObserver.new
    model.add_observer(observer)

    model.active_path = nil
    assert_nil(model.active_path)

    assert_equal(2, observer.log.size)
    expected = %w[
      onTransactionStart
      onTransactionCommit
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_empty_instance_path_array
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    group = model.entities.grep(Sketchup::Group).first
    path = [group]
    instance_path = Sketchup::InstancePath.new(path)
    model.active_path = instance_path

    model.active_path = []
    assert_nil(model.active_path)
  end

  def test_active_path_Set_invalid_arguments_integer
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    assert_raises(TypeError) do
      Sketchup.active_model.active_path = 123
    end
    assert_nil(Sketchup.active_model.active_path)
  end

  def test_active_path_Set_invalid_arguments_string
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    assert_raises(TypeError) do
      Sketchup.active_model.active_path = "not a path"
    end
    assert_nil(Sketchup.active_model.active_path)
  end

  def test_active_path_Set_invalid_arguments_erased_entity
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    group = model.entities.grep(Sketchup::Group).first
    path = [group]
    instance_path = Sketchup::InstancePath.new(path)
    group.erase!

    assert_raises(TypeError) do
      model.active_path = instance_path
    end
    assert_nil(model.active_path)
  end

  def test_active_path_Set_locked_instances_in_path
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    instance_path[1].locked = true

    assert_raises(ArgumentError) do
      model.active_path = instance_path
    end
    assert_nil(model.active_path)
  end

  def test_active_path_Set_locked_sibling_instances
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    definition = instance_path[1].definition
    sibling = model.entities.add_instance(definition, IDENTITY)
    sibling.locked = true

    assert_raises(ArgumentError) do
      model.active_path = instance_path
    end
    assert_nil(model.active_path)
  end

  def test_active_path_Set_invalid_instance_path
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    invalid_path = [instance_path[0]] * 3

    assert_raises(ArgumentError) do
      model.active_path = invalid_path
    end
    assert_nil(model.active_path)
  end

  def test_active_path_Set_trigger_model_observer_open
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    observer = ActivePathModelObserver.new
    model.add_observer(observer)

    model.active_path = instance_path
    assert_equal(instance_path.to_a, model.active_path)

    assert_equal(1, observer.log.size)
    expected = %w[
      onActivePathChanged
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_trigger_model_observer_close
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    model.active_path = instance_path
    observer = ActivePathModelObserver.new
    model.add_observer(observer)

    model.active_path = nil
    assert_nil(model.active_path)

    assert_equal(1, observer.log.size)
    expected = %w[
      onActivePathChanged
    ]
    assert_equal(expected, observer.log)
  ensure
    model.remove_observer(observer)
  end

  def test_active_path_Set_trigger_instance_observer_open
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    instance = instance_path[1]
    observer = ActivePathInstanceObserver.new
    instance.add_observer(observer)

    model.active_path = instance_path
    assert_equal(instance_path.to_a, model.active_path)

    assert_equal(1, observer.log.size)
    expected = [
      ['onOpen', instance]
    ]
    assert_equal(expected, observer.log)
  ensure
    instance.remove_observer(observer)
  end

  def test_active_path_Set_trigger_instance_observer_close
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    instance_path = create_nested_test_cubes
    model.active_path = instance_path
    instance = instance_path[1]
    observer = ActivePathInstanceObserver.new
    instance.add_observer(observer)

    model.active_path = nil

    assert_equal(1, observer.log.size)
    expected = [
      ['onClose', instance]
    ]
    assert_equal(expected, observer.log)
  ensure
    instance.remove_observer(observer)
  end

  def test_active_path_Set_live_component
    skip("Changed in SU2021") if Sketchup.version.to_i < 21
    model = Sketchup.active_model
    path = get_test_file("2021_lc.skp")
    model.definitions.load(path)
    definition = model.definitions["Exterior Sliding Door"]
    instance = model.entities.add_instance(definition, IDENTITY)
    instance_path = [instance]

    assert_raises(ArgumentError) do
      model.active_path = instance_path
    end
  end


  # ========================================================================== #
  # method Sketchup::Model.drawing_element_visible?

  # Obtains an instance path to the "top" face from the geometry generated by
  # create_test_tube.
  #
  # return [Skeetchup::InstancePath]
  def get_cube_instance_path
    model = Sketchup.active_model
    instance = model.entities.first
    face = instance.definition.entities.grep(Sketchup::Face).find { |face|
      face.normal.samedirection?(Z_AXIS)
    }
    # Need to assign the entities to another layer since it's not possible to
    # hide the only layer in the model.
    layer = model.layers.add("TestUp")
    instance.layer = layer
    face.layer = layer
    Sketchup::InstancePath.new([instance, face])
  end

  def test_drawing_element_visible_Query_visible
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    path = get_cube_instance_path
    assert(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_face_hidden
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    path = get_cube_instance_path
    path.leaf.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_face_hidden_with_hidden_geometry
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenGeometry"] = true
    path = get_cube_instance_path
    path.leaf.visible = false
    assert(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_face_layer_hidden
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    path = get_cube_instance_path
    path.leaf.layer.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_face_layer_hidden_with_hidden_geometry
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenGeometry"] = true
    path = get_cube_instance_path
    path.leaf.layer.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_hidden
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    path = get_cube_instance_path
    path.root.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_hidden_with_hidden_geometry
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenGeometry"] = true
    path = get_cube_instance_path
    path.root.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_hidden_with_hidden_objects
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenObjects"] = true
    path = get_cube_instance_path
    path.root.visible = false
    assert(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_layer_hidden
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    path = get_cube_instance_path
    path.root.layer.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_layer_hidden_with_hidden_geometry
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenGeometry"] = true
    path = get_cube_instance_path
    path.root.layer.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_layer_hidden_with_hidden_objects
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenObjects"] = true
    path = get_cube_instance_path
    path.root.layer.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_and_face_hidden
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    path = get_cube_instance_path
    path.leaf.visible = false
    path.root.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_and_face_hidden_draw_hidden_geometry
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenGeometry"] = true
    path = get_cube_instance_path
    path.leaf.visible = false
    path.root.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_and_face_hidden_draw_hidden_objects
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenObjects"] = true
    path = get_cube_instance_path
    path.leaf.visible = false
    path.root.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_and_face_hidden_draw_hidden
    skip("Implemented in SU2020") if Sketchup.version.to_i < 20
    model = Sketchup.active_model
    model.rendering_options["DrawHiddenGeometry"] = true
    model.rendering_options["DrawHiddenObjects"] = true
    path = get_cube_instance_path
    path.leaf.visible = false
    path.root.visible = false
    assert(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_folder_hidden
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    path = get_cube_instance_path
    folder1 = model.layers.add_folder('Hello')
    folder2 = folder1.add_folder('World')
    path.root.layer.folder = folder2
    assert(model.drawing_element_visible?(path))
    folder1.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_instance_folder_with_hidden_objects
    skip("Added in 2021.0") if Sketchup.version.to_f < 21.0
    model = Sketchup.active_model
    path = get_cube_instance_path
    folder1 = model.layers.add_folder('Hello')
    folder2 = folder1.add_folder('World')
    path.root.layer.folder = folder2
    path.root.visible = false
    refute(model.drawing_element_visible?(path))
  end

  def test_drawing_element_visible_Query_invalid_arguments_array_invalid_leaf
    skip("Crashes SU before 2021.1") if Sketchup.version.to_f < 21.1
    model = Sketchup.active_model
    layer = model.layers.first

    assert_raises(ArgumentError) do
      model.drawing_element_visible?([layer])
    end
  end

  def test_drawing_element_visible_Query_invalid_arguments_instancepath_invalid_leaf
    skip("Crashes SU before 2021.1") if Sketchup.version.to_f < 21.1
    model = Sketchup.active_model
    layer = model.layers.first

    assert_raises(ArgumentError) do
      model.drawing_element_visible?(Sketchup::InstancePath.new([layer]))
    end
  end

  def test_drawing_element_visible_Query_invalid_arguments_array_non_leaf
    model = Sketchup.active_model
    layer = model.layers.first
    drawingelement = model.entities.add_cpoint(ORIGIN)

    assert_raises(ArgumentError) do
      model.drawing_element_visible?([layer, drawingelement])
    end
  end

  def test_drawing_element_visible_Query_invalid_arguments_instancepath_non_leaf
    model = Sketchup.active_model
    layer = model.layers.first
    drawingelement = model.entities.add_cpoint(ORIGIN)

    assert_raises(ArgumentError) do
      model.drawing_element_visible?(Sketchup::InstancePath.new([layer, drawingelement]))
    end
  end


  # ========================================================================== #
  # method Sketchup::Model.active_layer

  def test_active_layer
    model = Sketchup.active_model
    layer0 = model.layers[0]

    assert_equal(layer0, model.active_layer) # default

    layer1 = model.layers.add('Hello')
    model.active_layer = layer1
    assert_equal(layer1, model.active_layer)
  end

  def test_active_layer_too_many_arguments
    model = Sketchup.active_model
    assert_raises(ArgumentError) do
      model.active_layer(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Model.active_layer=

  def test_active_layer_Set
    model = Sketchup.active_model
    layer0 = model.layers[0]

    assert_equal(layer0, model.active_layer) # default
    edge1 = model.entities.add_line([0, 0, 0], [9, 0, 0])
    assert_equal(layer0, edge1.layer)

    layer1 = model.layers.add('Hello')
    model.active_layer = layer1
    assert_equal(layer1, model.active_layer)

    edge2 = model.entities.add_line([0, 0, 9], [9, 0, 9])
    assert_equal(layer1, edge2.layer)
  end

  def test_active_layer_Set_string
    model = Sketchup.active_model
    layer = model.layers.add('Hello')

    model.active_layer = 'Hello'
    assert_equal(layer, model.active_layer)
  end

  def test_active_layer_Set_nil
    model = Sketchup.active_model
    layer = model.layers.add('Hello')
    model.active_layer = layer
    assert_equal(layer, model.active_layer)

    model.active_layer = nil
    assert_equal(model.layers[0], model.active_layer)
  end

  def test_active_layer_Set_invalid_argument_number
    assert_raises(ArgumentError) do
      Sketchup.active_model.active_layer = 123
    end
  end

  def test_create_attribute_dictionary_with_reserved_name
    discard_model_changes
    assert_raises(ArgumentError) do
      Sketchup.active_model.attribute_dictionary('GSU_ContributorsInfo', true)
    end
  end

  def test_read_attribute_dictionary_with_reserved_name
    dic = Sketchup.active_model.attribute_dictionary('SU_DefinitionSet')
  end

  # We post-poned this to SU2021.
  # def test_active_layer_Set_deprecated
  #   skip("Added in 2020.2") if Sketchup.version.to_f < 20.2
  #   model = Sketchup.active_model
  #   layer1 = model.layers.add('Hello')

  #   assert_raises(NotImplementedError) do
  #     model.active_layer = layer1
  #   end
  # end


  # ========================================================================== #
  # method Sketchup::Model.overlays

  def test_overlays
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_kind_of(Sketchup::OverlaysManager, overlays)
  end

  def test_overlays_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    model = Sketchup.active_model
    assert_raises(ArgumentError) do
      Sketchup.active_model.overlays(123)
    end
  end

end # class

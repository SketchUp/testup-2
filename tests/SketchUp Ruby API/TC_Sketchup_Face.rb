# Copyright:: Copyright 2014-2021 Trimble Inc Ltd.
# License:: The MIT License (MIT)
# Original Author:: Chris Fullmer

require "testup/testcase"
require_relative "utils/image_helper"

# class Sketchup::Face
class TC_Sketchup_Face < TestUp::TestCase

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


  # ========================================================================== #
  # Local test utilities.
  # If any of these utilities are needed in other test cases they should be
  # moved to TestUp's utility library.

  def get_test_case_file(filename)
    File.join(__dir__, File.basename(__FILE__, '.*'), filename)
  end

  def open_test_model(filename)
    test_model = get_test_case_file(filename)
    close_active_model
    if Sketchup.version.to_i < 21
      Sketchup.open_file(test_model)
    else
      Sketchup.open_file(test_model, with_status: true)
    end
    Sketchup.active_model
  end

  def create_face
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0, 0, 0], [100, 0, 0], [100, 100, 0], [0, 100, 0])
    face.reverse!
    face
  end

  def create_test_material(filename)
    path = get_test_case_file(filename)
    material = Sketchup.active_model.materials.add("Test Material")
    material.texture = path
    material
  end

  def create_face_with_glued_instance
    face = create_face
    component = Sketchup.active_model.definitions.add("tester")
    point1 = [10, 10, 0]
    point2 = [20, 10, 0]
    point3 = [20, 20, 0]
    point4 = [10, 20, 0]
    inner_face = component.entities.add_face(point1, point2, point3, point4)
    component.behavior.is2d = true
    inner_face.pushpull(-20, true)
    instance = Sketchup.active_model.active_entities.add_instance(
      component, Geom::Transformation.new)
    instance.glued_to = face
    [face, instance]
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

  def create_face_with_hole
    p1, p2, p3, p4 = [-1000, -1000, 0], [1000, -1000, 0], [1000, 1000,0],
      [-1000, 1000, 0]
    face1 = Sketchup.active_model.active_entities.add_face(p1, p2, p3, p4)
    face2 = create_face
    face1
  end

  # ========================================================================== #
  # method Sketchup::Face.all_connected

  def test_all_connected_api_example
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
    connected = face.all_connected
  end

  def test_all_connected_return_type
    face = create_face
    connected = face.all_connected
    assert_kind_of(Array, connected)
  end

  def test_all_connected_return_length
    face = create_face
    connected = face.all_connected
    assert_equal(5, connected.size)
  end

  def test_all_connected_return_faces_length
    face = create_face
    connected = face.all_connected
    faces = connected.grep(Sketchup::Face)
    assert_equal(1, faces.size)
  end

  def test_all_connected_return_edges_length
    face = create_face
    connected = face.all_connected
    edges = connected.grep(Sketchup::Edge)
    assert_equal(4, edges.size)
  end

  def test_all_connected_return_validity
    face = create_face
    connected = face.all_connected
    assert(connected.all? { |entity| entity.valid? })
  end

  def test_all_connected_return_parent
    face = create_face
    connected = face.all_connected
    assert(connected.all? { |entity| entity.parent == face.parent },
      "Returned entities did not come from the correct parent.")
  end

  def test_all_connected_return_model
    face = create_face
    connected = face.all_connected
    assert(connected.all? { |entity| entity.model == face.model },
      "Returned entities did not come from the correct model.")
  end

  def test_all_connected_arity
    assert_equal(0, Sketchup::Face.instance_method(:all_connected).arity)
  end

  def test_all_connected_incorrect_number_of_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.all_connected(1)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.area

  def test_area_api_example
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
    area = face.area
  end

  def test_area_return_type
    face = create_face
    area = face.area

    assert_kind_of(Float, area)
  end

  def test_area_return_value
    face = create_face
    area = face.area
    assert_in_delta(10000.0, area, SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_area_arity
    assert_equal(-1, Sketchup::Face.instance_method(:area).arity)
  end

  def test_area_invalid_arguments
    face = create_face

    assert_raises(TypeError) do
      face.area("String!")
    end

    assert_raises(ArgumentError) do
      face.area(["Array that is not a transformation matrix"],
      "An array that did not contain a Transformation Matrix was accepted as
      a valid argument")
    end

    assert_raises(TypeError) do
      face.area(false)
    end

    assert_raises(TypeError) do
      face.area(nil)
    end
  end

  def test_area_transformed
    face = create_face
    transform = Geom::Transformation.new(
      [0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 1])
    area = face.area(transform)
    assert_in_delta(2500.0, area, SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_area_valid_argument_transformation_object
    face = create_face
    transform = Geom::Transformation.new(
      [0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 1])
    area = face.area(transform)
    assert_kind_of(Float, area)
  end

  def test_area_valid_argument_array_transformation_matrix
    face = create_face
    area = face.area([0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 1])
    assert_kind_of(Float, area)
  end

  # ========================================================================== #
  # method Sketchup::Face.back_material

  def test_back_material_api_example
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
    face.back_material = "red"
    material = face.back_material
  end

  def test_back_material_return_type
    face = create_face
    face.back_material = "red"
    result = face.back_material

    assert_kind_of(Sketchup::Material, result)
  end

  def test_back_material_Set_image_material
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    face = create_face
    image_material = create_image_material
    assert_raises(ArgumentError) do
      face.back_material = image_material
    end
    assert_nil(face.back_material)
  end

  def test_back_material_arity
    assert_equal(0, Sketchup::Face.instance_method(:back_material).arity)
  end

  def test_back_material_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.back_material("String!")
    end

    assert_raises(ArgumentError) do
      face.back_material(["Array"])
    end

    assert_raises(ArgumentError) do
      face.back_material(false)
    end

    assert_raises(ArgumentError) do
      face.back_material(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.back_material=

  def test_back_material_Set_api_example
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
    status = face.back_material = "red"
  end


  def test_back_material_Set_Integer
    face = create_face
    result = face.back_material = 255
    assert_kind_of(Integer, result)
  end

  def test_back_material_Set_HexInteger
    face = create_face
    result = face.back_material = 0xff
    assert_kind_of(Integer, result)
  end

  def test_back_material_Set_HexString
    face = create_face
    result = face.back_material = '#ff0000'
    assert_kind_of(String, result)
  end

  def test_back_material_Set_ArrayFloat
    face = create_face
    result = face.back_material = [1.0, 0.0, 0.0]
    assert_kind_of(Array, result)
  end

  def test_back_material_Set_ArrayInteger
    face = create_face
    result = face.back_material = [255, 0, 0]
    assert_kind_of(Array, result)
  end

  def test_back_material_Set_string
    face = create_face
    result = face.back_material = "red"
    assert_kind_of(String, result)
  end

  def test_back_material_Set_material_object
    face = create_face
    material = Sketchup.active_model.materials.add("Material")
    material.color = "red"
    result = face.back_material = (material)
    assert_kind_of(Sketchup::Material, result)
  end

  def test_back_material_Set_sketchupcolor
    face = create_face
    result = face.back_material = (Sketchup::Color.new("red"))
    assert_kind_of(Sketchup::Color, result)
  end

  def test_back_material_Set_arity
    assert_equal(1, Sketchup::Face.instance_method(:back_material=).arity)
  end

  def test_back_material_Set_invalid_arguments
    skip("Fix this!") if Sketchup.version.to_i < 18
    # SU-30036 - Leaves open operation upon raising errors.
    skip("Broken in SU2014") if Sketchup.version.to_i == 14 # SU-30036
    face = create_face

    #assert_raises(TypeError) do
    #  face.back_material = nil
    #end

    assert_raises(ArgumentError) do
      face.back_material = "invalid color name"
    end

    assert_raises(ArgumentError) do
      face.back_material = ["Array"]
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.classify_point

  def test_classify_point_api_example
    model = Sketchup.active_model
    entities = model.active_entities
    pts = []
    pts[0] = [0, 0, 0]
    pts[1] = [9, 0, 0]
    pts[2] = [9, 9, 0]
    pts[3] = [0, 9, 0]

    # Add the face to the entities in the model
    face = entities.add_face(pts)

    # Check a point that should be outside the face.
    pt = Geom::Point3d.new(50, 50, 0)
    result = face.classify_point(pt)
    if result == Sketchup::Face::PointOutside
      puts "#{pt.to_s} is outside the face"
    end

    # Check a point that should be outside inside the face.
    pt = Geom::Point3d.new(1, 1, 0)
    result = face.classify_point(pt)
    if result == Sketchup::Face::PointInside
      puts "#{pt.to_s} is inside the face"
    end

    # Check a point that should be on the vertex of the face.
    pt = Geom::Point3d.new(0, 0, 0)
    result = face.classify_point(pt)
    if result == Sketchup::Face::PointOnVertex
      puts "#{pt.to_s} is on a vertex"
    end

    # Check a point that should be on the edge of the face.
    pt = Geom::Point3d.new(0, 1, 0)
    result = face.classify_point(pt)
    if result == Sketchup::Face::PointOnEdge
      puts "#{pt.to_s} is on an edge of the face"
    end

    # Check a point that should be off the plane of the face.
    pt = Geom::Point3d.new(1, 1, 10)
    result = face.classify_point(pt)
    if result == Sketchup::Face::PointNotOnPlane
      puts "#{pt.to_s} is not on the same plane as the face"
    end
  end

  def test_classify_point_outside
    face = create_face
    # Check a point that should be outside the face.
    pt = Geom::Point3d.new(500, 500, 0)
    result = face.classify_point(pt)
    assert_equal(Sketchup::Face::PointOutside, result)
  end

  def test_classify_point_inside
    face = create_face
    # Check a point that should be inside the face.
    pt = Geom::Point3d.new(1, 1, 0)
    result = face.classify_point(pt)
    assert_equal(Sketchup::Face::PointInside, result)
  end

  def test_classify_point_on_vertex
    face = create_face
    # Check a point that should be on the vertex of the face.
    pt = Geom::Point3d.new(0, 0, 0)
    result = face.classify_point(pt)
    assert_equal(Sketchup::Face::PointOnVertex, result)
  end

  def test_classify_point_on_edge
    face = create_face
    # Check a point that should be on the edge of the face.
    pt = Geom::Point3d.new(1, 0, 0)
    result = face.classify_point(pt)
    assert_equal(Sketchup::Face::PointOnEdge, result)
  end

  def test_classify_point_off_plane
    face = create_face
    # Check a point that should be off the plane of the face.
    pt = Geom::Point3d.new(1, 1, 10)
    result = face.classify_point(pt)
    assert_equal(Sketchup::Face::PointNotOnPlane, result)
  end


  def test_classify_point_arity
    assert_equal(1, Sketchup::Face.instance_method(:classify_point).arity)
  end

  def test_classify_point_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.classify_point("Strings are not valid!")
    end

    assert_raises(ArgumentError) do
      face.classify_point(["Array"])
    end

    assert_raises(ArgumentError) do
      face.classify_point(true)
    end

    assert_raises(ArgumentError) do
      face.classify_point(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.edges

  def test_edges_api_example
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
    edges = face.edges
  end

  def test_edges_return_type
    face = create_face
    result = face.edges
    assert_kind_of(Array, result)
  end

  def test_edges_return_value
    face = create_face
    result = face.edges
    assert(result.all? { |entity| entity.is_a?(Sketchup::Edge) },
      'Not all entities returned were edges.')
  end

  def test_edges_return_array_length
    face = create_face
    result = face.edges
    assert_equal(result.length, 4)
  end

  def test_edges_arity
    assert_equal(0, Sketchup::Face.instance_method(:edges).arity)
  end

  def test_edges_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.edges("Strings are not valid!")
    end

    assert_raises(ArgumentError) do
      face.edges(["Can't use array"])
    end

    assert_raises(ArgumentError) do
      face.edges(12)
    end

    assert_raises(ArgumentError) do
      face.edges(false)
    end

    assert_raises(ArgumentError) do
      face.edges(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Face.followme

  def test_followme_api_example
    model = Sketchup.active_model
    entities = model.active_entities
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(0, 0, 100)
    depth = 100
    width = 100
    pts = []
    pts[0] = [0, 0, 0]
    pts[1] = [width, 0, 0]
    pts[2] = [width, depth, 0]
    pts[3] = [0, depth, 0]

    # Add the face to the entities in the model
    face = entities.add_face(pts)

    # Add the line which we will "follow" to the entities in the model
    line = entities.add_line(point1, point2)
    status = face.followme(line)
  end

  def test_followme_edge_argument_result
    face = create_face
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(0, 0, 100)
    edge = Sketchup.active_model.active_entities.add_edges(point1, point2)
    result = face.followme(edge)

    assert_kind_of(TrueClass, result)
  end

  def test_followme_edge_array_argument_result
    face = create_face
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(0, 0, 100)
    point3 = Geom::Point3d.new(100, 0, 200)
    point4 = Geom::Point3d.new(200, 0, 200)
    edge1 = Sketchup.active_model.active_entities.add_edges(point1, point2)
    edge2 = Sketchup.active_model.active_entities.add_edges(point2, point3)
    edge3 = Sketchup.active_model.active_entities.add_edges(point3, point4)
    result = face.followme(edge1, edge2, edge3)
    assert_kind_of(TrueClass, result)
  end

  def test_followme_return_array_length
    face = create_face

    start_ents = Sketchup.active_model.active_entities.length
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(0, 0, 100)
    edge = Sketchup.active_model.active_entities.add_edges(point1, point2)

    face.followme(edge)
    end_ents = Sketchup.active_model.active_entities.length
    total_added_ents = end_ents - start_ents

    assert_equal(13, total_added_ents)
  end

  def test_followme_arity
    assert_equal(-1, Sketchup::Face.instance_method(:followme).arity)
  end

  def test_followme_too_few_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.followme
    end
  end

  def test_followme_invalid_arguments
    face = create_face

    assert_raises(TypeError) do
      face.followme(["Can't use array"])
    end

    #assert_raises(ArgumentError) do
    #  face.followme(nil)
    #end
  end

  # ========================================================================== #
  # method Sketchup::Face.get_glued_instances

  def test_get_glued_instances_api_example
    # Create a series of points that define a new face.
    model = Sketchup.active_model
    entities = model.active_entities
    pts = []
    pts[0] = [0, 0, 0]
    pts[1] = [9, 0, 0]
    pts[2] = [9, 9, 0]
    pts[3] = [0, 9, 0]

    # Add the face to the entities in the model
    face = entities.add_face(pts)
    glued_array = face.get_glued_instances
  end

  def test_get_glued_instances_result_type
    returned_array = create_face_with_glued_instance
    face = returned_array[0]
    glued_array = face.get_glued_instances

    assert_kind_of(Array, glued_array)
  end

  def test_get_glued_instances_return_array_length
    returned_array = create_face_with_glued_instance
    face = returned_array[0]
    glued_array = face.get_glued_instances

    assert_equal(1, glued_array.length)
  end

  def test_get_glued_instances_return_none_glued
    face = create_face
    glued_array = face.get_glued_instances

    assert_equal(0, glued_array.length)
  end

  def test_get_glued_instances_arity
    assert_equal(-1, Sketchup::Face.instance_method(:followme).arity)
  end

  def test_get_glued_instances_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.get_glued_instances(["Can't use array"])
    end

    assert_raises(ArgumentError) do
      face.get_glued_instances(12)
    end

    assert_raises(ArgumentError) do
      face.get_glued_instances(false)
    end

    assert_raises(ArgumentError) do
      face.get_glued_instances(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Face.get_texture_projection

  def test_get_texture_projection_api_example
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    model = Sketchup.active_model
    entities = model.active_entities
    materials = model.materials
    # Create a face and add it to the model entities.
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(10, 0, 0),
      Geom::Point3d.new(10, 10, 0),
    ]
    face = entities.add_face(points)
    # Export an image to use as a texture.
    path = Sketchup.temp_dir
    full_name = File.join(path, "temp_image.jpg")
    model.active_view.write_image(full_name, 500, 500, false, 0.0)
    # Create a material and assign the texture to it.
    material = materials.add("Test Material")
    material.texture = full_name
    # Assign the new material to our face we created.
    mapping = [
      Geom::Point3d.new(0, 0, 0), # World coordinate
      Geom::Point3d.new(0, 0, 0), # UV coordinate
    ]
    face.position_material(material, mapping, true, Geom::Vector3d.new(1, 2, 3))
    # Get the projection of the applied material.
    # This will be a normalized version of the vector given to position_material.
    vector = face.get_texture_projection(true)
  end

  def test_get_texture_projection_front_face
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_material
    mapping = [
      Geom::Point3d.new(0, 0, 0), # World coordinate
      Geom::Point3d.new(0, 0, 0), # UV coordinate
    ]
    projection = Geom::Vector3d.new(1, 2, 3)
    face.position_material(material, mapping, true, projection)
    result = face.get_texture_projection(true)
    assert_kind_of(Geom::Vector3d, result)
    assert_equal(projection.normalize, result)
  end

  def test_get_texture_projection_back_face
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_material
    mapping = [
      Geom::Point3d.new(0, 0, 0), # World coordinate
      Geom::Point3d.new(0, 0, 0), # UV coordinate
    ]
    projection = Geom::Vector3d.new(1, 2, 3)
    face.position_material(material, mapping, false, projection)
    result = face.get_texture_projection(false)
    assert_kind_of(Geom::Vector3d, result)
    assert_equal(projection.normalize, result)
  end

  def test_get_texture_projection_return_no_material
    face = create_face
    assert_nil(face.get_texture_projection(true))
  end

  def test_get_texture_projection_return_material_not_projected
    face = create_face
    material = create_material
    face.material = material

    assert_nil(face.get_texture_projection(true))
  end

  def test_get_texture_projection_arity
    assert_equal(1, Sketchup::Face.instance_method(
      :get_texture_projection).arity)
  end


  # ========================================================================== #
  # method Sketchup::Face.clear_texture_projection

  def test_clear_texture_projection
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_material
    mapping = [
      Geom::Point3d.new(0, 0, 0), # World coordinate
      Geom::Point3d.new(0, 0, 0), # UV coordinate
    ]
    projection = Geom::Vector3d.new(1, 2, 3)
    face.position_material(material, mapping, true, projection)
    face.position_material(material, mapping, false, projection)
    assert_equal(projection.normalize, face.get_texture_projection(true))
    assert_equal(projection.normalize, face.get_texture_projection(false))

    # Front side
    face.clear_texture_projection(true)

    refute(face.texture_projected?(true))
    assert_nil(face.get_texture_projection(true))
    assert(face.texture_positioned?(true))

    assert(face.texture_projected?(false))
    assert_equal(projection.normalize, face.get_texture_projection(false))
    assert(face.texture_positioned?(false))

    # Back side
    face.clear_texture_projection(false)

    refute(face.texture_projected?(false))
    assert_nil(face.get_texture_projection(false))
    assert(face.texture_positioned?(false))
  end

  def test_clear_texture_projection_material_with_no_texture
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    face.material = Sketchup.active_model.materials.add('TestMaterial')
    face.clear_texture_projection(true)
  end

  def test_clear_texture_projection_no_material
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    face.clear_texture_projection(true)
  end

  def test_clear_texture_projection_too_few_arguments
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.clear_texture_projection
    end
  end

  def test_clear_texture_projection_too_many_arguments
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.clear_texture_projection(true, true)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.get_UVHelper

  def test_get_UVHelper_api_example
    model = Sketchup.active_model
    entities = model.active_entities
    pts = []
    pts[0] = [0, 0, 0]
    pts[1] = [9, 0, 0]
    pts[2] = [9, 9, 0]
    pts[3] = [0, 9, 0]

    # Add the face to the entities in the model
    face = entities.add_face(pts)
    tw = Sketchup.create_texture_writer
    uvHelp = face.get_UVHelper(true, true, tw)
  end

  def test_get_UVHelper_result_type_front_back
    face = create_face
    tw = Sketchup.create_texture_writer
    uvHelp = face.get_UVHelper(true, true, tw)

    assert_kind_of(Sketchup::UVHelper, uvHelp)
  end

  def test_get_UVHelper_result_type_front_only
    face = create_face
    tw = Sketchup.create_texture_writer
    uvHelp = face.get_UVHelper(true, false, tw)

    assert_kind_of(Sketchup::UVHelper, uvHelp)
  end

  def test_get_UVHelper_result_type_back_only
    face = create_face
    tw = Sketchup.create_texture_writer
    uvHelp = face.get_UVHelper(false, true, tw)

    assert_kind_of(Sketchup::UVHelper, uvHelp)
  end

  def test_get_UVHelper_result_no_params
    face = create_face
    uvHelp = face.get_UVHelper

    assert_kind_of(Sketchup::UVHelper, uvHelp)
  end

  def test_get_UVHelper_arity
    assert_equal(-1, Sketchup::Face.instance_method(:get_UVHelper).arity)
  end

  def test_get_UVHelper_invalid_arguments
    face = create_face

    assert_raises(TypeError) do
      face.get_UVHelper([1], [1], [1])
    end

    assert_raises(TypeError) do
      face.get_UVHelper(nil, nil, nil)
    end

    assert_raises(TypeError) do
      face.get_UVHelper("st", "ri", "ng")
    end
  end


  # ========================================================================== #
  # method Sketchup::Face.loops

  def test_loops_api_example
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
    loops = face.loops
  end

  def test_loops_return_type
    face = create_face_with_hole
    result = face.loops
    assert_kind_of(Array, result)
  end

  def test_loops_return_value
    face = create_face_with_hole
    result = face.loops
    assert(result.all? { |entity| entity.is_a?(Sketchup::Loop) },
      'Not all entities returned were Loops.')
  end

  def test_loops_return_array_length
    face = create_face_with_hole
    result = face.loops
    assert_equal(result.length, 2)
  end

  def test_loops_arity
    assert_equal(0, Sketchup::Face.instance_method(:loops).arity)
  end

  def test_loops_invalid_arguments
    face = create_face_with_hole

    assert_raises(ArgumentError) do
      face.loops("Strings are not valid!")
    end

    assert_raises(ArgumentError) do
      face.loops(["Can't use array"])
    end

    assert_raises(ArgumentError) do
      face.loops(12)
    end

    assert_raises(ArgumentError) do
      face.loops(false)
    end

    assert_raises(ArgumentError) do
      face.loops(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.mesh

  if Sketchup.version.to_i < 2018
    MESH_POINTS = 0
    MESH_UVQ_FRONT = 1
    MESH_UVQ_BACK = 2
    MESH_NORMALS = 4
  else
    MESH_POINTS = Geom::PolygonMesh::MESH_POINTS
    MESH_UVQ_FRONT = Geom::PolygonMesh::MESH_UVQ_FRONT
    MESH_UVQ_BACK = Geom::PolygonMesh::MESH_UVQ_BACK
    MESH_NORMALS = Geom::PolygonMesh::MESH_NORMALS
  end
  MESH_EVERYTHING = MESH_POINTS | MESH_NORMALS | MESH_UVQ_FRONT | MESH_UVQ_BACK

  def test_mesh_api_example
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
    mesh = face.mesh(7)
  end

  def test_mesh_flags_with_points
    face = create_face_with_hole

    mesh = face.mesh(0)
    assert_kind_of(Geom::PolygonMesh, mesh)
    assert_equal(8, mesh.count_polygons)
    assert_equal(8, mesh.count_points)

    (1..mesh.count_points).each { |i|
      assert_equal(Geom::Vector3d.new(0, 0, 0), mesh.normal_at(i))
      assert_equal(Geom::Point3d.new(0, 0, 0), mesh.uv_at(i, true))
      assert_equal(Geom::Point3d.new(0, 0, 0), mesh.uv_at(i, false))
    }
  end

  def test_mesh_flags_with_points_and_normals
    face = create_face_with_hole

    mesh = face.mesh(MESH_POINTS | MESH_NORMALS)
    assert_kind_of(Geom::PolygonMesh, mesh)
    assert_equal(8, mesh.count_polygons)
    assert_equal(8, mesh.count_points)

    (1..mesh.count_points).each { |i|
      assert_equal(Z_AXIS.reverse, mesh.normal_at(i), "Normal at #{i}")
      assert_equal(Geom::Point3d.new(0, 0, 0), mesh.uv_at(i, true))
      assert_equal(Geom::Point3d.new(0, 0, 0), mesh.uv_at(i, false))
    }
  end

  def test_mesh_flags_with_points_and_front_UVQs
    face = create_face_with_hole

    mesh = face.mesh(MESH_POINTS | MESH_UVQ_FRONT)
    assert_kind_of(Geom::PolygonMesh, mesh)
    assert_equal(8, mesh.count_polygons)
    assert_equal(8, mesh.count_points)

    expected_uvs = [
      Geom::Point3d.new(1000, 1000, 1),
      Geom::Point3d.new(0, 100, 1),
      Geom::Point3d.new(1000, -1000, 1),
      Geom::Point3d.new(-1000, 1000, 1),
      Geom::Point3d.new(-100, 100, 1),
      Geom::Point3d.new(-100, 0, 1),
      Geom::Point3d.new(0, 0, 1),
      Geom::Point3d.new(-1000, -1000, 1),
    ]

    (1..mesh.count_points).each { |i|
      assert_equal(Geom::Vector3d.new(0, 0, 0), mesh.normal_at(i), "Normal at #{i}")
      assert_equal(expected_uvs[i - 1], mesh.uv_at(i, true))
      assert_equal(Geom::Point3d.new(0, 0, 0), mesh.uv_at(i, false))
    }
  end

  def test_mesh_flags_with_points_and_back_UVQs
    face = create_face_with_hole

    mesh = face.mesh(MESH_POINTS | MESH_UVQ_BACK)
    assert_kind_of(Geom::PolygonMesh, mesh)
    assert_equal(8, mesh.count_polygons)
    assert_equal(8, mesh.count_points)

    expected_uvs = [
      Geom::Point3d.new(1000, 1000, 1),
      Geom::Point3d.new(0, 100, 1),
      Geom::Point3d.new(1000, -1000, 1),
      Geom::Point3d.new(-1000, 1000, 1),
      Geom::Point3d.new(-100, 100, 1),
      Geom::Point3d.new(-100, 0, 1),
      Geom::Point3d.new(0, 0, 1),
      Geom::Point3d.new(-1000, -1000, 1),
    ]

    (1..mesh.count_points).each { |i|
      assert_equal(Geom::Vector3d.new(0, 0, 0), mesh.normal_at(i), "Normal at #{i}")
      assert_equal(Geom::Point3d.new(0, 0, 0), mesh.uv_at(i, true))
      assert_equal(expected_uvs[i - 1], mesh.uv_at(i, false))
    }
  end

  def test_mesh_all_flags
    face = create_face_with_hole

    mesh = face.mesh(MESH_EVERYTHING)
    assert_kind_of(Geom::PolygonMesh, mesh)
    assert_equal(8, mesh.count_polygons)
    assert_equal(8, mesh.count_points)

    expected_uvs = [
      Geom::Point3d.new(1000, 1000, 1),
      Geom::Point3d.new(0, 100, 1),
      Geom::Point3d.new(1000, -1000, 1),
      Geom::Point3d.new(-1000, 1000, 1),
      Geom::Point3d.new(-100, 100, 1),
      Geom::Point3d.new(-100, 0, 1),
      Geom::Point3d.new(0, 0, 1),
      Geom::Point3d.new(-1000, -1000, 1),
    ]

    (1..mesh.count_points).each { |i|
      assert_equal(Z_AXIS.reverse, mesh.normal_at(i), "Normal at #{i}")
      assert_equal(expected_uvs[i - 1], mesh.uv_at(i, true), "Front UVQs at #{i}")
      assert_equal(expected_uvs[i - 1], mesh.uv_at(i, false), "Back UVQs at #{i}")
    }
  end

  def test_mesh_arity
    assert_equal(-1, Sketchup::Face.instance_method(:mesh).arity)
  end

  def test_mesh_invalid_arguments
    face = create_face_with_hole

    assert_raises(TypeError) do
      face.mesh("Strings are not valid!")
    end

    assert_raises(TypeError) do
      face.mesh(["Can't use array"])
    end

    assert_raises(TypeError) do
      face.mesh(false)
    end

    assert_raises(TypeError) do
      face.mesh(nil)
    end
  end

  def test_mesh_arguments_out_of_range
    face = create_face_with_hole

    # Should raise an error, but does not
    #assert_raises(TypeError) do
    #  face.mesh(12)
    #end

    assert_raises(RangeError) do
      face.mesh(-5)
    end

  end

  # ========================================================================== #
  # method Sketchup::Face.normal

  def test_normal_api_example
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
    normal = face.normal
  end

  def test_normal_return_value_face_on_ground
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0, 0, 0], [100, 0, 0], [100, 100, 0], [0, 100, 0])
    vector = Geom::Vector3d.new(0, 0, -1)
    result = face.normal
    assert_equal(vector,result)
  end

  def test_normal_return_value_face_in_space
    p1,p2,p3 = [0, 0, 0], [10, 0, 10], [20, 10, 10]
    face = Sketchup.active_model.active_entities.add_face(p1, p2, p3)
    vector = Geom::Vector3d.new(
      -0.5773502691896258, 0.5773502691896257, 0.5773502691896258)
    result = face.normal

    assert_equal(true, (vector == result))
  end

  def test_normal_arity
    assert_equal(0, Sketchup::Face.instance_method(:normal).arity)
  end

  def test_normal_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.normal(-5)
    end

    assert_raises(ArgumentError) do
      face.normal(true)
    end

    assert_raises(ArgumentError) do
      face.normal("string")
    end

    assert_raises(ArgumentError) do
      face.normal(["Array"])
    end

    assert_raises(ArgumentError) do
      face.normal(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.outer_loop

  def test_outer_loop_api_example
    # Create a series of points that define a new face.
    model = Sketchup.active_model
    entities = model.active_entities
    pts = []
    pts[0] = [0, 0, 0]
    pts[1] = [9, 0, 0]
    pts[2] = [9, 9, 0]
    pts[3] = [0, 9, 0]

    # Add the face to the entities in the model
    face = entities.add_face(pts)
    loop = face.outer_loop
  end

  def test_outer_loop_return_type
    face = create_face_with_hole
    result = face.outer_loop
    assert_kind_of(Sketchup::Loop, result)
  end

  def test_outer_loop_arity
    assert_equal(0, Sketchup::Face.instance_method(:outer_loop).arity)
  end

  def test_outer_loop_invalid_arguments
    face = create_face_with_hole

    assert_raises(ArgumentError) do
      face.outer_loop("Strings are not valid!")
    end

    assert_raises(ArgumentError) do
      face.outer_loop(["Can't use array"])
    end

    assert_raises(ArgumentError) do
      face.outer_loop(12)
    end

    assert_raises(ArgumentError) do
      face.outer_loop(false)
    end

    assert_raises(ArgumentError) do
      face.outer_loop(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.plane

  def test_plane_api_example
    point1 = Geom::Point3d.new(0,0,0)
    point2 = Geom::Point3d.new(0,0,100)
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
    plane = face.plane
  end


  def test_plane_return_type
    face = create_face
    result = face.plane
    assert_kind_of(Array, result)
  end

  def test_plane_return_value
    face = create_face
    result = face.plane
    assert_equal([-0.0, -0.0, 1.0, -0.0], result)
  end

  def test_plane_arity
    assert_equal(0, Sketchup::Face.instance_method(:plane).arity)
  end

  def test_plane_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.plane(-5)
    end

    assert_raises(ArgumentError) do
      face.plane(true)
    end

    assert_raises(ArgumentError) do
      face.plane("string")
    end

    assert_raises(ArgumentError) do
      face.plane(["Array"])
    end

    assert_raises(ArgumentError) do
      face.plane(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.position_material

  def test_position_material_api_example
    model = Sketchup.active_model
    entities = model.active_entities
    # Create a face and add it to the model entities
    pts = []
    pts[0] = [0, 0, 1]
    pts[1] = [9, 0, 1]
    pts[2] = [9, 9, 1]
    pts[3] = [0, 9, 1]
    face = entities.add_face(pts)
    # Export an image to use as a texture
    path = Sketchup.temp_dir
    full_name = File.join(path, "temp_image.jpg")
    model.active_view.write_image(full_name, 500, 500, false, 0.0)
    # Create a material and assign the texture to it
    material = model.materials.add("Test Material")
    material.texture = full_name
    # Assign the new material to our face we created
    face.material = material
    pt_array = []
    pt_array[0] = Geom::Point3d.new(3, 0, 0)
    pt_array[1] = Geom::Point3d.new(0, 0, 0)
    on_front = true
    face.position_material(material, pt_array, on_front)
  end

  def test_position_material_return_type
    face = create_face
    material = create_material
    face.material = material
    pt_array = []
    pt_array[0] = Geom::Point3d.new(3, 0, 0)
    pt_array[1] = Geom::Point3d.new(0, 0, 0)
    result = face.position_material(material, pt_array, true)
    assert_kind_of(Sketchup::Face, result)
  end

  def test_position_material_return_value
    face = create_face
    material = create_material
    face.material = material
    pt_array = []
    pt_array[0] = Geom::Point3d.new(3, 0, 0)
    pt_array[1] = Geom::Point3d.new(0, 0, 0)
    result = face.position_material(material, pt_array, true)
    assert_equal(face, result)
  end

  def test_position_material_single_point
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    material = create_test_material('UV-Tile.png')
    face = create_face
    mapping = [
      Geom::Point3d.new(15, 25, 0), # World 
      Geom::Point3d.new(0, 0, 0),   # UV
    ]
    result = face.position_material(material, mapping, true)
    assert_equal(face, result)
    assert(face.texture_positioned?(true), "front face not positioned")
    refute(face.texture_positioned?(false), "back face positioned")
    face.position_material(material, mapping, false)
    assert(face.texture_positioned?(false), "back face not positioned")
  end

  def test_position_material_linear_points_degenerate
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    # Degenerate case.
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(3, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(30, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(50, 0, 0),
      Geom::Point3d.new(1, 1, 0),

      Geom::Point3d.new(70, 0, 0),
      Geom::Point3d.new(0, 1, 0),
    ]

    # Front side
    assert_raises(ArgumentError) do
      face.position_material(material, mapping, true)
    end
    refute(face.texture_positioned?(true), "front material Positioned")
    refute(face.texture_projected?(true), "front material Projected")
  end

  def test_position_material_linear_points_unexpectedly_passes
    skip('Fixed in SU2023.0') if Sketchup.version.to_f >= 23.0
    # Degenerate case - not sure why this passes.
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(100, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(200, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(250, 0, 0),
      Geom::Point3d.new(1, 1, 0),

      Geom::Point3d.new(350, 0, 0),
      Geom::Point3d.new(0, 1, 0),
    ]

    # Front side
    result = face.position_material(material, mapping, true)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    refute(face.texture_projected?(true), "front material Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    # Back side
    result = face.position_material(material, mapping, false)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    refute(face.texture_projected?(false), "back material Projected")
  end

  def test_position_material_linear_points
    skip('Fixed in SU2023.0') if Sketchup.version.to_f < 23.0
    # Degenerate case - not sure why this passes.
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(100, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(200, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(250, 0, 0),
      Geom::Point3d.new(1, 1, 0),

      Geom::Point3d.new(350, 0, 0),
      Geom::Point3d.new(0, 1, 0),
    ]

    assert_raises(ArgumentError) do
      face.position_material(material, mapping, true)
    end
    assert_raises(ArgumentError) do
      face.position_material(material, mapping, false)
    end
  end

  def test_position_material_projected_of_face_plane_single_point
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(3, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV
    ]
    direction = Geom::Vector3d.new(0, -1, 1)

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end

  def test_position_material_projected_of_face_plane_two_points
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(3, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(30, 0, 0),
      Geom::Point3d.new(1, 0, 0),
    ]
    direction = Geom::Vector3d.new(0, -1, 1)

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end
  
  def test_position_material_projected_of_face_plane_three_points_orthogonal
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(3, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(30, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(30, 50, 0),
      Geom::Point3d.new(1, 1, 0),
    ]
    direction = Geom::Vector3d.new(0, -1, 1)

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end

  def test_position_material_projected_of_face_plane_three_points_skewed
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(3, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(30, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(60, 50, 0),
      Geom::Point3d.new(1, 1, 0),
    ]
    direction = Geom::Vector3d.new(0, -1, 1)

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end

  def test_position_material_projected_of_face_plane_four_points_orthogonal
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(3, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(30, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(30, 50, 0),
      Geom::Point3d.new(1, 1, 0),

      Geom::Point3d.new(3, 50, 0),
      Geom::Point3d.new(0, 1, 0),
    ]
    direction = Geom::Vector3d.new(0, -1, 1)

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end

  def test_position_material_projected_of_face_plane_four_points_distorted
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(0, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(30, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(40, 50, 0),
      Geom::Point3d.new(1, 1, 0),

      Geom::Point3d.new(-20, 50, 0),
      Geom::Point3d.new(0, 1, 0),
    ]
    direction = Geom::Vector3d.new(0, -1, 1)

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end

  def test_position_material_projected_on_face_plane_distorted
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    model = Sketchup.active_model
    entities = model.active_entities

    face = entities.add_face([0, 0, 0], [50, 0, 0], [70, 100, 0], [-20, 100, 0])
    face.reverse!
    face

    material = create_test_material('UV-Tile.png')
    face.material = material

    mapping = [
      Geom::Point3d.new(0, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV

      Geom::Point3d.new(50, 0, 0),
      Geom::Point3d.new(1, 0, 0),

      Geom::Point3d.new(70, 100, 0),
      Geom::Point3d.new(1, 1, 0),

      Geom::Point3d.new(-20, 100, 0),
      Geom::Point3d.new(0, 1, 0),
    ]

    direction = Geom::Vector3d.new(0, 0, 1)

    # Transform everything to be on a plane that isn't aligned with any of the
    # XYZ axes.
    origin = Geom::Point3d.new(40, 50, 10)
    vector = Geom::Vector3d.new(1, 2, 3)
    tr = Geom::Transformation.new(origin, vector)
    face.parent.entities.transform_entities(tr, [face])
    direction.transform!(tr)
    mapping.each_slice(2) { |pt, uv| pt.transform!(tr) }

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end

  def test_position_material_projected_perpendicular
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [
      Geom::Point3d.new(3, 0, 0), # World position
      Geom::Point3d.new(0, 0, 0), # UV
    ]
    direction = Geom::Vector3d.new(0, -1, 0)

    # Front side
    result = face.position_material(material, mapping, true, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(true), "front material not Positioned")
    assert(face.texture_projected?(true), "front material not Projected")
    refute(face.texture_positioned?(false), "back material Positioned")
    refute(face.texture_projected?(false), "back material Projected")

    projection = face.get_texture_projection(true)
    assert_equal(direction.normalize, projection)

    # Back side
    result = face.position_material(material, mapping, false, direction)
    assert_equal(face, result)

    assert(face.texture_positioned?(false), "back material not Positioned")
    assert(face.texture_projected?(false), "back material not Projected")

    projection = face.get_texture_projection(false)
    assert_equal(direction.normalize, projection)
  end

  def test_position_material_arity
    assert_equal(-1, Sketchup::Face.instance_method(:position_material).arity)
  end

  def test_position_too_few_arguments
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [ [3, 0, 0], [0, 0, 0] ]
    assert_raises(ArgumentError) do
      face.position_material(material, mapping)
    end
  end

  def test_position_too_many_arguments
    skip('Changed in SU2021.0') if Sketchup.version.to_f >= 21.0
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [ [3, 0, 0], [0, 0, 0] ]
    assert_raises(ArgumentError) do
      face.position_material(material, mapping, true, nil)
    end
  end

  def test_position_too_many_arguments_su2021
    skip('Changed in SU2021.0') if Sketchup.version.to_f < 21.0
    face = create_face
    material = create_test_material('UV-Tile.png')
    face.material = material
    mapping = [ [3, 0, 0], [0, 0, 0] ]
    direction = Geom::Vector3d.new(0, -1, 1)
    assert_raises(ArgumentError) do
      face.position_material(material, mapping, true, direction, nil)
    end
  end

  def test_position_material_image_material
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    face = create_face
    image_material = create_image_material
    pt_array = [
      Geom::Point3d.new(3, 0, 0),
      Geom::Point3d.new(0, 0, 0),
    ]
    assert_raises(ArgumentError) do
      face.position_material(image_material, pt_array, true)
    end
    assert_nil(face.material)
  end

  def test_position_material_invalid_arguments
    face = create_face
    material = create_material
    face.material = material

    assert_raises(ArgumentError) do
      face.position_material("st", "ri", "ng")
    end

    assert_raises(TypeError) do
      face.position_material(false, false, false)
    end

    #assert_raises(ArgumentError) do
    #  face.position_material(1, 2, 3)
    #end

    #assert_raises(ArgumentError) do
    #  face.position_material(nil, nil, nil)
    #end
  end


  # ========================================================================== #
  # method Sketchup::Face.uv_tile_at

  # @param [Integer] face_pid
  # @param [Geom::Point3d] ref_point
  # @param [Array<Array(Geom::Point3d, Geom::Point3d)>] expected
  # @param [Boolean] front
  def assert_uv_tile_at(face_pid, ref_point, expected, front = true, test_model: 'uv_tile_at_variations.skp')
    model = open_test_model(test_model)
    face = model.find_entity_by_persistent_id(face_pid)
    assert_kind_of(Sketchup::Face, face)

    points = face.uv_tile_at(ref_point, front)
    assert_kind_of(Array, points)
    assert_equal(8, points.size)
    assert(points.all? { |point| point.is_a?(Geom::Point3d) })

    pairs = points.each_slice(2).to_a
    expected.size.times { |i|
      actual_pair = pairs[i]
      expect_pair = expected[i]
      assert_equal(expect_pair[0], actual_pair[0], "World Point (#{i})")
      assert_equal(expect_pair[1], actual_pair[1], "UV Point (#{i})")
    }
  end

  # @param [Integer] face_pid
  # @param [Geom::Point3d] ref_point
  # @param [Boolean] front
  def assert_uv_tile_at_remap(face_pid, ref_point, front = true)
    model = open_test_model('uv_tile_at_variations.skp')
    face = model.find_entity_by_persistent_id(face_pid)
    assert_kind_of(Sketchup::Face, face)

    material = front ? face.material : face.back_material
    mapping = face.uv_tile_at(ref_point, front)
    
    if face.texture_projected?(front)
      projection = face.get_texture_projection(front)
      face.position_material(material, mapping, front, projection)
    else
      face.position_material(material, mapping, front)
    end

    points = face.uv_tile_at(ref_point, front)
    assert_kind_of(Array, points)
    assert_equal(8, points.size)
    assert(points.all? { |point| point.is_a?(Geom::Point3d) })

    actual = points.each_slice(2).to_a
    expected = mapping.each_slice(2).to_a
    expected.size.times { |i|
      actual_pair = actual[i]
      expect_pair = expected[i]
      assert_equal(expect_pair[0], actual_pair[0], "World Point (#{i})")
      assert_equal(expect_pair[1], actual_pair[1], "UV Point (#{i})")
    }
  end

  def test_uv_tile_at_positioned_stretched
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    model = Sketchup.active_model
    path = get_test_case_file('uv_tile_at.skp')
    definition = model.definitions.load(path)
    model.entities.add_instance(definition, IDENTITY)
    face = definition.entities.grep(Sketchup::Face).first

    points = face.uv_tile_at(Geom::Point3d.new(25, 45, 0), true)
    assert_kind_of(Array, points)
    assert_equal(8, points.size)
    assert(points.all? { |point| point.is_a?(Geom::Point3d) })

    pairs = points.each_slice(2).to_a
    expected = [
      [
        Geom::Point3d.new(20, 40, 0), # World
        Geom::Point3d.new(1, 3, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(30, 40, 0), # World
        Geom::Point3d.new(2, 3, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(30, 60, 0), # World
        Geom::Point3d.new(2, 4, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(20, 60, 0), # World
        Geom::Point3d.new(1, 4, 0), # UV (0, 1)
      ],
    ]
    assert_equal(expected, pairs)
  end

  def test_uv_tile_at_no_material
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    ref_point = Geom::Point3d.new(20, 30, 0)
    assert_nil(face.uv_tile_at(ref_point, true), "front face")
    assert_nil(face.uv_tile_at(ref_point, false), "back face")
  end

  def test_uv_tile_at_material_no_texture
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    face.material = 'red'
    face.back_material = 'blue'
    ref_point = Geom::Point3d.new(20, 30, 0)
    assert_nil(face.uv_tile_at(ref_point, true), "front face")
    assert_nil(face.uv_tile_at(ref_point, false), "back face")
  end

  def test_uv_tile_at_not_positioned
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(60, 39.3778, 0), # World
        Geom::Point3d.new(3, 0, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(80, 39.3778, 0), # World
        Geom::Point3d.new(4, 0, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(80, 39.3778, 20), # World
        Geom::Point3d.new(4, 1, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(60, 39.3778, 20), # World
        Geom::Point3d.new(3, 1, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27788, Geom::Point3d.new(67.4581, 39.3778, 14.0827), expected, true)
  end

  def test_uv_tile_at_positioned_face_at_origin
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(20, 0, 20), # World
        Geom::Point3d.new(2, 3, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(30, 0, 20), # World
        Geom::Point3d.new(3, 3, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(30, 0, 40), # World
        Geom::Point3d.new(3, 4, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(20, 0, 40), # World
        Geom::Point3d.new(2, 4, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27806, Geom::Point3d.new(25, 0, 35), expected, true)
  end

  def test_uv_tile_at_reference_point_not_on_face
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(20, 0, 20), # World
        Geom::Point3d.new(2, 3, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(30, 0, 20), # World
        Geom::Point3d.new(3, 3, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(30, 0, 40), # World
        Geom::Point3d.new(3, 4, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(20, 0, 40), # World
        Geom::Point3d.new(2, 4, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27806, Geom::Point3d.new(25, -60, 35), expected, true)
  end

  def test_uv_tile_at_positioned_face_below_ground
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(138.11, 0, -10), # World
        Geom::Point3d.new(2, 3, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(148.11, 0, -10), # World
        Geom::Point3d.new(3, 3, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(148.11, 0, 10), # World
        Geom::Point3d.new(3, 4, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(138.11, 0, 10), # World
        Geom::Point3d.new(2, 4, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27824, Geom::Point3d.new(143, 0, 5), expected, true)
  end

  def test_uv_tile_at_positioned_face_not_on_axis
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(138.11, 69.6534, -10), # World
        Geom::Point3d.new(2, 3, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(148.11, 69.6534, -10), # World
        Geom::Point3d.new(3, 3, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(148.11, 69.6534, 10), # World
        Geom::Point3d.new(3, 4, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(138.11, 69.6534, 10), # World
        Geom::Point3d.new(2, 4, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27851, Geom::Point3d.new(143, 0, 5), expected, true)
  end

  def test_uv_tile_at_skewed
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(206.85, 0, 20), # World
        Geom::Point3d.new(0, 3, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(216.85, 0, 20), # World
        Geom::Point3d.new(1, 3, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(226.851, 0, 40), # World
        Geom::Point3d.new(1, 4, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(216.85, 0, 40), # World
        Geom::Point3d.new(0, 4, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27870, Geom::Point3d.new(216, 0, 25), expected, true)
  end

  def test_uv_tile_at_distorted_to_parallel
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(423.11, 69.6534, -20), # World
        Geom::Point3d.new(1, 2, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(443.11, 69.6534, -20), # World
        Geom::Point3d.new(2, 2, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(432.11, 69.6534, 20), # World
        Geom::Point3d.new(2, 3, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(420.11, 69.6534, 20), # World
        Geom::Point3d.new(1, 3, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(28026, Geom::Point3d.new(424.14, 69.6534, 13.9726), expected, true)
  end

  def test_uv_tile_at_distorted_to_face_at_angle
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(419.977, 38.2457, -20), # World
        Geom::Point3d.new(-8, 2, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(429.977, 55.5662, -20), # World
        Geom::Point3d.new(-7, 2, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(460.477, 108.394, 20), # World
        Geom::Point3d.new(-7, 3, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(454.477, 98.0014, 20), # World
        Geom::Point3d.new(-8, 3, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27997, Geom::Point3d.new(440.956, 74.5822, -3.01727), expected, true)
  end

  def test_uv_tile_at_distorted_to_perpendicular
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(453.11, 23.1102, -20), # World
        Geom::Point3d.new(-19, 2, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(453.11, 43.1102, -20), # World
        Geom::Point3d.new(-18, 2, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(453.11, 192.11, 20), # World
        Geom::Point3d.new(-18, 3, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(453.11, 180.11, 20), # World
        Geom::Point3d.new(-19, 3, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(28006, Geom::Point3d.new(453.11, 111.432, -0.796326), expected, true)
  end

  def test_uv_tile_at_projected_affine_to_parallel
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(298.11, 0, 10), # World
        Geom::Point3d.new(0, 4, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(308.11, 0, 10), # World
        Geom::Point3d.new(1, 4, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(308.11, 0, 30), # World
        Geom::Point3d.new(1, 5, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(298.11, 0, 30), # World
        Geom::Point3d.new(0, 5, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27916, Geom::Point3d.new(305, 69.6534, 14), expected, true)
  end

  def test_uv_tile_at_projected_affine_to_at_angle
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(338.111, 0, -10), # World
        Geom::Point3d.new(4, 3, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(348.111, 0, -10 ), # World
        Geom::Point3d.new(5, 3, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(348.111, 0, 10), # World
        Geom::Point3d.new(5, 4, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(338.111, 0, 10), # World
        Geom::Point3d.new(4, 4, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27934, Geom::Point3d.new(340.894, 74.4758, -2.49358), expected, true)
  end

  def test_uv_tile_at_projected_affine_to_perpendicular
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(348.111, 0, 10), # World
        Geom::Point3d.new(5, 4, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(358.111, 0, 10), # World
        Geom::Point3d.new(6, 4, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(358.111, 0, 30), # World
        Geom::Point3d.new(6, 5, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(348.111, 0, 30), # World
        Geom::Point3d.new(5, 5, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(27952, Geom::Point3d.new(353.11, 114, 20.9797), expected, true)
  end

  def test_uv_tile_at_projected_not_affine_to_parallel
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(523.11, 0, -20), # World
        Geom::Point3d.new(1, 2, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(543.11, 0, -20), # World
        Geom::Point3d.new(2, 2, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(532.11, 0, 20), # World
        Geom::Point3d.new(2, 3, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(520.11, 0, 20), # World
        Geom::Point3d.new(1, 3, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(28090, Geom::Point3d.new(524.14, 69.6534, 13.9726), expected, true)
  end

  def test_uv_tile_at_projected_not_affine_to_at_angle
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(543.11, 0, -20), # World
        Geom::Point3d.new(2, 2, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(563.11, 0, -20), # World
        Geom::Point3d.new(3, 2, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(544.11, 0, 20), # World
        Geom::Point3d.new(3, 3, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(532.11, 0, 20), # World
        Geom::Point3d.new(2, 3, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(28072, Geom::Point3d.new(540.956, 74.5822, -3.01727), expected, true)
  end

  def test_uv_tile_at_projected_not_affine_to_perpendicular
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    expected = [
      [
        Geom::Point3d.new(543.11, 0, -20), # World
        Geom::Point3d.new(2, 2, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(563.11, 0, -20), # World
        Geom::Point3d.new(3, 2, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(544.11, 0, 20 ), # World
        Geom::Point3d.new(3, 3, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(532.11, 0, 20), # World
        Geom::Point3d.new(2, 3, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(28081, Geom::Point3d.new(453.11, 111.432, -0.796326), expected, true)
  end

  def test_uv_tile_at_SKEXT3298
    skip('Fixed in SU2022.0') if Sketchup.version.to_f < 22.0
    position = Geom::Point3d.new(2.552132580461148, 355.1967079959961, 0.0)
    expected = [
      [
        Geom::Point3d.new(3.72908, 393.77, 0), # World
        Geom::Point3d.new(-8, 0, 0), # UV (0, 0)
      ],
      [
        Geom::Point3d.new(2.22821, 344.581, 0), # World
        Geom::Point3d.new(-7, 0, 0), # UV (1, 0)
      ],
      [
        Geom::Point3d.new(2.22821, 344.581, 70.8661), # World
        Geom::Point3d.new(-7, 1, 0), # UV (1, 1)
      ],
      [
        Geom::Point3d.new(3.72908, 393.77, 70.8661), # World
        Geom::Point3d.new(-8, 1, 0), # UV (0, 1)
      ],
    ]
    assert_uv_tile_at(28052, position, expected, true, test_model: 'SKEXT-3298.skp')
  end

  def test_uv_tile_at_compatibility_with_position_material_affine
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(27806, Geom::Point3d.new(25, 0, 35), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_distorted
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(28026, Geom::Point3d.new(424.14, 69.6534, 13.9726), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_distorted_at_angle
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(27997, Geom::Point3d.new(440.956, 74.5822, -3.01727), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_distorted_perpendicular
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(28006, Geom::Point3d.new(453.11, 111.432, -0.796326), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_projection_affine
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(27916, Geom::Point3d.new(305, 69.6534, 14), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_projection_affine_at_angle
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(27934, Geom::Point3d.new(340.894, 74.4758, -2.49358), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_projection_affine_perpendicular
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(27952, Geom::Point3d.new(353.11, 114, 20.9797), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_projection_distorted
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(28090, Geom::Point3d.new(524.14, 69.6534, 13.9726), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_projection_distorted_at_angle
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(28072, Geom::Point3d.new(540.956, 74.5822, -3.01727), true)
  end

  def test_uv_tile_at_compatibility_with_position_material_projection_distorted_perpendicular
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    assert_uv_tile_at_remap(28081, Geom::Point3d.new(453.11, 111.432, -0.796326), true)
  end

  def test_uv_tile_at_too_few_arguments_zero
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.uv_tile_at
    end
  end

  def test_uv_tile_at_too_few_arguments_one
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.uv_tile_at(ORIGIN)
    end
  end

  def test_uv_tile_at_too_few_arguments_too_many
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.uv_tile_at(ORIGIN, true, 123)
    end
  end

  def test_uv_tile_at_wrong_argument_point_string
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    # Should have been TypeError, but our existing logic for points uses ArgumentError.
    assert_raises(ArgumentError) do
      face.uv_tile_at('Hello', true)
    end
  end


  # ========================================================================== #
  # method Sketchup::Face.texture_positioned?

  def test_texture_positioned_Query_no_material
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    refute(face.texture_positioned?(true), "front face positioned")
    refute(face.texture_positioned?(false), "back face positioned")
  end

  def test_texture_positioned_Query_material_not_positioned
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    material = create_test_material('UV-Tile.png')
    face = create_face
    face.material = material
    face.back_material = material
    refute(face.texture_positioned?(true), "front face positioned")
    refute(face.texture_positioned?(false), "back face positioned")
  end

  def test_texture_positioned_Query_positioned
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    material = create_test_material('UV-Tile.png')
    face = create_face
    mapping = [
      Geom::Point3d.new(10, 20, 0), # World 
      Geom::Point3d.new(0, 0, 0),   # UV
    ]
    face.position_material(material, mapping, true)
    assert(face.texture_positioned?(true), "front face not positioned")
    refute(face.texture_positioned?(false), "back face positioned")
    face.position_material(material, mapping, false)
    assert(face.texture_positioned?(false), "back face not positioned")
  end

  def test_texture_positioned_Query_too_few_arguments
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.texture_positioned?
    end
  end

  def test_texture_positioned_Query_too_many_arguments
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.texture_positioned?(true, true)
    end
  end


  # ========================================================================== #
  # method Sketchup::Face.clear_texture_position

  def test_clear_texture_position
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    face = create_face
    material = create_material
    mapping = [
      Geom::Point3d.new(0, 0, 0), # World coordinate
      Geom::Point3d.new(0, 0, 0), # UV coordinate
    ]
    projection = Geom::Vector3d.new(1, 2, 3)
    face.position_material(material, mapping, true, projection)
    face.position_material(material, mapping, false, projection)
    assert_equal(projection.normalize, face.get_texture_projection(true))
    assert_equal(projection.normalize, face.get_texture_projection(false))

    # Front side
    face.clear_texture_position(true)

    refute(face.texture_positioned?(true))
    refute(face.texture_projected?(true))
    assert_nil(face.get_texture_projection(true))

    assert(face.texture_positioned?(false))
    assert(face.texture_projected?(false))
    assert_equal(projection.normalize, face.get_texture_projection(false))

    # Back side
    face.clear_texture_position(false)

    refute(face.texture_positioned?(false))
    refute(face.texture_projected?(false))
    assert_nil(face.get_texture_projection(false))
  end

  def test_clear_texture_position_material_with_no_texture
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    face = create_face
    face.material = Sketchup.active_model.materials.add('TestMaterial')
    face.clear_texture_position(true)
  end

  def test_clear_texture_position_no_material
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    face = create_face
    face.clear_texture_position(true)
  end

  def test_clear_texture_position_too_few_arguments
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    face = create_face
    assert_raises(ArgumentError) do
      face.clear_texture_position
    end
  end

  def test_clear_texture_position_too_many_arguments
    skip('Added in SU2022.0') if Sketchup.version.to_f < 22.0
    face = create_face
    assert_raises(ArgumentError) do
      face.clear_texture_position(true, true)
    end
  end
  
  # ========================================================================== #
  # method Sketchup::Face.texture_projected?

  def test_texture_projected_Query_no_material
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    refute(face.texture_projected?(true), "front face projected")
    refute(face.texture_projected?(false), "back face projected")
  end

  def test_texture_projected_Query_material_not_positioned
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    material = create_test_material('UV-Tile.png')
    face = create_face
    face.material = material
    face.back_material = material
    refute(face.texture_projected?(true), "front face projected")
    refute(face.texture_projected?(false), "back face projected")
  end

  def test_texture_projected_Query_positioned
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    material = create_test_material('UV-Tile.png')
    face = create_face
    mapping = [
      Geom::Point3d.new(10, 20, 0), # World 
      Geom::Point3d.new(0, 0, 0),   # UV
    ]
    face.position_material(material, mapping, true)
    refute(face.texture_projected?(true), "front face projected")
    refute(face.texture_projected?(false), "back face projected")
  end

  def test_texture_projected_Query_projected
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    material = create_test_material('UV-Tile.png')
    face = create_face
    mapping = [
      Geom::Point3d.new(10, 20, 0), # World 
      Geom::Point3d.new(0, 0, 0),   # UV
    ]
    direction = Geom::Vector3d.new(1, 2, 3)
    face.position_material(material, mapping, true, direction)
    assert(face.texture_projected?(true), "front face projected")
    refute(face.texture_projected?(false), "back face projected")
    face.position_material(material, mapping, false, direction)
    assert(face.texture_projected?(false), "back face projected")
  end

  def test_texture_projected_Query_too_few_arguments
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.texture_projected?
    end
  end

  def test_texture_projected_Query_too_many_arguments
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    assert_raises(ArgumentError) do
      face.texture_projected?(true, true)
    end
  end

  def test_texture_projected_Query_mapped_by_ui
    skip('Added in SU2021.1') if Sketchup.version.to_f < 21.1
    # In case the UI logic should differ from the API logic when it comes to
    # applying textures.
    model = Sketchup.active_model
    path = get_test_case_file('ui-textured.skp')
    definition = model.definitions.load(path)
    definitions = model.definitions

    get_face = ->(definition_name) {
      definition = model.definitions[definition_name]
      definition.entities.grep(Sketchup::Face).first
    }

    face = get_face.call('MaterialNotPositioned')
    refute(face.texture_positioned?(true), "MaterialNotPositioned")
    refute(face.texture_projected?(true), "MaterialNotPositioned")

    face = get_face.call('MaterialPositioned')
    assert(face.texture_positioned?(true), "MaterialPositioned")
    refute(face.texture_projected?(true), "MaterialPositioned")

    face = get_face.call('MaterialProjectedParallel')
    assert(face.texture_positioned?(true), "MaterialProjectedParallel")
    assert(face.texture_projected?(true), "MaterialProjectedParallel")

    face = get_face.call('MaterialProjectedPerpendicular')
    assert(face.texture_positioned?(true), "MaterialProjectedPerpendicular")
    assert(face.texture_projected?(true), "MaterialProjectedPerpendicular")

    face = get_face.call('MaterialProjectedAtAngle')
    assert(face.texture_positioned?(true), "MaterialProjectedAtAngle")
    assert(face.texture_projected?(true), "MaterialProjectedAtAngle")
  end


  # ========================================================================== #
  # method Sketchup::Face.pushpull

  def test_pushpull_api_example
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
    status = face.pushpull(100, true)
  end

  def test_pushpull_return_type
    face = create_face

    result = face.pushpull(100, true)
    assert_nil(result)
  end

  def test_pushpull_entity_count_face_not_copied
    face = create_face
    pre_pushpull = Sketchup.active_model.entities.length
    face.pushpull(100, false)
    face.pushpull(100, false)
    post_pushpull = Sketchup.active_model.entities.length
    entity_increase = post_pushpull - pre_pushpull
    assert_equal(13, entity_increase)
  end

  def test_pushpull_entity_count_face_copied
    face = create_face
    new_face = nil
    pre_pushpull = Sketchup.active_model.entities.length
    face.pushpull(100, true)
    face.all_connected.grep(Sketchup::Face).each do |e|
      new_face = e if (e.normal == face.normal) && (e != face)
    end
    new_face.pushpull(100, true)
    post_pushpull = Sketchup.active_model.entities.length
    entity_increase = post_pushpull - pre_pushpull

    assert_equal(26, entity_increase)
  end

  def test_pushpull_arity
    assert_equal(-1, Sketchup::Face.instance_method(:pushpull).arity)
  end

  def test_pushpull_invalid_arguments
    face = create_face
    material = create_material
    face.material = material

    assert_raises(TypeError) do
      face.pushpull("st", "ri")
    end

    assert_raises(TypeError) do
      face.pushpull(false, false)
    end

    #assert_raises(ArgumentError) do
    #  face.pushpull(1, 2)
    #end

    assert_raises(TypeError) do
      face.pushpull(nil, nil)
    end
  end

  def test_pushpull_copy_face_direction
    face = create_face
    face.pushpull(100, true)

    # Pulled face should point upwards.
    assert_equal(face.normal, [0, 0, 1])

    # The copied face at the bottom should remain pointing upwards also. This
    # behavior changed in 2021.1 to point these downwards but we are keeping
    # the legacy API behavior.
    bottom_face = face.all_connected.grep(Sketchup::Face).find do |face|
      face.normal == Z_AXIS
    end
    refute_nil(bottom_face)
  end

  # ========================================================================== #
  # method Sketchup::Face.reverse!

  def test_reverse_Bang_api_example
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
    status = face.reverse!
  end

  def test_reverse_Bang_return_type
    face = create_face

    result = face.reverse!
    assert_kind_of(Sketchup::Face, result)
  end

  def test_reverse_Bang_return_value
    face = create_face
    normal = face.normal
    result = face.reverse!
    assert_equal(normal, face.normal.reverse!)
  end

  def test_reverse_Bang_arity
    assert_equal(0, Sketchup::Face.instance_method(:reverse!).arity)
  end

  def test_reverse_Bang_invalid_arguments
    face = create_face
    material = create_material
    face.material = material

    assert_raises(ArgumentError) do
      face.reverse!("st")
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.set_texture_projection

  def test_set_texture_projection_removed
    skip('Removed in SU2021.1') if Sketchup.version.to_f < 21.1
    face = create_face
    material = create_material
    face.material = material
    
    assert_raises(NotImplementedError) do
      face.set_texture_projection(Y_AXIS, true)
    end
    assert_nil(face.get_texture_projection(true))
    refute(face.texture_projected?(true))
  end


  # ========================================================================== #
  # method Sketchup::Face.vertices

  def test_vertices_api_example
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
    vertices = face.vertices
  end

  def test_vertices_return_type
    face = create_face
    result = face.vertices
    assert_kind_of(Array, result)
  end

  def test_vertices_return_value
    face = create_face
    result = face.vertices
    assert(result.all? { |entity| entity.is_a?(Sketchup::Vertex) },
      'Not all entities returned were vertices.')
  end

  def test_vertices_return_array_length
    face = create_face
    result = face.vertices
    assert_equal(result.length, 4)
  end

  def test_vertices_arity
    assert_equal(0, Sketchup::Face.instance_method(:vertices).arity)
  end

  def test_vertices_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.vertices("Strings are not valid!")
    end

    assert_raises(ArgumentError) do
      face.vertices(["Can't use array"])
    end

    assert_raises(ArgumentError) do
      face.vertices(12)
    end

    assert_raises(ArgumentError) do
      face.vertices(false)
    end

    assert_raises(ArgumentError) do
      face.vertices(nil)
    end
  end

end

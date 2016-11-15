# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Chris Fullmer


require "testup/testcase"


# class Sketchup::Face
# http://www.sketchup.com/intl/en/en/developer/docs/ourdoc/face
class TC_Sketchup_Face < TestUp::TestCase

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

  def create_face
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0, 0, 0], [100, 0, 0], [100, 100, 0], [0, 100, 0])
    face.reverse!
    face
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
  # http://www.sketchup.com/intl/en/en/developer/docs/ourdoc/face#all_connected

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#area

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#back_material

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#back_material=

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
    assert(false, "Fix this for SU2016") # Create orphan operation.
    skip("Broken in SU2014") if Sketchup.version.to_i == 14
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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#classify_point

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#edges

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#followme

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#get_glued_instances

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#get_texture_projection

  def test_get_texture_projection_api_example
    model = Sketchup.active_model
    entities = model.active_entities
    materials = model.materials
    # Create a face and add it to the model entities
    pts = []
    pts[0] = [0, 0, 1]
    pts[1] = [10, 0, 1]
    pts[2] = [10, 10, 1]
    face = entities.add_face(pts)
    # Export an image to use as a texture
    path = Sketchup.temp_dir
    full_name = File.join(path, "temp_image.jpg")
    model.active_view.write_image(full_name, 500, 500, false, 0.0)
    # Create a material and assign the texture to it
    material = materials.add("Test Material")
    material.texture = full_name
    # Assign the new material to our face we created
    face.material = material
    # Set the projection of the applied material
    face.set_texture_projection(face.normal, true)
    # Get the projection of the applied material
    vector = face.get_texture_projection(true)
  end

  def test_get_texture_projection_return_type
    face = create_face
    material = create_material
    face.material = material
    vector = [rand, rand, rand]
    face.set_texture_projection(vector, true)
    result = face.get_texture_projection(true)

    assert_kind_of(Geom::Vector3d, result)
  end

  def test_get_texture_projection_back_face_return_type
    face = create_face
    material = create_material
    face.back_material = material
    vector = [rand, rand, rand]
    face.set_texture_projection(vector, false)
    result = face.get_texture_projection(false)

    assert_kind_of(Geom::Vector3d, result)
  end

  def test_get_texture_projection_given_vector_matched_returned_vector
    face = create_face
    material = create_material
    face.back_material = material
    vector = [rand, rand, rand]
    vector.normalize!
    face.set_texture_projection(vector, false)
    result = face.get_texture_projection(false)

    assert_equal(true, (result == vector), "Vector #{vector.to_s} was assigned
      to the projection, but #{result.to_s} was returned.
      They should compare equal.")
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

  #def test_get_texture_projection_invalid_arguments
    # No tests for invalid arguments, since no incorrect arguments are throwing
    # errors.  We should consider adding better error handling for incorrect
    # arguments to most of the methods in this class.  There are many arguments
    # that are allowed, even though they are wrong.
  #end

  # ========================================================================== #
  # method Sketchup::Face.get_UVHelper
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#get_UVHelper

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#loops

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
  # method Sketchup::Face.material
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#material

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
  # method Sketchup::Face.material=
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#material=

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
    assert(false, "Fix this for SU2016") # Create orphan operation.
    skip("Broken in SU2014") if Sketchup.version.to_i == 14
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
  # method Sketchup::Face.mesh
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#mesh

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

  def test_mesh_return_type
    face = create_face_with_hole

    # Valid flags include:
    # 0: Include PolygonMeshPoints,
    # 1: Include PolygonMeshUVQFront,
    # 2: Include PolygonMeshUVQBack,
    # 4: Include PolygonMeshNormals.
    # Add these numbers together to combine flags.
    # A value of 7 will include all flags.
    result = face.mesh(7)
    assert_kind_of(Geom::PolygonMesh, result)
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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#normal

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#outer_loop

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#plane

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
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#position_material

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

  def test_position_material_arity
    assert_equal(3, Sketchup::Face.instance_method(:position_material).arity)
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
  # method Sketchup::Face.pushpull
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#pushpull

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
    new_face = []
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


  # ========================================================================== #
  # method Sketchup::Face.reverse!
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#reverse!

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

    assert_raises(TypeError) do
      face.pushpull("st")
    end

    assert_raises(TypeError) do
      face.pushpull(false)
    end

    #assert_raises(ArgumentError) do
    #  face.pushpull(1, 2)
    #end

    assert_raises(TypeError) do
      face.pushpull(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::Face.set_texture_projection
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#set_texture_projection

  def test_set_texture_projection_api_example
    model = Sketchup.active_model
    entities = model.active_entities
    materials = model.materials
    # Create a face and add it to the model entities
    pts = []
    pts[0] = [0, 0, 1]
    pts[1] = [10, 0, 1]
    pts[2] = [10, 10, 1]
    face = entities.add_face(pts)
    # Export an image to use as a texture
    path = Sketchup.temp_dir
    full_name = File.join(path, "temp_image.jpg")
    model.active_view.write_image(full_name, 500, 500, false, 0.0)
    # Create a material and assign the texture to it
    material = materials.add "Test Material"
    material.texture = full_name
    # Assign the new material to our face we created
    face.material = material
    # Returns nil if not successful, path if successful
    result = face.set_texture_projection(face.normal, true)
  end

  def test_set_texture_projection_return_type
    face = create_face
    material = create_material
    face.material = material
    vector = [rand, rand, rand]
    result = face.set_texture_projection(vector, true)

    assert_kind_of(TrueClass, result)
  end

  def test_set_texture_projection_back_face_return_type
    face = create_face
    material = create_material
    face.back_material = material
    vector = [rand, rand, rand]
    result = face.set_texture_projection(vector, false)

    assert_kind_of(TrueClass, result)
  end

  def test_set_texture_projection_overwrite_existing_projection
    face = create_face
    material = create_material
    face.material = material

    vector = Geom::Vector3d.new(rand, rand, rand).normalize
    face.set_texture_projection(vector, true)

    vector2 = Geom::Vector3d.new(rand, rand, rand).normalize
    face.set_texture_projection(vector2, true)
    returned_vector = face.get_texture_projection(true)

    assert_equal(vector2, returned_vector)
  end

  def test_set_texture_projection_arity
    assert_equal(2, Sketchup::Face.instance_method(
      :set_texture_projection).arity)
  end

  def test_set_texture_projection_invalid_arguments
    face = create_face

    assert_raises(ArgumentError) do
      face.set_texture_projection("st", "ri")
    end

    assert_raises(ArgumentError) do
      face.set_texture_projection(false, false)
    end

    assert_raises(ArgumentError) do
      face.set_texture_projection(1, 2)
    end

    #assert_raises(TypeError) do
    #  face.set_texture_projection(nil,nil)
    #end
  end


  # ========================================================================== #
  # method Sketchup::Face.vertices
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/face#vertices

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

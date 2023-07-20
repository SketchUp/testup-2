# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Edge
class TC_Sketchup_Edge < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    entities = Sketchup.active_model.entities.to_a
    selection = Sketchup.active_model.selection.to_a
    start_with_empty_model()
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # Local test utilities.
  # If any of these utilities are needed in other tescases they should be moved
  # to TestUp's utility library.

  def create_test_edge_shared_by_two_faces
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    face.reverse!
    edge = face.edges.first
    face.pushpull(100, true)
    edge
  end


  # ========================================================================== #
  # method Sketchup::Edge.all_connected

  def test_all_connected_api_example
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge = face.edges.first
    face.pushpull(100, true)
    # Returns an array of all the entities that makes up the cube, 6 faces and
    # 12 edges.
    edge.all_connected
  end

  def test_all_connected
    edge = create_test_edge_shared_by_two_faces()

    entities = edge.all_connected
    assert_kind_of(Array, entities)

    assert_equal(18, entities.size)

    edges = entities.grep(Sketchup::Edge)
    assert_equal(12, edges.size,
      "Returned array did not contain correct number of edges.")

    faces = entities.grep(Sketchup::Face)
    assert_equal(6, faces.size,
      "Returned array did not contain correct number of faces.")

    assert(entities.all? { |entity| entity.valid? },
      "Returned entities were not all valid.")

    assert(entities.all? { |entity| entity.parent == edge.parent },
      "Returned entities did not come from the correct parent.")

    assert(entities.all? { |entity| entity.model == edge.model },
      "Returned entities did not come from the correct model.")
  end

  def test_all_connected_arity
    assert_equal(0, Sketchup::Edge.instance_method(:all_connected).arity)
  end

  def test_all_connected_incorrect_number_of_arguments
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(ArgumentError) do
      edge.all_connected(1)
    end
  end


  # ========================================================================== #
  # method Sketchup::Edge.common_face

  def test_common_face_api_example
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge1, edge2, edge3, edge4 = face.edges
    # Returns the face shared by both edges.
    edge1.common_face(edge2)
  end

  def test_common_face_edges_has_common_face
    edge1 = create_test_edge_shared_by_two_faces()
    face = edge1.faces.first
    edge2 = face.edges.find { |edge| edge != edge1 }

    result = edge1.common_face(edge2)
    assert_kind_of(Sketchup::Face, result)

    assert(result.valid?,
      "Returned face was not valid.")

    assert_equal(edge1.parent, result.parent,
      "Returned face did not come from the correct parent.")

    assert_equal(edge1.model, result.model,
      "Returned face did not come from the correct model.")
  end

  def test_common_face_edges_has_no_common_face
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([0, 0, 0], [1, 0, 0])
    edge2 = entities.add_line([0, 1, 0], [1, 1, 0])

    result = edge1.common_face(edge2)
    assert_nil(result)
  end

  def test_common_face_arity
    assert_equal(1, Sketchup::Edge.instance_method(:common_face).arity)
  end

  def test_common_face_incorrect_number_of_arguments_zero
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(ArgumentError) do
      edge.common_face()
    end
  end

  def test_common_face_incorrect_number_of_arguments_two
    edge1 = create_test_edge_shared_by_two_faces()
    edge2 = edge1.faces.first.edges.first

    assert_raises(ArgumentError) do
      edge1.common_face(edge2, edge2)
    end
  end

  def test_common_face_invalid_argument_nil
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(TypeError) do
      edge.common_face(nil)
    end
  end

  def test_common_face_invalid_argument_string
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(TypeError) do
      edge.common_face("This is not an edge")
    end
  end

  def test_common_face_invalid_argument_number
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(TypeError) do
      edge.common_face(10010101011)
    end
  end


  # ========================================================================== #
  # method Sketchup::Edge.curve

  def test_curve_api_example
    entities = Sketchup.active_model.active_entities
    edges = entities.add_curve([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    # Returns a Sketchup::Curve entity.
    edges[0].curve
  end

  def test_curve_edges_has_curve
    entities = Sketchup.active_model.active_entities
    edges = entities.add_curve([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge = edges.first

    result = edge.curve
    assert_kind_of(Sketchup::Curve, result)

    assert(result.valid?,
      "Returned curve was not valid.")

    assert_equal(edge.parent, result.parent,
      "Returned curve did not come from the correct parent.")

    assert_equal(edge.model, result.model,
      "Returned curve did not come from the correct model.")
  end

  def test_curve_edges_has_arc_curve
    entities = Sketchup.active_model.active_entities
    edges = entities.add_arc([0,0,0], X_AXIS, Z_AXIS, 1.m, 0, 90.degrees)
    edge = edges.first

    result = edge.curve
    assert_kind_of(Sketchup::ArcCurve, result)

    assert(result.valid?,
      "Returned curve was not valid.")

    assert_equal(edge.parent, result.parent,
      "Returned curve did not come from the correct parent.")

    assert_equal(edge.model, result.model,
      "Returned curve did not come from the correct model.")
  end

  def test_curve_edges_has_no_curve
    entities = Sketchup.active_model.active_entities
    edges = entities.add_edges([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge = edges.first

    result = edge.curve
    assert_nil(result)
  end

  def test_curve_arity
    assert_equal(0, Sketchup::Edge.instance_method(:curve).arity)
  end

  def test_curve_incorrect_number_of_arguments
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(ArgumentError) do
      edge.curve(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Edge.end

  def test_end_api_example
    entities = Sketchup.active_model.active_entities
    edge = entities.add_line([0,0,0], [100,0,0])
    # Returns a point Point3d(0.0, 0.0, 100.0).
    edge.end
  end

  def test_end
    entities = Sketchup.active_model.active_entities
    edge = entities.add_line([0,0,0], [100,0,0])

    result = edge.end
    assert_kind_of(Sketchup::Vertex, result)

    assert(result.valid?,
      "Returned vertex was not valid.")

    assert_equal(Geom::Point3d.new(100, 0, 0), result.position,
      "Returned vertex did have the expected position.")

    assert_equal(edge.parent, result.parent,
      "Returned vertex did not come from the correct parent.")

    assert_equal(edge.model, result.model,
      "Returned vertex did not come from the correct model.")
  end

  def test_end_arity
    assert_equal(0, Sketchup::Edge.instance_method(:end).arity)
  end

  def test_end_incorrect_number_of_arguments
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(ArgumentError) do
      edge.curve(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Edge.explode_curve

  def test_explode_curve_api_example
    entities = Sketchup.active_model.active_entities
    edges = entities.add_curve([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edges[0].explode_curve
  end

  def test_explode_curve_edges_has_curve
    entities = Sketchup.active_model.active_entities
    edges = entities.add_curve([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge = edges.first
    curve = edge.curve

    result = edge.explode_curve
    assert_equal(edge, result)

    assert(curve.deleted?, "Curve was not exploded.")
  end

  def test_explode_curve_edges_has_arc_curve
    entities = Sketchup.active_model.active_entities
    edges = entities.add_arc([0,0,0], X_AXIS, Z_AXIS, 1.m, 0, 90.degrees)
    edge = edges.first
    curve = edge.curve

    result = edge.explode_curve
    assert_equal(edge, result)

    assert(curve.deleted?, "Curve was not exploded.")
  end

  def test_explode_curve_edges_has_no_curve
    entities = Sketchup.active_model.active_entities
    edges = entities.add_edges([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge = edges.first

    result = edge.explode_curve
    assert_equal(edge, result)
  end

  def test_explode_curve_arity
    assert_equal(0, Sketchup::Edge.instance_method(:explode_curve).arity)
  end

  def test_explode_curve_incorrect_number_of_arguments
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(ArgumentError) do
      edge.explode_curve(nil)
    end
  end


  # ========================================================================== #
  # method Sketchup::Edge.faces

  def test_faces_api_example
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge = face.edges.first
    face.pushpull(100, true)

    edge_faces = edge.faces
    # edge_faces => [#<Sketchup::Face:0x7614030>, #<Sketchup::Face:0x761fe20>]
  end

  def test_faces
    edge = create_test_edge_shared_by_two_faces()

    assert_kind_of(Array, edge.faces)

    assert_equal(2, edge.faces.size)

    assert(edge.faces.all? { |object| object.is_a?(Sketchup::Face) },
      "Returned array did not contain just faces.")

    assert(edge.faces.all? { |entity| entity.valid? },
      "Returned entities were not all valid.")

    assert(edge.faces.all? { |entity| entity.parent == edge.parent },
      "Returned entities did not come from the correct parent.")

    assert(edge.faces.all? { |entity| entity.model == edge.model },
      "Returned entities did not come from the correct model.")
  end

  def test_faces_arity
    assert_equal(0, Sketchup::Edge.instance_method(:faces).arity)
  end

  def test_faces_incorrect_number_of_arguments
    edge = create_test_edge_shared_by_two_faces()

    assert_raises(ArgumentError) do
      edge.faces(1)
    end
  end


  # ========================================================================== #
  # method Sketchup::Edge.find_faces

  def test_find_faces_api_example
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([0,0,0], [100,0,0])
    edge2 = entities.add_line([100,0,0], [100,100,0])
    edge3 = entities.add_line([100,100,0], [0,0,0])
    edge1.find_faces
  end

  def test_find_faces_triangle
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([0,0,0], [100,0,0])
    edge2 = entities.add_line([100,0,0], [100,100,0])
    edge3 = entities.add_line([100,100,0], [0,0,0])

    result = edge1.find_faces
    assert_equal(1, result)
  end

  def test_find_faces_find_multiple_faces
    edge = create_test_edge_shared_by_two_faces()
    entities = Sketchup.active_model.active_entities
    faces = entities.grep(Sketchup::Face)
    entities.erase_entities(faces)

    result = edge.find_faces
    assert_equal(2, result)

    faces = entities.grep(Sketchup::Face)
    assert_equal(2, faces.size)
  end

  def test_find_faces_lonely_edge
    entities = Sketchup.active_model.active_entities
    edge = entities.add_line([0,0,0], [100,0,0])

    result = edge.find_faces
    assert_equal(0, result)
  end

  def test_find_faces_arity
    assert_equal(0, Sketchup::Edge.instance_method(:find_faces).arity)
  end

  def test_find_faces_incorrect_number_of_arguments
    entities = Sketchup.active_model.active_entities
    edge = entities.add_line([0,0,0], [100,0,0])

    assert_raises(ArgumentError) do
      edge.find_faces(nil)
    end
  end

  def test_find_faces_face_orientation_xy_on_ground
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([1,1,0], [2,1,0])
    edge2 = entities.add_line([2,1,0], [2,2,0])
    edge3 = entities.add_line([2,2,0], [1,1,0])

    face_count = edge1.find_faces
    assert_equal(1, face_count)
    face = entities.grep(Sketchup::Face)[0]
    assert_equal(face.normal, [0,0,-1])
  end

  def test_find_faces_face_orientation_xy_winding_counterclockwise
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([1,1,10], [2,1,10])
    edge2 = entities.add_line([2,1,10], [2,2,10])
    edge3 = entities.add_line([2,2,10], [1,1,10])

    face_count = edge1.find_faces
    assert_equal(1, face_count)
    face = entities.grep(Sketchup::Face)[0]
    assert_equal(face.normal, [0,0,1])
  end

  def test_find_faces_face_orientation_xy_winding_clockwise
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([1,1,10], [2,2,10])
    edge2 = entities.add_line([2,2,10], [2,1,10])
    edge3 = entities.add_line([2,1,10], [1,1,10])

    face_count = edge1.find_faces
    assert_equal(1, face_count)
    face = entities.grep(Sketchup::Face)[0]
    assert_equal(face.normal, [0,0,-1])
  end

  def test_find_faces_face_orientation_xz_winding_counterclockwise
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([1,0,1], [2,0,1])
    edge2 = entities.add_line([2,0,1], [2,0,2])
    edge3 = entities.add_line([2,0,2], [1,0,1])

    face_count = edge1.find_faces
    assert_equal(1, face_count)
    face = entities.grep(Sketchup::Face)[0]
    assert_equal(face.normal, [0,-1,0])
  end

  def test_find_faces_face_orientation_xz_winding_clockwise
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([1,0,1], [2,0,2])
    edge2 = entities.add_line([2,0,2], [2,0,1])
    edge3 = entities.add_line([2,0,1], [1,0,1])

    face_count = edge1.find_faces
    assert_equal(1, face_count)
    face = entities.grep(Sketchup::Face)[0]
    assert_equal(face.normal, [0,1,0])
  end

  def test_find_faces_face_orientation_yz_winding_counterclockwise
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([0,1,1], [0,2,1])
    edge2 = entities.add_line([0,2,1], [0,2,2])
    edge3 = entities.add_line([0,2,2], [0,1,1])

    face_count = edge1.find_faces
    assert_equal(1, face_count)
    face = entities.grep(Sketchup::Face)[0]
    assert_equal(face.normal, [1,0,0])
  end

  def test_find_faces_face_orientation_yz_winding_clockwise
    entities = Sketchup.active_model.active_entities
    edge1 = entities.add_line([0,1,1], [0,2,2])
    edge2 = entities.add_line([0,2,2], [0,2,1])
    edge3 = entities.add_line([0,2,1], [0,1,1])

    face_count = edge1.find_faces
    assert_equal(1, face_count)
    face = entities.grep(Sketchup::Face)[0]
    assert_equal(face.normal, [-1,0,0])
  end

end # class

# Copyright:: Copyright 2016-2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"
require_relative "utils/image_helper"


# class Sketchup::Entities
class TC_Sketchup_Entities < TestUp::TestCase

  include TestUp::SketchUpTests::ImageHelper

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end

  def basic_setup_for_SU41171
    start_with_empty_model
    mm = Sketchup.active_model
    g1 = mm.entities.add_group
    pts = [
      [0, 0, 0],
      [10, 0, 0],
      [10, 12, 0],
      [0, 12, 0]
    ]
    face1 = g1.entities.add_face(pts)
    face1.pushpull(-8)
    return g1
  end

  def add_test_face
    model = Sketchup.active_model
    face = model.entities.add_face([0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0])
    return face
  end

  def add_instance
    face = add_test_face
    model = Sketchup.active_model
    group = model.entities.add_group(face)
    group.to_component
  end

  def create_test_mesh
    mesh = Geom::PolygonMesh.new
    mesh.add_point(Geom::Point3d.new(0, 0, 0))
    mesh.add_point(Geom::Point3d.new(1, 0, 0))
    mesh.add_point(Geom::Point3d.new(1, 1, 0))
    mesh.add_polygon([1, 2, 3])
    mesh
  end

  def setup_instance_test
    add_instance
    comp_inst = Sketchup.active_model.active_entities.first
    comp_inst.definition.entities.each { |entity|
      if entity.is_a?(Sketchup::Edge)
        if entity.start.position == Geom::Point3d.new(9, 0, 0)
          if entity.end.position == Geom::Point3d.new(9, 9, 0)
            return comp_inst, entity, entity.start.position, entity.end.position
          end
        end
      end
    }
  end

  def get_transform_points
    return [
      Geom::Point3d.new( 2,  0, 0),
      Geom::Point3d.new(-2,  0, 0),
      Geom::Point3d.new( 0,  2, 0),
      Geom::Point3d.new( 0, -2, 0)
    ]
  end

  def get_faces_points(face)
    points = []
    face.vertices.each do |vertex|
      points.push(vertex.position)
    end
    return points
  end

  def get_transformed_points(points)
    init_points = points
    shift_points = get_transform_points
    assert_equal(init_points.count, shift_points.count)
    points = []
    for i in 0..(init_points.count-1)
      points.push(init_points[i] + shift_points[i].to_a)
    end
    return points
  end

  def get_entities_faces(entities)
    entities.grep(Sketchup::Face)
  end

  def sort_points (points)
    return points.sort{ |p1,p2| p1.to_s <=> p2.to_s}
  end

  # ========================================================================== #
  # method Sketchup::Entities.transform_by_vectors_vectors

  def test_transform_by_vectors_vectors
    entities = Sketchup.active_model.entities
    face = add_test_face

    vectors = []
    points = get_transform_points
    points.each { |point| vectors.push(Geom::Vector3d.new(point.to_a)) }
    # Get the faces points for later comparison because the order will change
    # getting transformed.
    points = get_faces_points(face)
    # Apply the transformations to the vertices and make sure the expected value
    # is returned
    result = entities.transform_by_vectors(face.vertices, vectors)
    assert_kind_of(Sketchup::Entities, result)
    # Get the faces points and manually apply the transformations for
    # comparison.  The points have to be sorted for the comparision to work.
    face = get_entities_faces(entities)[0]
    test_points = sort_points(get_transformed_points(points))
    face_points = sort_points(get_faces_points(face))
    # Make sure the face has the expected number of points
    num_pnts = points.count
    assert_equal(num_pnts, face.vertices.count)
    # Loop through the points making sure they are in the expected positions.
    for i in 0..(num_pnts-1)
      assert_equal(test_points[i], face_points[i])
    end
  end

  def test_transform_by_vectors_points
    entities = Sketchup.active_model.entities
    face = add_test_face

    points = get_transform_points
    result = entities.transform_by_vectors(face.vertices, points)
    assert_kind_of(Sketchup::Entities, result)
  end

  def test_transform_by_vectors_transformations
    entities = Sketchup.active_model.entities
    face = add_test_face

    transformations = []
    points = get_transform_points
    points.each { |point| transformations.push(Geom::Transformation.new(point)) }
    result = entities.transform_by_vectors(face.vertices, transformations)
    assert_kind_of(Sketchup::Entities, result)
  end

  def test_transform_by_vectors_incorrect_number_of_arguments_zero
    entities = Sketchup.active_model.entities
    assert_raises(ArgumentError) {
      entities.transform_by_vectors
    }
  end

  def test_transform_by_vectors_incorrect_number_of_arguments_one
    entities = Sketchup.active_model.entities
    face = add_test_face

    assert_raises(ArgumentError) {
      entities.transform_by_vectors(face.vertices)
    }
  end

  def test_transform_by_vectors_incorrect_number_of_arguments_three
    skip("This method did not raise errors for too many arguments.")
    # Now we have to keep it like that... :(
    entities = Sketchup.active_model.entities
    face = add_test_face

    points = get_transform_points
    assert_raises(ArgumentError) {
      entities.transform_by_vectors(face.vertices, points, nil)
    }
  end

  def test_transform_by_vectors_array_size_mismatch
    skip("Fixed in SU2017") if Sketchup.version.to_i < 17
    entities = Sketchup.active_model.entities
    face = add_test_face

    vectors = [
      Geom::Vector3d.new( 2,  0, 0)
    ]
    assert_raises(ArgumentError) {
      entities.transform_by_vectors(face.vertices, vectors)
    }
  end

  # ========================================================================== #
  # method Sketchup::Entities.erase_entities

  def test_each_erase_entities_crash_run_by_itself
    # Test was formed from a bug issued by beta testers in SU2018 (SU-37674)
    # this test has the potential to crash sketchup, run it by itself
    start_with_empty_model
    add_test_face
    entities = Sketchup.active_model.entities
    assert_equal(5, entities.size)
    entities.each {|e| entities.erase_entities(e)}
    assert_equal(0, entities.size)
  end

  # ========================================================================== #
  # method Sketchup::Entities.add_text

  def test_add_text_point3d_as_position
    model = start_with_empty_model
    text = model.entities.add_text("su", Geom::Point3d.new(1, 2, 3))
    assert_kind_of(Sketchup::Text, text)
    assert_equal("su", text.text)
    assert_equal(Geom::Point3d.new(1, 2, 3), text.point)
  end

  def test_add_text_array_as_position
    model = start_with_empty_model
    text = model.entities.add_text("su", [1, 2, 3])
    assert_kind_of(Sketchup::Text, text)
    assert_equal(Geom::Point3d.new(1, 2, 3), text.point)
  end

  def test_add_text_vertex_as_position
    model = start_with_empty_model
    edge = model.entities.add_line([1, 2, 3], [9, 8, 7])
    vertex = edge.start
    text = model.entities.add_text("su", vertex)
    assert_kind_of(Sketchup::Text, text)
    assert_equal(Geom::Point3d.new(1, 2, 3), text.point)
  end

  def test_add_text_input_point_as_position
    model = start_with_empty_model
    input_point = Sketchup::InputPoint.new([1, 2, 3])
    text = model.entities.add_text("su", input_point)
    assert_kind_of(Sketchup::Text, text)
    assert_equal(Geom::Point3d.new(1, 2, 3), text.point)
  end

  def test_add_text_vector3d_as_leader
    model = start_with_empty_model
    text = model.entities.add_text("su", [1, 2, 3], Geom::Vector3d.new(4, 5, 6))
    assert_kind_of(Sketchup::Text, text)
    assert_equal(Geom::Vector3d.new(4, 5, 6), text.vector)
  end

  def test_add_text_array_as_leader
    model = start_with_empty_model
    text = model.entities.add_text("su", [1, 2, 3], [4, 5, 6])
    assert_kind_of(Sketchup::Text, text)
    assert_equal(Geom::Vector3d.new(4, 5, 6), text.vector)
  end

  def test_add_text_not_enough_arguments
    start_with_empty_model
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_text(nil)
    end
  end

  def test_add_text_too_many_arguments
    start_with_empty_model
    # This is legacy behavior.
    # No error thrown since we only check to make sure that they have the minimum
    # amount of arguments (which is 3).
    ent = Sketchup.active_model.entities.add_text("su", [1, 1, 1], [3, 3, 0], nil)
    assert_kind_of(Sketchup::Text, ent)
  end

  def test_add_text_instance_path
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    en = Sketchup.active_model.entities.add_text("su", [ip, start_pt],
                                            [30, 30, 0])
    assert_kind_of(Sketchup::Text, en)
  end

  def test_add_text_instance_path_too_many_arguments
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su",
                                              [ip, start_pt, "nope"],
                                              [30, 30, 0])
    end
  end

  def test_add_text_instance_path_not_enough_arguments
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su",
                                              [ip],
                                              [30, 30, 0])
    end
  end

  def test_add_text_instance_path_invalid_path
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge  = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, comp_inst])
    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su",
                                              [ip],
                                              [30, 30, 0])
    end
  end

  def test_add_text_instance_path_array
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt = setup_instance_test
    path = [comp_inst, edge]
    en = Sketchup.active_model.entities.add_text("su", [path, start_pt],
                                            [30, 30, 0])
    assert_kind_of(Sketchup::Text, en)
  end

  def test_add_text_instance_path_array_too_many_arguments
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt = setup_instance_test
    path = [comp_inst, edge]
    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su", [path, start_pt, nil],
                                              [30, 30, 0])
    end
  end

  def test_add_text_instance_path_array_not_enough_arguments
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge = setup_instance_test
    path = [comp_inst, edge]
    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su", [path],
                                              [30, 30, 0])
    end
  end

  def test_add_text_invalid_types
    start_with_empty_model
    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text(nil, [0, 0, 0], [0, 0, 0])
    end

    # this will throw an ArgumentError since 2018 was throwing ArgumentError
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_text("su", nil, [0, 0, 0])
    end
  end

  def test_add_text_instance_path_invalid_types
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge = setup_instance_test
    path = [comp_inst, edge]

    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su", [path], [0, 0, 0])
    end

    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su", [path, nil], [0, 0, 0])
    end

    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_text("su", [nil, [1, 2, 3]], [0, 0 ,0])
    end

    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_text("su", [path, [1, 2, 3]], nil)
    end
  end

  def test_add_text_example_1
    start_with_empty_model
    coordinates = [10, 10, 10]
    model = Sketchup.active_model
    entities = model.entities
    point = Geom::Point3d.new coordinates
    text = entities.add_text("This is a Test", point)
    assert_kind_of(Sketchup::Text, text)
  end

  def test_add_text_example_instance_path
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    add_instance
    instance = Sketchup.active_model.active_entities.grep(Sketchup::ComponentInstance).first
    edge = instance.definition.entities.grep(Sketchup::Edge).first
    instance_path = Sketchup::InstancePath.new([instance, edge])
    point = edge.start.position
    vector = Geom::Vector3d.new(30, 30, 0)
    text = Sketchup.active_model.entities.add_text("mytext", [instance_path, point], vector)
    assert_kind_of(Sketchup::Text, text)
  end

  def test_add_text_example_instance_path_as_array
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    add_instance
    instance = Sketchup.active_model.active_entities.grep(Sketchup::ComponentInstance).first
    edge = instance.definition.entities.grep(Sketchup::Edge).first
    path = [instance, edge]
    point = edge.start.position
    vector = Geom::Vector3d.new(30, 30, 0)
    text = Sketchup.active_model.entities.add_text("mytext", [path, point], vector)
    assert_kind_of(Sketchup::Text, text)
  end

  def test_add_text_instance_path_after_move
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    en = Sketchup.active_model.entities.add_text("su", [ip, start_pt],
                                            [30, 30, 0])
    vec = en.vector
    assert_equal(Geom::Point3d.new(9, 0, 0), en.point)
    tr = Geom::Transformation.new([12, 0, 0], [0, 1, 0], [0, 0, 1])
    comp_inst.transformation = tr
    assert_equal(Geom::Point3d.new(12, 9, 0), en.point)
    assert_equal(vec, en.vector)
  end

  # ========================================================================== #
  # method Sketchup::Entities.add_dimension_linear

  def test_add_dimension_linear_point3d_point3d_vector3d
    model = start_with_empty_model
    add_test_face
    entities = Sketchup.active_model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    ent = entities.add_dimension_linear(edge.start.position, edge.end.position,
                                        Geom::Vector3d.new(10, 20, 30))
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(edge.start.position, ent.start[1])
    assert_equal(edge.end.position, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_array3d_array3d_array3d
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    pt1 = edge.start.position.to_a
    pt2 = edge.end.position.to_a
    ent = entities.add_dimension_linear(pt1, pt2,
                                        [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(edge.start.position, ent.start[1])
    assert_equal(edge.end.position, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_inputpoint_inputpoint_array3d
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    ip1 = Sketchup::InputPoint.new(edge.start)
    ip2 = Sketchup::InputPoint.new(edge.end)
    ent = entities.add_dimension_linear(ip1, ip2, [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(edge.start, ent.start[0])
    assert_equal(edge.end, ent.end[0])
    assert_equal(edge.start.position, ent.start[1])
    assert_equal(edge.end.position, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_vertex_vertex_array3d
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    ent = entities.add_dimension_linear(edge.start, edge.end, [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(edge.start, ent.start[0])
    assert_equal(edge.end, ent.end[0])
    assert_equal(edge.start.position, ent.start[1])
    assert_equal(edge.end.position, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_edge_edge_array3d_on_edge_vertices
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    pt1 = edge.start.position
    pt2 = edge.end.position
    ent = entities.add_dimension_linear([edge, pt1], [edge, pt2], [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(edge, ent.start[0])
    assert_equal(edge, ent.end[0])
    assert_equal(pt1, ent.start[1])
    assert_equal(pt2, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_edge_edge_array3d_on_edge
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    pt1 = edge.start.position
    pt2 = edge.end.position
    v1 = pt1.vector_to(pt2)
    v2 = v1.reverse
    pt1.offset!(v1, edge.length / 4.0)
    pt2.offset!(v2, edge.length / 4.0)
    ent = entities.add_dimension_linear([edge, pt1], [edge, pt2], [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(edge, ent.start[0])
    assert_equal(edge, ent.end[0])
    assert_equal(pt1, ent.start[1])
    assert_equal(pt2, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_edge_edge_array3d_off_edge
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    pt1 = edge.start.position.offset([1, 2, 3])
    pt2 = edge.end.position.offset([1, 2, 3])
    ent = entities.add_dimension_linear([edge, pt1], [edge, pt2], [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(edge, ent.start[0])
    assert_equal(edge, ent.end[0])
    assert_equal(Geom::Point3d.new(1, 0, 0), ent.start[1])
    assert_equal(Geom::Point3d.new(10, 0, 0), ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_cpoint_cpoint_array3d
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    cpoint1 = entities.add_cpoint(edge.start)
    cpoint2 = entities.add_cpoint(edge.end)
    ent = entities.add_dimension_linear(cpoint1, cpoint2, [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(cpoint1, ent.start[0])
    assert_equal(cpoint2, ent.end[0])
    assert_equal(cpoint1.position, ent.start[1])
    assert_equal(cpoint2.position, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_cline_cline_array3d_on_cline_ends
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    pt1 = edge.start.position
    pt2 = edge.end.position
    cline = entities.add_cline(pt1, pt2)
    ent = entities.add_dimension_linear([cline, pt1], [cline, pt2], [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(cline, ent.start[0])
    assert_equal(cline, ent.end[0])
    assert_equal(pt1, ent.start[1])
    assert_equal(pt2, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_cline_cline_array3d_on_cline
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    pt1 = edge.start.position
    pt2 = edge.end.position
    cline = entities.add_cline(pt1, pt2)
    v1 = pt1.vector_to(pt2)
    v2 = v1.reverse
    pt1.offset!(v1, edge.length / 4.0)
    pt2.offset!(v2, edge.length / 4.0)
    ent = entities.add_dimension_linear([cline, pt1], [cline, pt2], [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(cline, ent.start[0])
    assert_equal(cline, ent.end[0])
    assert_equal(pt1, ent.start[1])
    assert_equal(pt2, ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_cline_cline_array3d_off_cline
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    pt1 = edge.start.position
    pt2 = edge.end.position
    cline = entities.add_cline(pt1, pt2)
    pt1.offset!([1, 2, 3])
    pt2.offset!([1, 2, 3])
    ent = entities.add_dimension_linear([cline, pt1], [cline, pt2], [10, 20, 30])
    assert_kind_of(Sketchup::DimensionLinear, ent)
    assert_equal(cline, ent.start[0])
    assert_equal(cline, ent.end[0])
    assert_equal(Geom::Point3d.new(1, 0, 0), ent.start[1])
    assert_equal(Geom::Point3d.new(10, 0, 0), ent.end[1])
    assert_equal(Geom::Vector3d.new(10, 20, 30), ent.offset_vector)
  end

  def test_add_dimension_linear_validate_points
    model = start_with_empty_model
    assert_raises(ArgumentError) do
      model.entities.add_dimension_linear(ORIGIN, ORIGIN, Z_AXIS)
    end
  end

  def test_add_dimension_linear_too_many_arguments
    # This doesn't produce an error, when it should... however, since this has
    # been around since SketchUp 2014, we need to keep around unfortunately.
    model = start_with_empty_model
    add_test_face
    entities = model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    ent = entities.add_dimension_linear(edge.start.position, edge.end.position,
                                  [10, 10, 0], [10, 10, 10], [10, 10, 10],
                                  [10, 10, 10])
    assert_kind_of(Sketchup::DimensionLinear, ent)
  end

  def test_add_dimension_linear_not_enough_arguments
    start_with_empty_model
    add_test_face
    entities = Sketchup.active_model.active_entities
    edge = entities.grep(Sketchup::Edge).first
    assert_raises(ArgumentError) do
      entities.add_dimension_linear(edge.start.position, Geom::Point3d.new)
    end
  end

  def test_add_dimension_linear_instance_path
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    en = Sketchup.active_model.entities.add_dimension_linear([ip, start_pt],
            [ip, end_pt], [10, 10, 0])
    assert_kind_of(Sketchup::DimensionLinear, en)
  end

  def test_add_dimension_linear_instance_path_too_many_arguments
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear([ip, start_pt, "su"],
          [ip, end_pt], [10, 10, 0])
    end
  end

  def test_add_dimension_linear_instance_path_not_enough_arguments
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear([ip],
          [ip, end_pt], [10, 10, 0])
    end
  end

  def test_add_dimension_linear_instance_path_invalid_path
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, comp_inst])
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear([ip, start_pt],
          [ip, end_pt], [10, 10, 0])
    end
  end

  def test_add_dimension_linear_instance_path_array
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    path = [comp_inst, edge]
    en = Sketchup.active_model.entities.add_dimension_linear([path, start_pt],
            [path, end_pt], [10, 10, 0])
    assert_kind_of(Sketchup::DimensionLinear, en)
  end

  def test_add_dimension_linear_instance_path_array_too_many_arguments
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    path = [comp_inst, edge]
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear([path, start_pt, "su"],
          [path, end_pt], [10, 10, 0])
    end
  end

  def test_add_dimension_linear_instance_path_array_not_enough_arguments
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    path = [comp_inst, edge]
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear([path],
          [path, end_pt], [10, 10, 0])
    end
  end

  def test_add_dimension_linear_instance_path_mixed_arguments
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    path = [comp_inst, edge]
    en = Sketchup.active_model.entities.add_dimension_linear([ip, start_pt],
            [path, end_pt], [10, 10, 0])
    assert_kind_of(Sketchup::DimensionLinear, en)
  end

  def test_add_dimension_linear_invalid_types
    start_with_empty_model
    pt = [1, 2, 3]
    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear(nil, pt, pt, pt)
    end

    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear(pt, nil, pt, pt)
    end

    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear(pt, pt, nil, pt)
    end

    assert_raises(ArgumentError) do
      Sketchup.active_model.entities.add_dimension_linear(pt, pt, pt, nil)
    end
  end

  def test_add_dimension_linear_instance_path_invalid_types
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_dimension_linear([nil, start_pt],
          [ip, end_pt], Geom::Vector3d.new(1, 2, 3))
    end

    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_dimension_linear([ip, nil],
          [ip, end_pt], Geom::Vector3d.new(1, 2, 3))
    end

    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_dimension_linear([ip, start_pt],
          [nil, end_pt], Geom::Vector3d.new(1, 2, 3))
    end

    assert_raises(TypeError) do
      Sketchup.active_model.entities.add_dimension_linear([ip, start_pt],
          [ip, nil], Geom::Vector3d.new(1, 2, 3))
    end
  end

  def test_add_dimension_linear_example_1
    start_with_empty_model
    entities = Sketchup.active_model.entities
    # From point to point
    dim = entities.add_dimension_linear [50, 10, 0], [100, 10, 0], [0, 20, 0]
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_example_2
    start_with_empty_model
    entities = Sketchup.active_model.entities
    edge = entities.add_edges([50, 50, 0], [40, 10, 0])[0]
    v0 = edge.start
    v1 = edge.end
    dim = entities.add_dimension_linear v0, v1, [0, 0, 20]
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_example_3
    start_with_empty_model
    entities = Sketchup.active_model.entities
    edge = entities.add_edges([50, 50, 0], [40, 10, 0])[0]
    p0 = edge.start.position
    p1 = edge.end.position
    mp = Geom::Point3d.new((p0.x+p1.x)/2.0, (p0.y+p1.y)/2.0, (p0.z+p1.z)/2.0)
    cp = entities.add_cpoint [50, 10, 0]
    dim = entities.add_dimension_linear [edge, mp], cp, [20, 0, 0]
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_example_instance_path
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    add_instance
    instance = Sketchup.active_model.active_entities.grep(Sketchup::ComponentInstance).first
    edge = instance.definition.entities.grep(Sketchup::Edge).first
    instance_path = Sketchup::InstancePath.new([instance, edge])
    start_point = edge.start.position
    end_point = edge.end.position
    vector = Geom::Vector3d.new(30, 30, 0)
    dim = Sketchup.active_model.entities.add_dimension_linear([instance_path,
        start_point], [instance_path, end_point], vector)
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_example_instance_path_as_array
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    add_instance
    instance = Sketchup.active_model.active_entities.grep(Sketchup::ComponentInstance).first
    edge = instance.definition.entities.grep(Sketchup::Edge).first
    path = [instance, edge]
    start_point = edge.start.position
    end_point = edge.end.position
    vector = Geom::Vector3d.new(30, 30, 0)
    dim = Sketchup.active_model.entities.add_dimension_linear([path, start_point],
        [path, end_point], vector)
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_instance_path_after_move
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    start_with_empty_model
    comp_inst, edge, start_pt, end_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    en = Sketchup.active_model.entities.add_dimension_linear([ip, start_pt],
            [ip, end_pt], [10, 10, 0])
    assert_equal(start_pt, en.start[1])
    assert_equal(end_pt, en.end[1])
    offset_vector = en.offset_vector
    tr = Geom::Transformation.new([12, 12, 12])
    comp_inst.transformation = tr
    assert_equal(Geom::Point3d.new(21, 12, 12), en.start[1])
    assert_equal(Geom::Point3d.new(21, 21, 12), en.end[1])
    assert_equal(offset_vector, en.offset_vector)
  end

  def test_add_dimension_linear_SU41171_centercode_original
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    group1 = basic_setup_for_SU41171
    model = Sketchup.active_model
    comp1 = group1.to_component
    comp2 = model.entities.add_instance(comp1.definition, Geom::Transformation.new([20, 30, 0]))
    vertex1 = comp1.definition.entities.grep(Sketchup::Face).first.vertices.first
    path1 = Sketchup::InstancePath.new([comp1, vertex1])
    point1 = vertex1.position
    point1.transform!(comp1.transformation)

    vertex2 = comp2.definition.entities.grep(Sketchup::Face).first.vertices.first
    path2 = Sketchup::InstancePath.new([comp2, vertex2])
    point2 = vertex2.position
    point2.transform!(comp2.transformation)

    dim = model.active_entities.add_dimension_linear([path1, point1], [path2, point2], [-30, 0, 0])
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_SU41171_construction_point_vertex
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    group1 = basic_setup_for_SU41171
    model = Sketchup.active_model
    component1 = group1.to_component
    component1.transform!(Geom::Transformation.new([10, 10, 10]))
    component2 = model.entities.add_instance(component1.definition, Geom::Transformation.new([20, 30, 0]))
    vertex = component2.definition.entities.grep(Sketchup::Edge).first.start
    construction_point = component1.definition.entities.add_cpoint([10, 10, 10])

    path1 = Sketchup::InstancePath.new([component1, construction_point])
    path2 = Sketchup::InstancePath.new([component2, vertex])

    point1 = construction_point.position
    point2 = vertex.position
    point1.transform!(path1.transformation)
    point2.transform!(path2.transformation)

    dim = model.entities.add_dimension_linear([path1, point1], [path2, point2], [30, 30, 30])
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_SU41171_edge_start_end_points
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    group1 = basic_setup_for_SU41171
    model = Sketchup.active_model
    component1 = group1.to_component
    component1.transform!(Geom::Transformation.new([10, 10, 10]))
    component2 = model.entities.add_instance(component1.definition, Geom::Transformation.new([20, 30, 0]))
    edge1 = component1.definition.entities.grep(Sketchup::Edge).first
    edge2 = component2.definition.entities.grep(Sketchup::Edge).last

    path1 = Sketchup::InstancePath.new([component1, edge1])
    path2 = Sketchup::InstancePath.new([component2, edge2])

    point1 = edge1.start.position
    point2 = edge2.start.position
    point1.transform!(path1.transformation)
    point2.transform!(path2.transformation)

    dim = model.entities.add_dimension_linear([path1, point1], [path2, point2], [30, 30, 30])
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  def test_add_dimension_linear_SU41171_construction_line
    skip("Added in SU2019") if Sketchup.version.to_i < 19
    group1 = basic_setup_for_SU41171
    model = Sketchup.active_model
    component1 = group1.to_component
    #component1.definition.entities.add_cline([0, 0, 0], [1, 1, 1])
    component1.transform!(Geom::Transformation.new([10, 10, 10]))
    component2 = model.entities.add_instance(component1.definition, Geom::Transformation.new([20, 30, 0]))
    component2.definition.entities.add_cline([0, 0, 0], [100, 100, 100])
    cline1 = component1.definition.entities.grep(Sketchup::ConstructionLine).first
    cline2 = component2.definition.entities.grep(Sketchup::ConstructionLine).first

    path1 = Sketchup::InstancePath.new([component1, cline1])
    path2 = Sketchup::InstancePath.new([component2, cline2])

    point1 = cline1.start
    point2 = cline2.start
    point1.transform!(path1.transformation)
    point2.transform!(path2.transformation)

    dim = model.entities.add_dimension_linear([path1, point1], [path2, point2], [30, 30, 30])
    assert_kind_of(Sketchup::DimensionLinear, dim)
  end

  # ========================================================================== #
  # method Sketchup::Entities.fill_from_mesh

  def test_fill_from_mesh_image_material
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    entities = Sketchup.active_model.active_entities
    mesh = create_test_mesh
    image_material = create_image_material
    group = entities.add_group
    assert_raises(ArgumentError, 'front material') do
      group.entities.fill_from_mesh(mesh, true, Geom::PolygonMesh::AUTO_SOFTEN,
          image_material)
    end
    group = entities.add_group
    assert_raises(ArgumentError, 'back material') do
      group.entities.fill_from_mesh(mesh, true, Geom::PolygonMesh::AUTO_SOFTEN,
          nil, image_material)
    end
  end

  # ========================================================================== #
  # method Sketchup::Entities.add_faces_from_mesh

  def test_add_faces_from_mesh_image_material
    skip('Fixed in SU2019.2') if Sketchup.version.to_f < 19.2
    entities = Sketchup.active_model.active_entities
    mesh = create_test_mesh
    image_material = create_image_material
    assert_raises(ArgumentError, 'front material') do
      entities.add_faces_from_mesh(mesh, Geom::PolygonMesh::AUTO_SOFTEN,
          image_material)
    end
    assert_raises(ArgumentError, 'back material') do
      entities.add_faces_from_mesh(mesh, Geom::PolygonMesh::AUTO_SOFTEN,
         nil, image_material)
    end
  end

  # ========================================================================== #
  # method Sketchup::Entities.weld

  def test_weld_single_face_loop
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    entities = Sketchup.active_model.active_entities
    face = add_test_face
    edges = face.edges
    curves = entities.weld(edges)
    assert_kind_of(Array, curves)
    assert_equal(1, curves.size)
    curve = curves.first
    assert_equal(Sketchup::Curve, curve.class) # Ensure it's not ArcCurve
    assert_equal(edges.size + 1, curve.vertices.size)
    assert_equal(edges.sort_by(&:entityID), curve.edges.sort_by(&:entityID))
  end

  def test_weld_multiple_face_loops
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    model = Sketchup.active_model
    entities = model.active_entities
    face1 = entities.add_face([0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0])
    face2 = entities.add_face([0, 0, 1], [9, 0, 1], [9, 9, 1], [0, 9, 1])
    edges = face1.edges + face2.edges
    curves = entities.weld(edges)
    assert_kind_of(Array, curves)
    assert_equal(2, curves.size)
    curves.each { |curve|
      assert_equal(Sketchup::Curve, curve.class) # Ensure it's not ArcCurve
    }
    curve_edges = curves.map(&:edges).flatten.uniq
    assert_equal(edges.size, curve_edges.size)
    assert_equal(edges.sort_by(&:entityID), curve_edges.sort_by(&:entityID))
  end

  def test_weld_single_edge
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    entities = Sketchup.active_model.active_entities
    face = add_test_face
    edges = face.edges.take(1)
    curves = entities.weld(edges)
    assert_kind_of(Array, curves)
    assert_equal(1, curves.size)
    curve = curves.first
    assert_equal(Sketchup::Curve, curve.class) # Ensure it's not ArcCurve
    assert_equal(edges.size + 1, curve.vertices.size)
    assert_equal(edges.sort_by(&:entityID), curve.edges.sort_by(&:entityID))
  end

  def test_weld_empty_array
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    entities = Sketchup.active_model.active_entities
    curves = entities.weld([])
    assert_kind_of(Array, curves)
    assert_empty(curves)
  end

  def test_weld_invalid_arguments_nil
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    entities = Sketchup.active_model.active_entities
    assert_raises(TypeError) do
      entities.weld(nil)
    end
  end

  def test_weld_invalid_arguments_numeric
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    entities = Sketchup.active_model.active_entities
    assert_raises(TypeError) do
      entities.weld(123)
    end
  end

  def test_weld_invalid_arguments_not_edges
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    entities = Sketchup.active_model.active_entities
    face = add_test_face
    assert_raises(TypeError) do
      entities.weld(entities.to_a)
    end
  end

  def test_weld_invalid_arguments_wrong_parent
    skip('Added in SU2020.1') if Sketchup.version.to_f < 20.1
    entities = Sketchup.active_model.active_entities
    group = entities.add_group
    face = group.entities.add_face([0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0])
    assert_raises(ArgumentError) do
      entities.weld(face.edges)
    end
  end

end # class

# Copyright:: Copyright 2021 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"


# module Sketchup::EntitiesBuilder
class TC_Sketchup_EntitiesBuilder < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end

  def assert_premutation(expected, actual)
    # .map(&:to_a) because Geom::Point3d doesn't have #<=> operator.
    expected.map(&:to_a).sort == actual.map(&:to_a).sort
  end

  # ========================================================================== #
  # class Sketchup::EntitiesBuilder

  def test_cannot_initialize_via_new
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    assert_raises(NoMethodError) do
      Sketchup::EntitiesBuilder.new
    end
  end

  def test_cannot_dup
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_raises(TypeError) do
        builder.dup
      end
    end
  end

  def test_cannot_clone
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_raises(TypeError) do
        builder.clone
      end
    end
  end

  # ========================================================================== #
  # method Sketchup::EntitiesBuilder#add_face

  def test_add_face_array_of_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 6, 0),
      Geom::Point3d.new(0, 6, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      face = builder.add_face(points)
      assert_kind_of(Sketchup::Face, face)
      assert_equal(points.size, face.vertices.size)
      assert_equal(model.entities, face.parent.entities)
      assert_equal(Z_AXIS, face.normal)
      assert_premutation(points, face.vertices.map(&:position))
    end
  end

  def test_add_face_array_of_reversed_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 6, 0),
      Geom::Point3d.new(0, 6, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      face = builder.add_face(points.reverse)
      assert_kind_of(Sketchup::Face, face)
      assert_equal(points.size, face.vertices.size)
      assert_equal(model.entities, face.parent.entities)
      assert_equal(Z_AXIS.reverse, face.normal)
      assert_premutation(points, face.vertices.map(&:position))
    end
  end

  def test_add_face_variable_arguments_of_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 6, 0),
      Geom::Point3d.new(0, 6, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      face = builder.add_face(*points)
      assert_kind_of(Sketchup::Face, face)
      assert_equal(points.size, face.vertices.size)
      assert_equal(model.entities, face.parent.entities)
      assert_equal(Z_AXIS, face.normal)
      assert_premutation(points, face.vertices.map(&:position))
    end
  end

  def test_add_face_with_holes
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points1 = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 8, 0),
      Geom::Point3d.new(0, 8, 0),
    ]
    points2 = [
      Geom::Point3d.new(1, 1, 0),
      Geom::Point3d.new(4, 1, 0),
      Geom::Point3d.new(4, 7, 0),
      Geom::Point3d.new(1, 7, 0),
    ]
    points3 = [
      Geom::Point3d.new(5, 1, 0),
      Geom::Point3d.new(8, 1, 0),
      Geom::Point3d.new(8, 7, 0),
      Geom::Point3d.new(5, 7, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      face = builder.add_face(points1, holes: [points2, points3])
      assert_kind_of(Sketchup::Face, face)
      assert_equal(3, face.loops.size)
      assert_equal(12, face.vertices.size)
      assert_equal(model.entities, face.parent.entities)
      assert_equal(Z_AXIS, face.normal)
      expected_points = points1 + points2 + points3
      assert_premutation(expected_points, face.vertices.map(&:position))
    end
  end

  def test_add_face_with_holes_with_var_args
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points1 = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 8, 0),
      Geom::Point3d.new(0, 8, 0),
    ]
    points2 = [
      Geom::Point3d.new(1, 1, 0),
      Geom::Point3d.new(4, 1, 0),
      Geom::Point3d.new(4, 7, 0),
      Geom::Point3d.new(1, 7, 0),
    ]
    points3 = [
      Geom::Point3d.new(5, 1, 0),
      Geom::Point3d.new(8, 1, 0),
      Geom::Point3d.new(8, 7, 0),
      Geom::Point3d.new(5, 7, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      face = builder.add_face(*points1, holes: [points2, points3])
      assert_kind_of(Sketchup::Face, face)
      assert_equal(3, face.loops.size)
      assert_equal(12, face.vertices.size)
      assert_equal(model.entities, face.parent.entities)
      assert_equal(Z_AXIS, face.normal)
      expected_points = points1 + points2 + points3
      assert_premutation(expected_points, face.vertices.map(&:position))
    end
  end

  def test_add_face_from_vertices
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 6, 0),
      Geom::Point3d.new(0, 6, 0),
    ]
    model = Sketchup.active_model
    temp_face = model.entities.add_face(points)
    expected_normal = temp_face.normal
    vertices = temp_face.outer_loop.vertices
    temp_face.erase!
    model.entities.build do |builder|
      face = builder.add_face(vertices)
      assert_kind_of(Sketchup::Face, face)
      assert_equal(points.size, face.vertices.size)
      assert_equal(model.entities, face.parent.entities)
      assert_equal(expected_normal, face.normal)
      assert_premutation(points, face.vertices.map(&:position))
      assert_equal(4, model.entities.grep(Sketchup::Edge).size)
    end
  end

  def test_add_face_identical_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(0, 0, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_face(points)
      end
      assert(builder.valid?)
      assert_equal(0, model.entities.size)
    end
  end
  
  def test_add_face_non_planar_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 6, 0),
      Geom::Point3d.new(0, 6, 5),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_face(points)
      end
      assert(builder.valid?)
      assert_equal(0, model.entities.size)
    end
  end

  def test_add_face_colinear_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(2, 0, 0),
      Geom::Point3d.new(4, 0, 0),
      Geom::Point3d.new(6, 0, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_face(points)
      end
      assert(builder.valid?)
      assert_equal(0, model.entities.size)
    end
  end

  def test_add_face_small_face
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0.0000, 0.0000, 0),
      Geom::Point3d.new(0.0009, 0.0000, 0),
      Geom::Point3d.new(0.0009, 0.0006, 0),
      Geom::Point3d.new(0.0000, 0.0006, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_face(points)
      end
      assert(builder.valid?)
      assert_equal(0, model.entities.size)
    end
  end

  def test_add_face_too_few_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_face(points)
      end
      assert(builder.valid?)
      assert_equal(0, model.entities.size)
    end
  end

  def test_add_face_holes_missing_named_parameter
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points1 = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 8, 0),
      Geom::Point3d.new(0, 8, 0),
    ]
    points2 = [
      Geom::Point3d.new(1, 1, 0),
      Geom::Point3d.new(4, 1, 0),
      Geom::Point3d.new(4, 7, 0),
      Geom::Point3d.new(1, 7, 0),
    ]
    points3 = [
      Geom::Point3d.new(5, 1, 0),
      Geom::Point3d.new(8, 1, 0),
      Geom::Point3d.new(8, 7, 0),
      Geom::Point3d.new(5, 7, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        face = builder.add_face(points1, [points2, points3])
      end
    end
  end
  
  def test_add_face_too_few_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_face
      end
      assert(builder.valid?)
      assert_equal(0, model.entities.size)
    end
  end

  def test_add_face_invalid_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      # Ideally this should be TypeError, but our API has used ArgumentError for
      # Point3d types since the beginning, so we're stuck with this now.
      assert_raises(ArgumentError) do
        builder.add_face(['a', 'b', 'c'])
      end
      assert(builder.valid?)
      assert_equal(0, model.entities.size)
    end
  end

  # ========================================================================== #
  # method Sketchup::EntitiesBuilder#add_edge

  def test_add_edge_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
    ]
    point1, point2 = points
    model = Sketchup.active_model
    model.entities.build do |builder|
      edge = builder.add_edge(point1, point2)
      assert_kind_of(Sketchup::Edge, edge)
      assert_equal(points.size, edge.vertices.size)
      assert_equal(model.entities, edge.parent.entities)
      assert_premutation(points, edge.vertices.map(&:position))
    end
  end

  def test_add_edge_array_of_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      edge = builder.add_edge(points)
      assert_kind_of(Sketchup::Edge, edge)
      assert_equal(model.entities, edge.parent.entities)
      assert_premutation(points, edge.vertices.map(&:position))
    end
  end

  def test_add_edge_array_of_vertices
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    edge1 = model.entities.add_line([0, 0, 0], [0, 0, 9])
    edge2 = model.entities.add_line([9, 0, 0], [9, 0, 9])
    vertices = [edge1.start, edge2.start]
    model.entities.build do |builder|
      edge = builder.add_edge(vertices)
      assert_kind_of(Sketchup::Edge, edge)
      assert_equal(model.entities, edge.parent.entities)
      assert_premutation(vertices.map(&:position), edge.vertices.map(&:position))
    end
  end
  
  def test_add_edge_too_few_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_edge(points)
      end
    end
  end

  def test_add_edge_too_small
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0.0000, 0, 0),
      Geom::Point3d.new(0.0004, 0, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_edge(points)
      end
    end
  end

  def test_add_edge_invalid_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      # Ideally this should be TypeError, but our API has used ArgumentError for
      # Point3d types since the beginning, so we're stuck with this now.
      assert_raises(ArgumentError) do
        builder.add_edge(123, 465)
      end
    end
  end

  def test_add_edge_invalid_arguments_in_array
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_edge(['hello', 'mystery'])
      end
    end
  end
  
  def test_add_edge_too_few_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.add_edge
      end
    end
  end

  # ========================================================================== #
  # method Sketchup::EntitiesBuilder#add_line (alias)

  def test_add_line_array_of_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      edge = builder.add_line(points)
      assert_kind_of(Sketchup::Edge, edge)
      assert_equal(points.size, edge.vertices.size)
      assert_equal(model.entities, edge.parent.entities)
      assert_premutation(points, edge.vertices.map(&:position))
    end
  end

  # ========================================================================== #
  # method Sketchup::EntitiesBuilder#add_edges

  def test_add_edges_variable_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(5, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 6, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      edges = builder.add_edges(*points)
      assert_equal(3, edges.size)
      edges.each { |edge|
        assert_kind_of(Sketchup::Edge, edge)
        assert_equal(model.entities, edge.parent.entities)
      }
      vertices = edges.map(&:vertices).flatten.uniq
      assert_equal(points.size, vertices.size)
      assert_premutation(points, vertices.map(&:position))
    end
  end

  def test_add_edges_array_of_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(5, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 6, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      edges = builder.add_edges(points)
      assert_equal(3, edges.size)
      edges.each { |edge|
        assert_kind_of(Sketchup::Edge, edge)
        assert_equal(model.entities, edge.parent.entities)
      }
      vertices = edges.map(&:vertices).flatten.uniq
      assert_equal(points.size, vertices.size)
      assert_premutation(points, vertices.map(&:position))
    end
  end

  def test_add_edges_array_of_vertices
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    edge1 = model.entities.add_line([0, 0, 0], [0, 9, 0])
    edge2 = model.entities.add_line([8, 9, 0], [8, 0, 0])
    vertices = edge1.vertices + edge2.vertices
    points = vertices.map(&:position)
    model.entities.build do |builder|
      edges = builder.add_edges(vertices)
      assert_equal(3, edges.size)
      edges.each { |edge|
        assert_kind_of(Sketchup::Edge, edge)
        assert_equal(model.entities, edge.parent.entities)
      }
      vertices2 = edges.map(&:vertices).flatten.uniq
      assert_equal(points.size, vertices2.size)
      assert_premutation(points, vertices.map(&:position))
    end
  end

  def test_add_edges_skip_short_edge
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    points = [
      Geom::Point3d.new(0.0000, 0, 0),
      Geom::Point3d.new(5.0000, 0, 0),
      Geom::Point3d.new(5.0001, 0, 0),
      Geom::Point3d.new(9.0000, 0, 0),
      Geom::Point3d.new(9.0000, 6, 0),
    ]
    model = Sketchup.active_model
    model.entities.build do |builder|
      edges = builder.add_edges(points)
      assert_equal(4, edges.size)
      edges.compact! # Removes nil elements
      assert_equal(3, edges.size)
      edges.each { |edge|
        assert_kind_of(Sketchup::Edge, edge)
        assert_equal(model.entities, edge.parent.entities)
      }
      vertices = edges.map(&:vertices).flatten.uniq
      expected = [
        Geom::Point3d.new(0.0000, 0, 0),
        Geom::Point3d.new(5.0000, 0, 0),
        Geom::Point3d.new(9.0000, 0, 0),
        Geom::Point3d.new(9.0000, 6, 0),
      ]
      assert_equal(expected.size, vertices.size)
      assert_premutation(expected, vertices.map(&:position))
    end
  end

  def test_add_edges_too_few_points
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        edges = builder.add_edges(ORIGIN)
      end
    end
  end

  def test_add_edges_too_few_points_in_array
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        edges = builder.add_edges([ORIGIN])
      end
    end
  end

  def test_add_edges_invalid_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      # Ideally this should be TypeError, but our API has used ArgumentError for
      # Point3d types since the beginning, so we're stuck with this now.
      assert_raises(ArgumentError) do
        edges = builder.add_edges('hello', 'world')
      end
    end
  end

  def test_add_edges_invalid_arguments_in_array
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    model = Sketchup.active_model
    model.entities.build do |builder|
      assert_raises(ArgumentError) do
        edges = builder.add_edges(['hello', 'world'])
      end
    end
  end

  # ========================================================================== #
  # method Sketchup::EntitiesBuilder#entities

  def test_entities
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_equal(Sketchup.active_model.entities, builder.entities)
    end
  end

  def test_entities_too_many_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.entities(123)
      end
    end
  end

  # ========================================================================== #
  # method Sketchup::EntitiesBuilder#valid?

  def test_valid_Query_valid
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_kind_of(TrueClass, builder.valid?)
    end
  end

  def test_valid_Query_invalid
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    zombie_builder = nil
    Sketchup.active_model.entities.build do |builder|
      zombie_builder = builder
    end
    assert_kind_of(FalseClass, zombie_builder.valid?)
  end

  def test_valid_Query_too_many_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.valid?(123)
      end
    end
  end

  # ========================================================================== #
  # method Sketchup::EntitiesBuilder#vertex_at

  def test_vertex_at_found
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      builder.add_edge([1, 0, 0], [9, 0, 0])

      vertex = builder.vertex_at(Geom::Point3d.new(9, 0, 0))
      refute_nil(vertex)
      assert_kind_of(Sketchup::Vertex, vertex)
      assert_equal(Geom::Point3d.new(9, 0, 0), vertex.position)
    end
  end

  def test_vertex_at_found_array_as_point
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      builder.add_edge([1, 0, 0], [9, 0, 0])

      vertex = builder.vertex_at([9, 0, 0])
      refute_nil(vertex)
      assert_kind_of(Sketchup::Vertex, vertex)
      assert_equal(Geom::Point3d.new(9, 0, 0), vertex.position)
    end
  end

  def test_vertex_at_not_found
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      builder.add_edge([1, 0, 0], [9, 0, 0])

      vertex = builder.vertex_at([0, 0, 0])
      assert_nil(vertex)
    end
  end

  def test_vertex_at_too_few_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.vertex_at
      end
    end
  end

  def test_vertex_at_too_many_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.vertex_at([9, 0, 0], 123)
      end
    end
  end

  def test_vertex_at_invalid_arguments
    skip("Added in SU2022.0") if Sketchup.version.to_f < 22.0
    Sketchup.active_model.entities.build do |builder|
      assert_raises(ArgumentError) do
        builder.vertex_at('not a point!')
      end
    end
  end

end # class

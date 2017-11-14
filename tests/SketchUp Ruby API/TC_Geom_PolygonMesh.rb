# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi


require "testup/testcase"


# module Geom::PolygonMesh
class TC_Geom_PolygonMesh < TestUp::TestCase
  MESH_POINTS = 0
  MESH_UVQ_FRONT = 1
  MESH_UVQ_BACK = 2
  MESH_NORMAL = 4

  def setup
    # ...
    start_with_empty_model
  end

  def teardown
    # ...
  end

  def setup_face
    points = [[0, 0, 0], [1, 2, 3], [2, 3, 4], [3, 2, 1]]
    return Sketchup.active_model.active_entities.add_face(points)
  end

  def setup_polygon_for_polygon_at
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(0, 31, 0)
    point3 = Geom::Point3d.new(31, 31, 0)
    point4 = Geom::Point3d.new(31, 0, 0)
    polygonmesh.add_point(point1)
    polygonmesh.add_point(point2)
    polygonmesh.add_point(point3)
    polygonmesh.add_point(point4)
    polygonmesh.add_polygon(point1, point2, point3, point4)
    return polygonmesh
  end

  def setup_polygon_for_uv
    polygonmesh = Geom::PolygonMesh.new(4)
    # Create points for a triangle.
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(9, 0, 0)
    point3 = Geom::Point3d.new(9, 9, 0)
    point4 = Geom::Point3d.new(0, 9, 0)
    # Add points and UV data to mesh.
    index1 = polygonmesh.add_point(point1)
    index2 = polygonmesh.add_point(point2)
    index3 = polygonmesh.add_point(point3)
    index4 = polygonmesh.add_point(point4)
    return polygonmesh
  end

  def setup_polygon_for_transform
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 1, 2)
    polygonmesh.add_point(point1)
    return polygonmesh
  end

  def setup_polygon_for_point_at
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(11, 22, 33)
    point2 = Geom::Point3d.new(22, 33, 44)
    point3 = Geom::Point3d.new(33, 44, 55)
    point4 = Geom::Point3d.new(44, 55, 66)
    point5 = Geom::Point3d.new(1, 33, 7)
    polygonmesh.add_point(point1)
    polygonmesh.add_point(point2)
    polygonmesh.add_point(point3)
    polygonmesh.add_point(point4)
    polygonmesh.add_point(point5)
    return polygonmesh
  end

  def setup_polygon_for_uv_at_textured
    face = setup_face
    materials = Sketchup.active_model.materials
    material = materials.add("test_polygon")
    filename = get_test_file("myquad.png")
    material.texture = filename
    face.position_material(material, [[1, 2, 3], [0, 0, 0]], true)
    polygonmesh = face.mesh(MESH_UVQ_FRONT | MESH_UVQ_BACK)
    return polygonmesh
  end

  def setup_polygon_for_uvs
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], true)
    polygonmesh.set_uv(2, [2, 0, 0], true)
    polygonmesh.set_uv(3, [2, 2, 0], true)
    polygonmesh.set_uv(4, [0, 2, 0], true)
    return polygonmesh
  end

  def get_test_file(filename)
    File.join(__dir__, "TC_Geom_PolygonMesh", filename)
  end

  def test_initialize
    polygonmesh = Geom::PolygonMesh.new
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
  end

  def test_initialize_num_points
    polygonmesh = Geom::PolygonMesh.new(4)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)

    polygonmesh = Geom::PolygonMesh.new(0)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
  end

  def test_initialize_num_points_num_polygons
    polygonmesh = Geom::PolygonMesh.new(4, 2)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
  end

  def test_initialize_invalid_polygonmesh
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(TypeError) do 
      Geom::PolygonMesh.new(polygonmesh)
    end

    assert_raises(TypeError) do
      Geom::PolygonMesh.new(nil)
    end
  end

  def test_initialize_invalid_num_points
    # Expected this to fail since creating a polygon mesh with 1.3 points does
    # not make sense.
    polygonmesh = Geom::PolygonMesh.new(1.3)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
  end

  def test_initialize_negative_num_points
    # Expected this to fail since creating a polygon mesh with negative points
    # does not make sense.
    polygonmesh = Geom::PolygonMesh.new(-1)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
  end

  def test_initialize_invalid_num_polygons
    # Expected this to fail since creating a polygon mesh with 2.3 polygons
    # does not make sense.
    polygonmesh = Geom::PolygonMesh.new(4, 2.3)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
  end

  def test_initialize_negative_num_polygons
    # Expected this to fail since creating a polygon mesh with negative number
    # of polygons sounds a bit odd.
    polygonmesh = Geom::PolygonMesh.new(4, -2)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
  end

  def test_add_point
    polygonmesh = Geom::PolygonMesh.new
    point = Geom::Point3d.new(0, 1, 2)
    index = polygonmesh.add_point(point)
    assert_kind_of(Integer, index)
    assert_equal(1, index)
  end

  def test_add_point_array
    polygonmesh = Geom::PolygonMesh.new
    index = polygonmesh.add_point([0, 1, 2])
    assert_kind_of(Integer, index)
    assert_equal(1, index)

    index = polygonmesh.add_point([0, 1])
    assert_kind_of(Integer, index)
    assert_equal(2, index)
  end

  def test_add_point_invalid_arguments
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(ArgumentError) do
      polygonmesh.add_point(123)
    end

    assert_raises(ArgumentError) do
      polygonmesh.add_point(nil)
    end
  end

  def test_add_point_array_invalid_arguments
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(ArgumentError) do
      polygonmesh.add_point([0])
    end
  end

  def test_add_point_too_few_arguments 
    polygonmesh = Geom::PolygonMesh.new 
    assert_raises(ArgumentError) do 
      polygonmesh.add_point
    end
  end

  def test_add_polygon
    polygonmesh = Geom::PolygonMesh.new
    index1 = polygonmesh.add_point(Geom::Point3d.new(0, 0, 0))
    index2 = polygonmesh.add_point(Geom::Point3d.new(1, 0, 0))
    index3 = polygonmesh.add_point(Geom::Point3d.new(1, 1, 0))
    polygon_index = polygonmesh.add_polygon(index1, index2, index3)
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
  end

  def test_add_polygon_same_3_points
    polygonmesh = Geom::PolygonMesh.new
    index1 = polygonmesh.add_point(Geom::Point3d.new(1, 1, 1))
    index2 = polygonmesh.add_point(Geom::Point3d.new(1, 1, 1))
    index3 = polygonmesh.add_point(Geom::Point3d.new(1, 1, 1))
    polygon_index = polygonmesh.add_polygon(index1, index2, index3)
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
  end

  def test_add_polygon_co_linear_points
    polygonmesh = Geom::PolygonMesh.new
    index1 = polygonmesh.add_point(Geom::Point3d.new(0, 0, 0))
    index2 = polygonmesh.add_point(Geom::Point3d.new(25, 0, 0))
    index3 = polygonmesh.add_point(Geom::Point3d.new(20, 0, 0))
    index4 = polygonmesh.add_point(Geom::Point3d.new(10, 0, 0))
    polygon_index = polygonmesh.add_polygon(index1, index2, index3, index4)
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
  end

  def test_add_polygon_invalid_index
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon(0)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon(-1)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon(1, 0)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon(nil)
    end
  end

  def test_add_polygon_array
    polygonmesh = Geom::PolygonMesh.new
    index1 = polygonmesh.add_point(Geom::Point3d.new(0, 0, 0))
    index2 = polygonmesh.add_point(Geom::Point3d.new(1, 0, 0))
    index3 = polygonmesh.add_point(Geom::Point3d.new(1, 1, 0))
    polygon_index = polygonmesh.add_polygon([index1, index2, index3])
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
  end
  
  def test_add_polygon_invalid_array
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon([0])
    end

    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon([nil])
    end
  end

  def test_add_polygon_points
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(1, 0, 0)
    point3 = Geom::Point3d.new(1, 1, 0)
    polygon_index = polygonmesh.add_polygon(point1, point2, point3)
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
  end

  def test_add_polygon_array_points
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(1, 0, 0)
    point3 = Geom::Point3d.new(1, 1, 0)
    polygon_index = polygonmesh.add_polygon([point1, point2, point3])
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
  end

  def test_add_polygon_array_array
    polygonmesh = Geom::PolygonMesh.new
    points = [[0, 0, 0], [1, 0, 0], [1, 0, 1], [1, 2, 3]]
    polygon_index = polygonmesh.add_polygon(points)
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
  end

  def test_add_polygon_two_triangles_share_same_edge
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 0, 0)
    point2 = Geom::Point3d.new(0, 1, 0)
    point3 = Geom::Point3d.new(1, 0, 0)
    polygon_index = polygonmesh.add_polygon(point1, point2, point3)
    assert_kind_of(Integer, polygon_index)
    assert_equal(1, polygon_index)
    assert_equal(3, polygonmesh.count_points)
    
    point1 = Geom::Point3d.new(1, 0, 0)
    point2 = Geom::Point3d.new(0, 1, 0)
    point3 = Geom::Point3d.new(2, 0, 0)
    polygon_index = polygonmesh.add_polygon(point1, point2, point3)
    assert_kind_of(Integer, polygon_index)
    assert_equal(2, polygon_index)
    assert_equal(4, polygonmesh.count_points)
  end

  def test_add_polygon_invalid_arguments
    polygonmesh = Geom::PolygonMesh.new
    vector = Geom::Vector3d.new(1, 1, 1)
    assert_raises(ArgumentError) do
      polygonmesh.add_polygon(vector)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon("1")
    end
  end

  def test_add_polygon_too_few_arguments
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(ArgumentError) do 
      polygonmesh.add_polygon 
    end
  end

  def test_count_points
    polygonmesh = Geom::PolygonMesh.new
    polygonmesh.add_point([0, 1, 2])
    count = polygonmesh.count_points
    assert_equal(1, count)
  end

  def test_count_points_size_4
    polygonmesh = Geom::PolygonMesh.new
    polygonmesh.add_point([0, 0, 0])
    polygonmesh.add_point([1, 0, 0])
    polygonmesh.add_point([1, 1, 0])
    polygonmesh.add_point([1, 1, 1])
    count = polygonmesh.count_points
    assert_equal(4, count)
  end

  def test_count_points_too_many_arguments
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(ArgumentError) do 
      polygonmesh.count_points(nil)
    end
  end

  def test_count_polygons
    polygonmesh = Geom::PolygonMesh.new
    polygonmesh.add_point(Geom::Point3d.new(0, 0, 0))
    polygonmesh.add_point(Geom::Point3d.new(1, 0, 0))
    polygonmesh.add_point(Geom::Point3d.new(1, 1, 0))
    polygonmesh.add_polygon([1, 2, 3])
    count = polygonmesh.count_polygons
    assert_equal(1, count)
  end

  def test_count_polygons_size_4
    polygonmesh = Geom::PolygonMesh.new
    polygonmesh.add_point(Geom::Point3d.new(0, 0, 0))
    polygonmesh.add_point(Geom::Point3d.new(1, 0, 0))
    polygonmesh.add_point(Geom::Point3d.new(1, 1, 0))
    polygonmesh.add_polygon([1, 2, 3])
    polygonmesh.add_polygon([1, 2, 3])
    polygonmesh.add_polygon([1, 2, 3])
    polygonmesh.add_polygon([1, 2, 3])
    count = polygonmesh.count_polygons
    assert_equal(4, count)
  end

  def test_count_polygons_too_many_arguments
    polygonmesh = Geom::PolygonMesh.new
    assert_raises(ArgumentError) do
      polygonmesh.count_polygons(nil)
    end
  end

  def test_normal_at
    face = setup_face
    entities = Sketchup.active_model.active_entities
    polygonmesh = face.mesh(MESH_NORMAL)
    normal = polygonmesh.normal_at(1)
    assert_kind_of(Geom::Vector3d, normal)
    assert_equal([-0.4082482904638631, 0.8164965809277261, -0.4082482904638631],
      normal.to_a)
  end

  def test_normal_at_valid_arguments
    # According to docs, the index passed starts at 1.
    # Code implementation shows something different, if the index passed is < 0
    # then index = -index. So it gets flipped to positive. But nil class is
    # returned if the index is 0, so it is a way to test to see if its invalid.
    face = setup_face
    entities = Sketchup.active_model.active_entities
    polygonmesh = face.mesh(MESH_NORMAL)
    vector = polygonmesh.normal_at(-1)
    assert_kind_of(Geom::Vector3d, vector)
    vector = polygonmesh.normal_at(0)
    assert_nil(vector)
  end
  
  def test_normal_at_too_many_arguments
    face = setup_face
    entities = Sketchup.active_model.active_entities
    polygonmesh = face.mesh(MESH_NORMAL)
    assert_raises(ArgumentError) do
      polygonmesh.normal_at(1, 1)
    end
  end

  def test_normal_at_too_few_arguments
    face = setup_face
    entities = Sketchup.active_model.active_entities
    polygonmesh = face.mesh(MESH_NORMAL)
    assert_raises(ArgumentError) do
      polygonmesh.normal_at
    end
  end

  def test_normal_at_invalid_arguments
    face = setup_face
    entities = Sketchup.active_model.active_entities
    polygonmesh = face.mesh(MESH_NORMAL)
    assert_raises(TypeError) do
      polygonmesh.normal_at(nil)
    end

    assert_raises(TypeError) do 
      polygonmesh.normal_at([1])
    end
  end

  def test_point_at
    polygonmesh = setup_polygon_for_point_at
    point1 = Geom::Point3d.new(1, 0, 1)
    index = polygonmesh.add_point(point1)
    point_from_index = polygonmesh.point_at(index)
    assert_kind_of(Geom::Point3d, point_from_index)
    assert_equal([1, 0, 1], point_from_index.to_a)

    point_from_index = polygonmesh.point_at(5)
    assert_kind_of(Geom::Point3d, point_from_index)
    assert_equal([1, 33, 7], point_from_index.to_a)
  end

  def test_point_at_valid_arguments
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(11, 22, 33)
    polygonmesh.add_point(point1)
    point = polygonmesh.point_at(0)
    assert_nil(point)
    point = polygonmesh.point_at(-1)
    assert_kind_of(Geom::Point3d, point)
    assert_equal([11, 22, 33], point.to_a)
  end

  def test_point_at_too_many_arguments
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(11, 22, 33)
    polygonmesh.add_point(point1)
    assert_raises(ArgumentError) do 
      polygonmesh.point_at(1, 2)
    end
  end

  def test_point_at_too_few_arguments
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(11, 22, 33)
    polygonmesh.add_point(point1)
    assert_raises(ArgumentError) do
      polygonmesh.point_at
    end
  end

  def test_point_at_out_of_range
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(11, 22, 33)
    polygonmesh.add_point(point1)
    point = polygonmesh.point_at(2)
    assert_nil(point)
  end

  def test_point_at_invalid_argument
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(11, 22, 33)
    polygonmesh.add_point(point1)
    assert_raises(TypeError) do 
      polygonmesh.point_at(nil)
    end
    
    assert_raises(TypeError) do 
      polygonmesh.point_at([1])
    end
  end

  def test_point_index
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 1, 2)
    point2 = Geom::Point3d.new(10, 20, 30)
    polygonmesh.add_point(point1)
    polygonmesh.add_point(point2)
    index = polygonmesh.point_index(point1)
    assert_equal(1, index)
    index = polygonmesh.point_index(point2)
    assert_equal(2, index)
  end

  def test_point_index_array
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 1, 2)
    point2 = Geom::Point3d.new(10, 20, 30)
    polygonmesh.add_point(point1)
    polygonmesh.add_point(point2)
    index = polygonmesh.point_index([0, 1, 2])
    assert_equal(1, index)
    index = polygonmesh.point_index([10, 20, 30])
    assert_equal(2, index)
  end

  def test_point_index_invalid_point
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 1, 2)
    point2 = Geom::Point3d.new(10, 20, 30)
    point3 = Geom::Point3d.new(11, 22, 33)
    polygonmesh.add_point(point1)
    polygonmesh.add_point(point2)
    index = polygonmesh.point_index(point3)
    assert_equal(0, index)
  end

  def test_point_index_invalid_arguments
    polygonmesh = Geom::PolygonMesh.new
    polygonmesh.add_point(Geom::Point3d.new(11, 22, 33))
    assert_raises(ArgumentError) do 
      polygonmesh.point_index(nil)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.point_index(Geom::Vector3d.new(11, 22, 33))
    end

    assert_raises(ArgumentError) do 
      polygonmesh.point_index(1)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.point_index("1")
    end
  end

  def test_points 
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 1, 2)
    point2 = Geom::Point3d.new(10, 20, 30)
    polygonmesh.add_point(point1)
    polygonmesh.add_point(point2)
    points = polygonmesh.points
    assert_kind_of(Array, points)
    assert_kind_of(Geom::Point3d, points[0])
  end

  def test_points_with_no_added_points
    polygonmesh = Geom::PolygonMesh.new
    points = polygonmesh.count_points
    assert_equal(0, points)
  end

  def test_points_invalid_arguments
    polygonmesh = Geom::PolygonMesh.new
    point1 = Geom::Point3d.new(0, 1, 2)
    point2 = Geom::Point3d.new(10, 20, 30)
    polygonmesh.add_point(point1)
    polygonmesh.add_point(point2)
    assert_raises(ArgumentError) do 
      polygonmesh.points(nil)
    end
  end

  def test_polygon_at 
    polygonmesh = setup_polygon_for_polygon_at
    array = polygonmesh.polygon_at(1)
    assert_kind_of(Array, array)
    assert_equal([1, 2, 3, 4], array)
  end

  def test_polygon_at_too_many_arguments
    polygonmesh = setup_polygon_for_polygon_at
    assert_raises(ArgumentError) do 
      polygonmesh.polygon_at(1, 1)
    end
  end

  def test_polygon_at_too_few_arguments
    polygonmesh = setup_polygon_for_polygon_at
    assert_raises(ArgumentError) do 
      polygonmesh.polygon_at
    end
  end

  def test_polygon_at_invalid_arguments
    polygonmesh = setup_polygon_for_polygon_at
    assert_raises(TypeError) do 
      polygonmesh.polygon_at([1])
    end
    
    assert_raises(TypeError) do 
      polygonmesh.polygon_at(polygonmesh)
    end

    assert_raises(TypeError) do 
      polygonmesh.polygon_at("1")
    end

    assert_raises(TypeError) do 
      polygonmesh.polygon_at(nil)
    end
  end

  def test_polygon_at_index_zero
    polygonmesh = setup_polygon_for_polygon_at
    result = polygonmesh.polygon_at(0)
    assert_nil(result)
  end

  def test_polygon_points_at
    polygonmesh = setup_polygon_for_polygon_at
    points = polygonmesh.polygon_points_at(1)
    assert_kind_of(Array, points)
    assert_equal(4, points.size)
    assert_kind_of(Geom::Point3d, points[0])
    assert_equal([0, 0, 0], points[0].to_a)
  end

  def test_polygon_points_at_too_many_arguments
    polygonmesh = setup_polygon_for_polygon_at
    assert_raises(ArgumentError) do
      polygonmesh.polygon_points_at(1, 1)
    end
  end

  def test_polygon_points_at_too_few_arguments
    polygonmesh = setup_polygon_for_polygon_at
    assert_raises(ArgumentError) do 
      polygonmesh.polygon_points_at
    end
  end

  def test_polygon_points_at_invalid_arguments
    polygonmesh = setup_polygon_for_polygon_at
    assert_raises(TypeError) do
      polygonmesh.polygon_points_at(nil)
    end

    assert_raises(TypeError) do
      polygonmesh.polygon_points_at([1])
    end

    assert_raises(TypeError) do
      polygonmesh.polygon_points_at("1")
    end

    assert_raises(TypeError) do
      polygonmesh.polygon_points_at(polygonmesh)
    end
  end

  def test_polygon_points_at_index_zero
    polygonmesh = setup_polygon_for_polygon_at
    result = polygonmesh.polygon_points_at(0)
    assert_nil(result)
  end

  def test_polygons
    polygonmesh = setup_polygon_for_polygon_at
    array = polygonmesh.polygons
    assert_kind_of(Array, array)
    assert_equal(1, array.size)
    assert_equal([1, 2, 3, 4], array[0])
  end

  def test_polygons_too_many_arguments
    polygonmesh = setup_polygon_for_polygon_at
    assert_raises(ArgumentError) do
      polygonmesh.polygons(nil)
    end
  end

  def test_polygons_no_polygons
    polygonmesh = Geom::PolygonMesh.new
    result = polygonmesh.polygons
    assert_kind_of(Array, result)
    assert_nil(result[0])
  end

  def test_set_point
    polygonmesh = setup_polygon_for_polygon_at
    point1 = Geom::Point3d.new(22, 33, 44)
    result = polygonmesh.set_point(1, point1)
    assert_kind_of(Geom::PolygonMesh, result)
    assert_equal(point1.to_a, result.point_at(1).to_a)
  end

  def test_set_point_array
    polygonmesh = setup_polygon_for_polygon_at
    result = polygonmesh.set_point(1, [22, 33, 44])
    assert_kind_of(Geom::PolygonMesh, result)
    assert_equal([22, 33, 44], result.point_at(1).to_a)
  end

  def test_set_point_too_many_arguments
    polygonmesh = setup_polygon_for_polygon_at
    point1 = Geom::Point3d.new(22, 33, 44)
    assert_raises(ArgumentError) do
      polygonmesh.set_point(1, point1, point1)
    end
  end

  def test_set_point_too_few_arguments
    polygonmesh = setup_polygon_for_polygon_at
    point1 = Geom::Point3d.new(22, 33, 44)
    assert_raises(ArgumentError) do 
      polygonmesh.set_point(1)
    end
  end

  def test_set_point_invalid_arguments
    polygonmesh = setup_polygon_for_polygon_at
    point1 = Geom::Point3d.new(22, 33, 44)
    assert_raises(ArgumentError) do 
      polygonmesh.set_point(nil)
    end

    assert_raises(TypeError) do
      polygonmesh.set_point("1", point1)
    end

    assert_raises(ArgumentError) do
      polygonmesh.set_point(1, "point1")
    end

    assert_raises(ArgumentError) do 
      polygonmesh.set_point([1, point1])
    end

    assert_raises(ArgumentError) do
      polygonmesh.set_point(1, [point1])
    end
  end

  def test_set_uv
    polygonmesh = setup_polygon_for_uv
    uv1 = Geom::Point3d.new(0, 0, 0)
    uv2 = Geom::Point3d.new(2, 0, 0)
    uv3 = Geom::Point3d.new(2, 2, 0)
    uv4 = Geom::Point3d.new(0, 2, 0)
    polygonmesh.set_uv(1, uv1, true)
    polygonmesh.set_uv(2, uv2, true)
    polygonmesh.set_uv(3, uv3, true)
    polygonmesh.set_uv(4, uv4, true)
    assert_equal(uv1.to_a, polygonmesh.uv_at(1, true).to_a)
    assert_equal(uv2.to_a, polygonmesh.uv_at(2, true).to_a)
    assert_equal(uv3.to_a, polygonmesh.uv_at(3, true).to_a)
    assert_equal(uv4.to_a, polygonmesh.uv_at(4, true).to_a)
  end

  def test_set_uv_array_point
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], true)
    polygonmesh.set_uv(2, [2, 0, 0], true)
    polygonmesh.set_uv(3, [2, 2, 0], true)
    polygonmesh.set_uv(4, [0, 2, 0], true)
    assert_equal([0, 0, 0], polygonmesh.uv_at(1, true).to_a)
    assert_equal([2, 0, 0], polygonmesh.uv_at(2, true).to_a)
    assert_equal([2, 2, 0], polygonmesh.uv_at(3, true).to_a)
    assert_equal([0, 2, 0], polygonmesh.uv_at(4, true).to_a)
  end

  def test_set_uv_too_many_arguments
    polygonmesh = setup_polygon_for_uv
    point = Geom::Point3d.new(0, 0, 0)
    assert_raises(ArgumentError) do 
      polygonmesh.set_uv(1, point, true, true)
    end
  end

  def test_set_uv_too_few_arguments
    polygonmesh = setup_polygon_for_uv
    point = Geom::Point3d.new(0, 0, 0)
    assert_raises(ArgumentError) do 
      polygonmesh.set_uv(1, point)
    end

    assert_raises(ArgumentError) do
      polygonmesh.set_uv(1)
    end
  end

  def test_set_uv_invalid_arguments
    polygonmesh = setup_polygon_for_uv
    point = Geom::Point3d.new(0, 0, 0)
    assert_raises(TypeError) do 
      polygonmesh.set_uv("1", point, true)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.set_uv(1, "point", true)
    end

    assert_raises(ArgumentError) do 
      polygonmesh.set_uv([1, point, true])
    end

    assert_raises(ArgumentError) do 
      polygonmesh.set_uv(1, [point], true)
    end
  end

  def test_set_uv_invalid_boolean
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], "true")
  end

  def test_uv_at_from_textured_face
    polygonmesh = setup_polygon_for_uv_at_textured
    point1 = polygonmesh.uv_at(1, true)
    point2 = polygonmesh.uv_at(2, true)
    point3 = polygonmesh.uv_at(3, true)
    point4 = polygonmesh.uv_at(4, true)
    assert_kind_of(Geom::Point3d, point1)
    assert_kind_of(Geom::Point3d, point2)
    assert_kind_of(Geom::Point3d, point3)
    assert_kind_of(Geom::Point3d, point4)
    assert_equal([0, 0, 1.0], point1.to_a)
    assert_equal([-0.1788854381999832, -0.21908902300206645, 1.0], point2.to_a)
    assert_equal([0.1788854381999832, -0.3286335345030997, 1.0], point3.to_a)
    assert_equal([-0.13416407864998742, 0.10954451150103323, 1.0], point4.to_a)
  end

  def test_uv_at
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], true)
    polygonmesh.set_uv(2, [2, 0, 0], true)
    polygonmesh.set_uv(3, [2, 2, 0], true)
    polygonmesh.set_uv(4, [0, 2, 0], true)
    point1 = polygonmesh.uv_at(1, true)
    point2 = polygonmesh.uv_at(2, true)
    point3 = polygonmesh.uv_at(3, true)
    point4 = polygonmesh.uv_at(4, true)
    assert_kind_of(Geom::Point3d, point1)
    assert_kind_of(Geom::Point3d, point2)
    assert_kind_of(Geom::Point3d, point3)
    assert_kind_of(Geom::Point3d, point4)
    assert_equal([0, 0, 0], point1.to_a)
    assert_equal([2, 0, 0], point2.to_a)
    assert_equal([2, 2, 0], point3.to_a)
    assert_equal([0, 2, 0], point4.to_a)
  end

  def test_uv_at_invalid_boolean
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], true)
    result = polygonmesh.uv_at(1, "true")
    assert_kind_of(Geom::Point3d, result)
    assert_equal([0, 0, 0], result.to_a)
  end

  def test_uv_at_too_many_arguments
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], true)
    polygonmesh.set_uv(2, [2, 0, 0], true)
    polygonmesh.set_uv(3, [2, 2, 0], true)
    polygonmesh.set_uv(4, [0, 2, 0], true)

    assert_raises(ArgumentError) do
      polygonmesh.uv_at(1, true, true)
    end
  end

  def test_uv_at_too_few_arguments
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], true)
    polygonmesh.set_uv(2, [2, 0, 0], true)
    polygonmesh.set_uv(3, [2, 2, 0], true)
    polygonmesh.set_uv(4, [0, 2, 0], true)

    assert_raises(ArgumentError) do 
      polygonmesh.uv_at(1)
    end

    assert_raises(ArgumentError) do
      polygonmesh.uv_at
    end
  end

  def test_uv_at_invalid_arguments
    polygonmesh = setup_polygon_for_uv
    polygonmesh.set_uv(1, [0, 0, 0], true)
    polygonmesh.set_uv(2, [2, 0, 0], true)
    polygonmesh.set_uv(3, [2, 2, 0], true)
    polygonmesh.set_uv(4, [0, 2, 0], true)

    assert_raises(TypeError) do
      polygonmesh.uv_at("1", true)
    end

    assert_raises(ArgumentError) do
      polygonmesh.uv_at([1, true])
    end

    assert_raises(TypeError) do
      polygonmesh.uv_at(nil, true)
    end
  end

  def test_uvs
    polygonmesh = setup_polygon_for_uvs
    uvs = polygonmesh.uvs(true) 
    assert_kind_of(Array, uvs)
    assert_kind_of(Geom::Point3d, uvs[0])
    assert_equal(4, uvs.size)
    assert_equal([0, 0, 0], uvs[0].to_a)
    assert_equal([2, 0, 0], uvs[1].to_a)
    assert_equal([2, 2, 0], uvs[2].to_a)
    assert_equal([0, 2, 0], uvs[3].to_a)
  end

  def test_uvs_too_many_arguments
    polygonmesh = setup_polygon_for_uvs

    assert_raises(ArgumentError) do 
      polygonmesh.uvs(true, true)
    end
  end

  def test_uvs_too_few_arguments
    polygonmesh = setup_polygon_for_uvs
    
    assert_raises(ArgumentError) do
      polygonmesh.uvs
    end
  end

  def test_uvs_string_argument
    polygonmesh = setup_polygon_for_uvs

    result =  polygonmesh.uvs("true")
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_equal(4, result.size)
    assert_equal([0, 0, 0], result[0].to_a)
    assert_equal([2, 0, 0], result[1].to_a)
    assert_equal([2, 2, 0], result[2].to_a)
    assert_equal([0, 2, 0], result[3].to_a)

  end

  def test_uvs_integer_argument
    polygonmesh = setup_polygon_for_uvs
    result =  polygonmesh.uvs(1)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_equal(4, result.size)
    assert_equal([0, 0, 0], result[0].to_a)
    assert_equal([2, 0, 0], result[1].to_a)
    assert_equal([2, 2, 0], result[2].to_a)
    assert_equal([0, 2, 0], result[3].to_a)

    result =  polygonmesh.uvs(0)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_equal(4, result.size)
    assert_equal([0, 0, 0], result[0].to_a)
    assert_equal([2, 0, 0], result[1].to_a)
    assert_equal([2, 2, 0], result[2].to_a)
    assert_equal([0, 2, 0], result[3].to_a)
  end

  def test_uvs_nil_argument
    polygonmesh = setup_polygon_for_uvs
    result =  polygonmesh.uvs(nil)
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_equal(4, result.size)
    assert_equal([0, 0, 0], result[0].to_a)
    assert_equal([0, 0, 0], result[1].to_a)
    assert_equal([0, 0, 0], result[2].to_a)
    assert_equal([0, 0, 0], result[3].to_a)
  end

  def test_uvs_array_argument
    polygonmesh = setup_polygon_for_uvs
    result =  polygonmesh.uvs([nil])
    assert_kind_of(Array, result)
    assert_kind_of(Geom::Point3d, result[0])
    assert_equal(4, result.size)
    assert_equal([0, 0, 0], result[0].to_a)
    assert_equal([2, 0, 0], result[1].to_a)
    assert_equal([2, 2, 0], result[2].to_a)
    assert_equal([0, 2, 0], result[3].to_a)
  end

  def test_transform_Bang
    polygonmesh = setup_polygon_for_transform
    point1 = Geom::Point3d.new(100, 200, 300)
    transform = Geom::Transformation.new(point1)
    result = polygonmesh.transform!(transform)
    assert_kind_of(Geom::PolygonMesh, result)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
    assert_equal([100, 201, 302], result.points[0].to_a)
    assert_equal([100, 201, 302], polygonmesh.points[0].to_a)
  end

  def test_transform_Bang_array
    polygonmesh = setup_polygon_for_transform
    point1 = Geom::Point3d.new(100, 200, 300)
    transform = Geom::Transformation.new(point1)
    result = polygonmesh.transform!([1.0, 0.0, 0.0, 0.0, 
                                    0.0, 1.0, 0.0, 0.0, 
                                    0.0, 0.0, 1.0, 0.0,
                                    100.0, 200.0, 300.0, 1.0])
    assert_kind_of(Geom::PolygonMesh, result)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
    assert_equal([100, 201, 302], result.points[0].to_a)
    assert_equal([100, 201, 302], polygonmesh.points[0].to_a)
  end

  def test_transform_Bang_integer
    polygonmesh = setup_polygon_for_transform
    point1 = Geom::Point3d.new(100, 200, 300)
    transform = Geom::Transformation.new(point1)
    result = polygonmesh.transform!(1)
    assert_kind_of(Geom::PolygonMesh, result)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
    assert_equal([0, 1, 2], result.points[0].to_a)
    assert_equal([0, 1, 2], polygonmesh.points[0].to_a)
  end

  def test_transform_Bang_point3d
    polygonmesh = setup_polygon_for_transform
    point1 = Geom::Point3d.new(100, 200, 300)
    transform = Geom::Transformation.new(point1)
    result = polygonmesh.transform!(point1)
    assert_kind_of(Geom::PolygonMesh, result)
    assert_kind_of(Geom::PolygonMesh, polygonmesh)
    assert_equal([100, 201, 302], result.points[0].to_a)
    assert_equal([100, 201, 302], polygonmesh.points[0].to_a)
  end

  def test_transform_Bang_too_many_arguments
    polygonmesh = setup_polygon_for_transform
    point1 = Geom::Point3d.new(100, 200, 300)
    transform = Geom::Transformation.new(point1)
    result = polygonmesh.transform!(transform)
    assert_raises(ArgumentError) do
      polygonmesh.transform!(transform, transform)
    end

    assert_raises(ArgumentError) do
      polygonmesh.transform!(transform, nil)
    end
  end

  def test_transform_Bang_too_few_arguments
    polygonmesh = setup_polygon_for_transform
    point1 = Geom::Point3d.new(100, 200, 300)
    transform = Geom::Transformation.new(point1)
    assert_raises(ArgumentError) do 
      polygonmesh.transform!
    end
  end

  def test_transform_Bang_invalid_arguments
    polygonmesh = setup_polygon_for_transform
    point1 = Geom::Point3d.new(100, 200, 300)
    transform = Geom::Transformation.new(point1)
    
    assert_raises(TypeError) do
      polygonmesh.transform!(nil)
    end

    optimus_prime = 100
    assert_raises(TypeError) do
      polygonmesh.transform!([optimus_prime, transform, transform, transform,
                              transform, transform, transform, transform,
                              transform, transform, transform, transform,
                              transform, transform, transform, transform])
    end

    assert_raises(TypeError) do
      polygonmesh.transform!("transform")
    end
  end
end # class

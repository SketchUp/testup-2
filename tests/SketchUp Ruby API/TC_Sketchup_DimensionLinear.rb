# Copyright:: Copyright 2018 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi

require "testup/testcase"

class TC_Sketchup_DimensionLinear < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model
    @dim = setup_attached_to_test
  end

  def teardown
    # ...
  end


  def mid_point(edge)
    pt1 = edge.start.position
    pt2 = edge.end.position
    Geom.linear_combination(0.5, pt1, 0.5, pt2)
  end

  # helper method for unit test
  def setup_attached_to_test
    start_with_empty_model
    entities = Sketchup.active_model.entities
    point1 = Geom::Point3d.new(0,0,0)
    point2 = Geom::Point3d.new(20,20,20)
    edge = entities.add_edges(point1, point2)
    comp_inst = entities.add_group(edge).to_component
    edge =  comp_inst.definition.entities.grep(Sketchup::Edge).first
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    dim = entities.add_dimension_linear([ip, point1], [ip, point2], Geom::Vector3d.new(0, 9, 0))
    return edge, dim
  end

  def test_start_attached_to
    edge, dim = setup_attached_to_test
    result = dim.start_attached_to
    assert_kind_of(Array, result)
    assert_kind_of(Sketchup::InstancePath, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(edge.start.position, result[0].leaf.position)
    assert_equal(ORIGIN, result[1])
  end

  def test_start_attached_to_invalid_arguments
    edge, dim = setup_attached_to_test
    assert_raises(ArgumentError) do
      dim.start_attached_to(nil)
    end
  end

  def test_start_attached_to_Set
    edge, dim = setup_attached_to_test
    result = dim.start_attached_to
    ip = Sketchup::InstancePath.new([result[0].to_a[0], edge])
    point = mid_point(edge).transform(ip.transformation.inverse)
    dim.start_attached_to = [ip, point]
    assert_kind_of(Sketchup::DimensionLinear, dim)
    result = dim.start_attached_to
    assert_kind_of(Array, result)
    assert_kind_of(Sketchup::InstancePath, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(point, result[1])
  end

  def test_start_attached_to_Set_invalid_assignment
    edge, dim = setup_attached_to_test
    assert_raises(TypeError) do
      dim.start_attached_to = "String"
    end

    assert_raises(TypeError) do
      dim.start_attached_to = ["hello", Geom::Point3d.new(1, 2, 3)]
    end

    ip = Sketchup::InstancePath.new([dim.start_attached_to[0][0], edge])
    assert_raises(ArgumentError) do
      dim.start_attached_to = [[ip], nil]
    end
  end

  def test_end_attached_to
    edge, dim = setup_attached_to_test
    result = dim.end_attached_to
    assert_kind_of(Array, result)
    assert_kind_of(Sketchup::InstancePath, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(edge.end.position, result[0].leaf.position)
    assert_equal(Geom::Point3d.new(20, 20, 20), result[1])
  end

  def test_end_attached_to_invalid_arguments
    edge, dim = setup_attached_to_test
    assert_raises(ArgumentError) do
      dim.end_attached_to(nil)
    end
  end

  def test_end_attached_to_Set
    edge, dim = setup_attached_to_test
    result = dim.end_attached_to
    ip = Sketchup::InstancePath.new([result[0].to_a[0], edge])
    point = Geom::Point3d.new(10, 10, 10).transform(ip.transformation.inverse)
    point = mid_point(edge).transform(ip.transformation.inverse)
    dim.end_attached_to = [ip, point]
    assert_kind_of(Sketchup::DimensionLinear, dim)
    result = dim.end_attached_to
    assert_kind_of(Array, result)
    assert_kind_of(Sketchup::InstancePath, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(point, result[1])
  end

  def test_end_attached_to_Set_invalid_assignment
    edge, dim = setup_attached_to_test
    assert_raises(TypeError) do
      dim.end_attached_to = "String"
    end

    assert_raises(TypeError) do
      dim.end_attached_to = ["hello", Geom::Point3d.new(1, 2, 3)]
    end

    ip = Sketchup::InstancePath.new([dim.end_attached_to[0][0], edge])
    assert_raises(ArgumentError) do
      dim.end_attached_to = [[ip], nil]
    end
  end
end
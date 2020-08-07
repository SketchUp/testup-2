# Copyright:: Copyright 2018 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Jin Yi

require "testup/testcase"

class TC_Sketchup_Text < TestUp::TestCase

  def setup
    start_with_empty_model
    @text = setup_attached_to_test
  end

  def teardown
    # ...
  end

  # helper functions for unit tests
  def add_test_face
    model = Sketchup.active_model
    model.entities.add_face([0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0])
  end

  def add_instance
    face = add_test_face
    model = Sketchup.active_model
    group = model.entities.add_group(face)
    group.to_component
  end

  def setup_instance_test
    add_instance
    comp_inst = Sketchup.active_model.active_entities.first
    comp_inst.definition.entities.grep(Sketchup::Edge) { |edge|
      if edge.start.position == Geom::Point3d.new(9, 0, 0)
        if edge.end.position == Geom::Point3d.new(9, 9, 0)
          return comp_inst, edge, edge.start.position, edge.end.position
        end
      end
    }
  end

  def setup_attached_to_test
    comp_inst, edge, start_pt = setup_instance_test
    ip = Sketchup::InstancePath.new([comp_inst, edge])
    Sketchup.active_model.entities.add_text("su", [ip, start_pt],
                                            [30, 30, 0])
  end

  def test_attached_to
    result = @text.attached_to
    assert_kind_of(Array, result)
    assert_kind_of(Sketchup::InstancePath, result[0])
    assert_kind_of(Geom::Point3d, result[1])
  end

  def test_attached_to_invalid_argument
    assert_raises(ArgumentError) do
      @text.attached_to(nil)
    end
  end

  def test_attached_to_Set
    temp = @text.attached_to
    result = @text.attached_to = [temp[0], Geom::Point3d.new(3, 3, 3)]
    assert_kind_of(Array, result)
    assert_kind_of(Sketchup::InstancePath, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(temp[0], result[0])
    assert_equal([3, 3, 3], result[1].to_a)
  end

  def test_attached_to_Set_invalid_assignment
    assert_raises(TypeError) do
      @text.attached_to = "string"
    end

    assert_raises(TypeError) do
      @text.attached_to = [nil, Geom::Point3d.new(1, 1, 1)]
    end

    assert_raises(ArgumentError) do
      @text.attached_to = [@text.attached_to[0], nil]
    end
  end

  def test_attached_to_Set_array
    start_with_empty_model
    comp_inst, edge, start_pt = setup_instance_test
    path = [comp_inst, edge]
    text = Sketchup.active_model.entities.add_text("su", [path, start_pt],
                                                  [30, 30, 0])
    text.attached_to = [path, Geom::Point3d.new(9, 3, 0)]
    result = text.attached_to
    assert_kind_of(Array, result)
    assert_kind_of(Sketchup::InstancePath, result[0])
    assert_kind_of(Geom::Point3d, result[1])
    assert_equal(path, result[0].to_a)
    assert_equal([9, 3, 0], result[1].to_a)
  end

  def test_attached_to_Set_array_invalid_assignment
    assert_raises(ArgumentError) do
      @text.attached_to = [["hippo"], Geom::Point3d.new(1, 1, 1)]
    end

    comp_inst, edge, start_pt = setup_instance_test
    assert_raises(ArgumentError) do
      @text.attached_to = [["llama", edge], Geom::Point3d.new(1, 1, 1)]
    end

    assert_raises(ArgumentError) do
      @text.attached_to = [[comp_inst, "goat"], Geom::Point3d.new(1, 1, 1)]
    end

    assert_raises(ArgumentError) do
      @text.attached_to = [[nil, edge], Geom::Point3d.new(1, 1, 1)]
    end

    assert_raises(ArgumentError) do
      @text.attached_to = [[comp_inst, nil], Geom::Point3d.new(1, 1, 1)]
    end
  end
end
# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Paul Ballew

require "testup/testcase"

# class Sketchup::PickHelper
# http://www.sketchup.com/intl/en/developer/docs/ourdoc/pickhelper
class TC_Sketchup_PickHelper < TestUp::TestCase

  def setup
    start_with_empty_model()
    setup_camera
    
    # Handy variables
    @pick_helper = Sketchup.active_model.active_view.pick_helper
    @origin_point = Geom::Point3d.new(0, 0, 0)
    @start_point = Geom::Point3d.new(10, 10, 0)
    @end_point = Geom::Point3d.new(800, 500, 0)
    @near_point = Geom::Point3d.new(1, 1, 0)
    @far_point = Geom::Point3d.new(9999999, 9999999, 0)
    @negative_point = Geom::Point3d.new(-10, -10, 0)
    @z_point = Geom::Point3d.new(0, 0, 100)
  end

  def teardown
    Sketchup.active_model.selection.add(@pick_helper.all_picked)
  end

  def setup_camera
    eye = [50,-50,100]
    target = [50,0,0]
    up = [0,1,0]
    Sketchup.active_model.active_view.camera.set(eye, target, up)
  end
  
  def add_window_pick_data
    # Put some stuff in the model
    entities = Sketchup.active_model.active_entities
    entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    entities.add_edges([1,1,1], [2,2,2])
  end

  def add_boundingbox
    @boundingbox = Geom::BoundingBox.new
    @boundingbox.add([-10, -10, -10], [10, 10, 10])
  end
  
  def add_inside_edges
    entities = Sketchup.active_model.active_entities
    entities.add_edges([1, 0, 0], [2, 0, 0])
    entities.add_edges([0, 5, 0], [0, 6, 0])
    @num_inside_edges = 2
  end

  def add_crossing_edges
    entities = Sketchup.active_model.active_entities
    entities.add_edges([9, 0, 0], [11, 0, 0])
    entities.add_edges([0, 9, 0], [0, 11, 0])
    entities.add_edges([0, 0, 9], [0, 0, 11])
    @num_crossing_edges = 3
  end

  def add_outside_edges
    entities = Sketchup.active_model.active_entities
    entities.add_edges([11, 0, 0], [13, 0, 0])
    entities.add_edges([0, 11, 0], [0, 13, 0])
    entities.add_edges([0, 0, 11], [0, 0, 13])
    entities.add_edges([-11, 0, 0], [-13, 0, 0])
    entities.add_edges([0, -11, 0], [0, -13, 0])
    entities.add_edges([0, 0, -11], [0, 0, -13])
  end
  
  def add_inside_group
    # Inside group
    group = Sketchup.active_model.entities.add_group
    entities = group.entities
    entities.add_face([1,1,2], [5,1,2], [5,5,2], [1,5,2])
  end

  def add_crossing_group
    group = Sketchup.active_model.entities.add_group
    entities = group.entities
    entities.add_face([1,1,5], [5,1,5], [5,5,5], [1,5,5])
    entities.add_face([6,6,5], [12,6,5], [12,12,5], [6,12,5])
  end

  
  # ========================================================================== #
  # method Sketchup::PickHelper.window_pick
  # http://www.sketchup.com/intl/developer/docs/ourdoc/pickhelper#window_pick

  def test_window_pick_api_example
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    ph = Sketchup.active_model.active_view.pick_helper
    start_point = Geom::Point3d.new(100, 100, 0)
    end_point = Geom::Point3d.new(500, 500, 0)
    num_picked = ph.window_pick start_point, end_point, Sketchup::PickHelper::PICK_CROSSING
  end

  def test_window_pick_same_point_values
    dup_point = Geom::Point3d.new(@start_point.x, @start_point.y, 0)
    generic_window_pick_test(@start_point, dup_point, Sketchup::PickHelper::PICK_CROSSING, 0)
  end

  def test_window_pick_same_points
    generic_window_pick_test(@start_point, @start_point, Sketchup::PickHelper::PICK_CROSSING, 0)
  end

  def test_window_pick_negative_values_inside
    generic_window_pick_test(@negative_point, @end_point, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_negative_values_crossing
    generic_window_pick_test(@negative_point, @end_point, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_huge_points_inside
    generic_window_pick_test(@start_point, @far_point, Sketchup::PickHelper::PICK_INSIDE, 2)
  end

  def test_window_pick_huge_points_crossing
    generic_window_pick_test(@start_point, @far_point, Sketchup::PickHelper::PICK_CROSSING, 5)
  end

  def test_window_pick_none_inside
    generic_window_pick_test(@origin_point, @near_point, Sketchup::PickHelper::PICK_INSIDE, 0)
  end

  def test_window_pick_none_crossing
    generic_window_pick_test(@origin_point, @near_point, Sketchup::PickHelper::PICK_CROSSING, 0)
  end

  def test_window_pick_some_inside
    generic_window_pick_test(@start_point, @end_point, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_some_crossing
    generic_window_pick_test(@start_point, @end_point, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_reverse_points_inside
    generic_window_pick_test(@end_point, @start_point, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_reverse_points_crossing
    generic_window_pick_test(@end_point, @start_point, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_with_z_gt_1_inside
    generic_window_pick_test(@z_point, @end_point, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_with_z_gt_1_crossing
    generic_window_pick_test(@z_point, @end_point, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_inside_on_crossing_group
    add_crossing_group
    end_point = Geom::Point3d.new(300, 400, 0)
    num_picked = @pick_helper.window_pick(@origin_point, end_point, Sketchup::PickHelper::PICK_INSIDE)
    assert_equal(0, num_picked)
    assert_equal(0, @pick_helper.all_picked.count)
  end

  def generic_window_pick_test(point1, point2, pick_method, expected_count)
    add_window_pick_data
    num_picked = @pick_helper.window_pick(point1, point2, pick_method)
    assert_equal(expected_count, num_picked)
    assert_equal(expected_count, @pick_helper.all_picked.count)
  end
  
  def test_window_pick_with_group
    add_window_pick_data
    group = Sketchup.active_model.entities.add_group
    entities = group.entities
    face = entities.add_face([20,0,10], [30,0,10], [30,10,10], [20,10,10])

    generic_window_pick_test(@start_point, @end_point, Sketchup::PickHelper::PICK_CROSSING, 5)
    assert_kind_of(Sketchup::Group, @pick_helper.all_picked()[4])
  end

  # ========================================================================== #
  # method Sketchup::PickHelper.boundingbox_pick
  # http://www.sketchup.com/intl/developer/docs/ourdoc/pickhelper#boundingbox_pick
  def test_boundingbox_pick_api_example
     boundingbox = Geom::BoundingBox.new
     boundingbox.add([1, 1, 1], [100, 100, 100])
     ph = Sketchup.active_model.active_view.pick_helper
 
     # Rotate the box 45' around the z-axis
     angle = 45
     transformation = Geom::Transformation.new(ORIGIN, Z_AXIS, angle)

     num_picked = ph.boundingbox_pick(boundingbox, Sketchup::PickHelper::PICK_CROSSING, transformation)
     if num_picked > 0
       Sketchup.active_model.selection.add(ph.all_picked)
     end
   end

  def test_boundingbox_pick_inside
    add_boundingbox
    add_inside_edges
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
    assert_equal(@num_inside_edges, num_picked)
    add_crossing_edges
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
    assert_equal(@num_inside_edges, num_picked)
    add_outside_edges
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
    assert_equal(@num_inside_edges, num_picked)
  end

  def test_boundingbox_pick_crossing
    add_boundingbox
    add_crossing_edges
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
    assert_equal(@num_crossing_edges, num_picked)
    add_inside_edges
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
    assert_equal(@num_crossing_edges + @num_inside_edges, num_picked)
    add_outside_edges
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
    assert_equal(@num_crossing_edges + @num_inside_edges, num_picked)
  end

  def test_boundingbox_pick_group_inside
    add_boundingbox
    add_inside_group
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
    assert_equal(1, num_picked)
    add_crossing_group
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
    assert_equal(1, num_picked)
    add_crossing_edges
    add_outside_edges
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
    assert_equal(1, num_picked)
  end

  def test_boundingbox_pick_group_crossing
    add_boundingbox
    add_crossing_group
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
    assert_equal(1, num_picked)
    add_inside_group
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
    assert_equal(2, num_picked)
    add_outside_edges
    assert_equal(2, num_picked)
  end
  
  def test_boundingbox_pick_rotated_box
    add_boundingbox
    add_outside_edges
    # Rotate the box 45' around the z-axis
    pt = Geom::Point3d.new(0,0,0)
    axis = vector = Geom::Vector3d.new(0,0,1)
    angle = 45
    transformation = Geom::Transformation.new(pt, axis, angle)
    # This should get the outside edges on the x/y plane
    num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING, transformation)
    assert_equal(4, num_picked)
  end
  
  def test_boundingbox_pick_invalid_boundingbox
    num_picked = 0
    assert_raises(TypeError) do
      num_picked = @pick_helper.boundingbox_pick('', 999)
    end
    assert_equal(0, num_picked)
  end

  def test_boundingbox_pick_invalid_pick_type
    add_boundingbox
    num_picked = 0
    assert_raises(ArgumentError) do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, 999)
    end
    assert_equal(0, num_picked)
  end

  def test_boundingbox_pick_too_few_arguments
    add_boundingbox
    num_picked = 0
    assert_raises(ArgumentError) do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox)
    end
    assert_equal(0, num_picked)
  end

end # class

# Copyright:: Copyright 2016 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


class TC_Sketchup_InputPoint < TestUp::TestCase

  def setup
    start_with_empty_model
    @path = create_test_instances
  end

  def teardown
    # ...
  end


  # Model > ComponentInstance > Group1 > Group2 > Group3 > Edge
  def create_test_instances
    model = Sketchup.active_model
    definition = model.definitions.add('TC_Sketchup_InputPoint')
    group1 = definition.entities.add_group
    group2 = group1.entities.add_group
    group2.transform!([10, 20, 30])
    group3 = group2.entities.add_group
    edge = group3.entities.add_line([10, 10, 10], [20, 20, 20])
    tr = Geom::Transformation.new([20, 30, 40])
    instance = model.entities.add_instance(definition, tr)
    [instance, group1, group2, group3, edge]
  end

  def compute_expected_transformation(path)
    instances = path.select { |entity|
      entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
    }
    tr = Geom::Transformation.new
    instances.each { |instance| tr = tr * instance.transformation }
    tr
  end

  def edge_mid_point(edge)
    pt1 = edge.start.position
    pt2 = edge.end.position
    Geom.linear_combination(0.5, pt1, 0.5, pt2)
  end


  # ========================================================================== #
  # class Sketchup::InputPoint

  def test_introduction_api_example
    # TODO:
  end


  # ========================================================================== #
  # method Sketchup::InputPoint.instance_path
  
  def test_instance_path
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    path = @path
    # Compute the screen coordinate of one of the entities in the path.
    view = Sketchup.active_model.active_view
    tr = compute_expected_transformation(path)
    point = edge_mid_point(path.last).transform(tr)
    screen_point = view.screen_coords(point)
    # Make the instance point pick this entity.
    inputpoint = Sketchup::InputPoint.new
    inputpoint.pick(view, screen_point.x, screen_point.y)

    result = inputpoint.instance_path
    assert_kind_of(Sketchup::InstancePath, result)
    assert_equal(path, result.to_a)
  end

  def test_instance_path_no_pick
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    inputpoint = Sketchup::InputPoint.new
    result = inputpoint.instance_path
    assert_nil(result)
  end

  def test_instance_path_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    inputpoint = Sketchup::InputPoint.new
    assert_raises(ArgumentError) {
      inputpoint.instance_path(nil)
    }
  end

end # class

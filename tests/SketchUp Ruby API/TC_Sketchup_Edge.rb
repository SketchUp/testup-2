# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Edge
# http://www.sketchup.com/intl/en/developer/docs/ourdoc/edge
class TC_Sketchup_Edge < TestUp::TestCase

  def setup
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
  # method Sketchup::Edges.faces
  # http://www.sketchup.com/intl/developer/docs/ourdoc/edge#faces

  def test_faces_api_example
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    edge = face.edges.first
    face.pushpull(100, true)

    edge_faces = edge.faces
    # edge_faces => [#<Sketchup::Face:0x7614030>, #<Sketchup::Face:0x761fe20>]
  end # test

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
  end # test

  def test_faces_incorrect_number_of_arguments
    edge = create_test_edge_shared_by_two_faces()

    assert_equal(0, edge.method(:faces).arity)

    assert_raises(ArgumentError) do
      edge.faces(1)
    end
  end # test


end # class

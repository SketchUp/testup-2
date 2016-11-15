# Copyright:: Copyright 2016 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Entities
class TC_Sketchup_Entities < TestUp::TestCase

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end

  def add_test_face
    model = Sketchup.active_model
    face = model.entities.add_face([0, 0, 0], [9, 0, 0], [9, 9, 0], [0, 9, 0])
	return face
  end
  
  def get_transform_points
	return [
      Geom::Point3d.new( 2,  0, 0),
      Geom::Point3d.new(-2,  0, 0),
      Geom::Point3d.new( 0,  2, 0),
      Geom::Point3d.new( 0, -2, 0)
    ]
  end
  
  def get_faces_points (face)
    points = []
    face.vertices.each do |vertex|
      points.push(vertex.position)
    end
    return points
  end
  
  def get_transformed_points (points)
    init_points = points
	shift_points = get_transform_points
	assert_equal(init_points.count, shift_points.count)
	points = []
	for i in 0..(init_points.count-1)
	  points.push(init_points[i] + shift_points[i].to_a)
	end
	return points
  end
  
  def get_entities_faces (entities)
    faces = []
    entities.each do |entity|
      if entity.typename == "Face"
        faces.push(entity)
      end
    end
    return faces
  end
  
  def sort_points (points)
    return points.sort{|p1,p2| p1.to_s <=> p2.to_s}
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
    entities = Sketchup.active_model.entities
    face = add_test_face

    vectors = [
      Geom::Vector3d.new( 2,  0, 0)
    ]
    assert_raises(ArgumentError) {
      entities.transform_by_vectors(face.vertices, vectors)
    }
  end

end # class

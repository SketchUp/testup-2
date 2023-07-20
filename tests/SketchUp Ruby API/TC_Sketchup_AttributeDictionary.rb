# Copyright:: Copyright 2017 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"


# class Sketchup::AttributeDictionary
class TC_Sketchup_AttributeDictionary < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    model = start_with_empty_model
    # start_with_empty_model doesn't remove attributes.
    model.attribute_dictionaries.delete(self.class.name)
  end

  def teardown
    # ...
  end


  def get_test_dictionary
    Sketchup.active_model.attribute_dictionary(self.class.name, true)
  end


  # ========================================================================== #
  # method Sketchup::AttributeDictionary.[]

  def test_Operator_Get_length
    dictionary = get_test_dictionary
    dictionary['Length'] = 1200.mm
    result = dictionary['Length']
    assert_kind_of(Length, result)
    assert_equal(1200.mm, result)
  end

  def test_Operator_Get_integer
    dictionary = get_test_dictionary
    dictionary['Integer'] = 42
    result = dictionary['Integer']
    assert_kind_of(Integer, result)
    assert_equal(42, result)
  end

  def test_Operator_Get_float
    dictionary = get_test_dictionary
    dictionary['Float'] = 1.618
    result = dictionary['Float']
    assert_kind_of(Float, result)
    assert_equal(1.618, result)
  end

  def test_Operator_Get_string
    dictionary = get_test_dictionary
    dictionary['String'] = 'Hello World'
    result = dictionary['String']
    assert_kind_of(String, result)
    assert_equal('Hello World', result)
  end

  def test_Operator_Get_color
    dictionary = get_test_dictionary
    dictionary['Sketchup::Color'] = Sketchup::Color.new(255, 128, 64)
    result = dictionary['Sketchup::Color']
    assert_kind_of(Sketchup::Color, result)
    assert_equal(Sketchup::Color.new(255, 128, 64).to_a, result.to_a)
  end

  def test_Operator_Get_time
    dictionary = get_test_dictionary
    expected = Time.now
    dictionary['Time'] = expected
    result = dictionary['Time']
    assert_kind_of(Time, result)
    assert_equal(expected.to_i, result.to_i)
  end

  def test_Operator_Get_point
    dictionary = get_test_dictionary
    dictionary['Geom::Point3d'] = Geom::Point3d.new(1, 2, 3)
    result = dictionary['Geom::Point3d']
    assert_kind_of(Geom::Point3d, result)
    assert_equal(Geom::Point3d.new(1, 2, 3), result)
  end

  def test_Operator_Get_vector
    dictionary = get_test_dictionary
    dictionary['Geom::Vector3d'] = Geom::Vector3d.new(7, 8, 9)
    result = dictionary['Geom::Vector3d']
    assert_kind_of(Geom::Vector3d, result)
    assert_equal(Geom::Vector3d.new(7, 8, 9), result)
  end

  def test_Operator_Get_array
    dictionary = get_test_dictionary
    expected = [
      1200.mm,
      42,
      1.618,
      'Hello World',
      Sketchup::Color.new(255, 128, 64),
      Time.now,
      Geom::Point3d.new(1, 2, 3),
      Geom::Vector3d.new(7, 8, 9)
    ]
    dictionary['Array'] = expected
    result = dictionary['Array']
    assert_kind_of(Array, result)
    assert_equal(expected[0], result[0])
    assert_equal(expected[1], result[1])
    assert_equal(expected[2], result[2])
    assert_equal(expected[3], result[3])
    assert_equal(expected[4].to_a, result[4].to_a)
    assert_equal(expected[5].to_i, result[5].to_i)
    assert_equal(expected[6], result[6])
    assert_equal(expected[7], result[7])
  end

end # class

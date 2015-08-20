# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Sketchup::Image
# http://www.sketchup.com/intl/developer/docs/ourdoc/image
class TC_Sketchup_Image < TestUp::TestCase

  def setup
    start_with_empty_model()
  end

  def teardown
    # ...
  end


  def create_test_image
    entities = Sketchup.active_model.entities
    filename = File.join(__dir__, File.basename(__FILE__, ".*"), "test.jpg")
    image = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)
    image
  end


  # ========================================================================== #
  # method Sketchup::Image.explode
  # http://www.sketchup.com/intl/developer/docs/ourdoc/image#explode

  def test_explode_api_example
    model = Sketchup.active_model
    path = "Plugins/su_dynamiccomponents/images"
    image_file = Sketchup.find_support_file("report_tool.png", path)
    image = model.active_entities.add_image(image_file, ORIGIN, 300)
    entities = image.explode
  end

  def test_explode
    image = create_test_image()
    result = image.explode
    assert_kind_of(Array, result)
    assert(image.deleted?)
  end

  def test_explode_return_entities
    skip("Fixed in SU2015") if Sketchup.version.to_i < 15
    image = create_test_image()
    result = image.explode
    assert_kind_of(Array, result)
    assert(!result.empty?, "Returned array wasn't empty.")
    assert(result.all? { |entity| entity.is_a?(Sketchup::Entity)})
  end

  def test_explode_incorrect_number_of_arguments_one
    image = create_test_image()
    assert_raises ArgumentError do
      image.explode(123)
    end
  end


end # class

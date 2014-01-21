# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


# module Geom
# http://www.sketchup.com/intl/developer/docs/ourdoc/geom
class TC_Geom < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # module Geom
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom

  def test_introduction_api_example_1
    assert_nothing_raised do
      line = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
      line = [Geom::Point3d.new(0, 0, 0), Geom::Point3d.new(0, 0, 100)]
    end
  end # test


  def test_introduction_api_example_2
    assert_nothing_raised do
      plane = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
      plane = [0, 0, 1, 0]
    end
  end # test


  # ========================================================================== #
  # method Geom.closest_points
  # http://www.sketchup.com/intl/developer/docs/ourdoc/geom#closest_points

  def test_closest_points_api_example
    assert_nothing_raised do
       line1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1)]
       line2 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 100)]
       # 0,0,0 on each line should be closest because both lines start from
       # that point.
       points = Geom.closest_points(line1, line2)
    end
  end # test

  def test_closest_points_dummy
    assert(false, 'Oh noes!')
  end # test

  def test_closest_points_skipped_dummy
    skip('not this time!')
  end # test


end # class

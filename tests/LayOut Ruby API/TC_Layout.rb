# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# module Layout
# http://www.sketchup.com/developer/layout/docs/layout
class TC_Layout < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Layout.application_name
  # http://www.sketchup.com/developer/layout/docs/layout#application_name

  def test_application_name
    result = Layout.application_name
    assert_kind_of(String, result)
    assert_equal('LayOut', result)
  end # test


end # class

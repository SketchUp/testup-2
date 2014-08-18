# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


# Set of tests triggering different result types.
class TC_TestReadOnlyDialog < TestUp::TestCase

  def setup
    disable_read_only_flag_for_test_models()
  end

  def teardown
    restore_read_only_flag_for_test_models()
  end


  # ========================================================================== #

  def test_open_read_only_file
    basename = File.basename(__FILE__, ".*")
    test_model = File.join(__dir__, basename, "Cube.skp")
    Sketchup.open_file(test_model)
    Sketchup.active_model.close(true)
  end # test


end # class

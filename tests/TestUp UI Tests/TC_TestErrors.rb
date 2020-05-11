# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


module TestUp
module Tests
  # Set of tests triggering different result types.
  class TC_TestErrors < TestUp::TestCase

    def setup
      # ...
    end

    def teardown
      # ...
    end


    # ========================================================================== #

    # Ensure that error failures expand the test case.
    def test_error_only_test_case
      raise ArgumentError, 'All your base are belong to us!'
    end # test


  end # class
end
end

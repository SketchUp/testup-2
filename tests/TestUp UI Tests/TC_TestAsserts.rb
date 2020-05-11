# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


module TestUp
module Tests
  # Set of tests triggering different result types.
  class TC_TestAsserts < TestUp::TestCase

    def setup
      # ...
    end

    def teardown
      # ...
    end


    # ========================================================================== #

    # Ensure that assert failures expand the test case.
    def test_assert_only_test_case
      assert(false)
    end # test

  end # class
end
end

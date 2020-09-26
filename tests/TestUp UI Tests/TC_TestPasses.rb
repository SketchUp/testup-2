# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


module TestUp
module Tests
  # Set of tests triggering different result types.
  class TC_TestPasses < TestUp::TestCase

    def setup
      # ...
    end

    def teardown
      # ...
    end


    # ========================================================================== #

    # Ensure that passing tests doesn't expand the test case.
    def test_pass_only_test_case
      assert(true)
    end # test

  end # class
end
end

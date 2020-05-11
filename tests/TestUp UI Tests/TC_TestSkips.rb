# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


module TestUp
module Tests
  # Set of tests triggering different result types.
  class TC_TestSkips < TestUp::TestCase

    def setup
      # ...
    end

    def teardown
      # ...
    end


    # ========================================================================== #

    # Ensure that skips doesn't expand the test case.
    def test_skip_only_test_case
      skip('skip skip skip to my lou')
    end # test

  end # class
end
end

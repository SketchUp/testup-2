#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/taskbar_progress'


module TestUp
  class TestProgress < TaskbarProgress

    def initialize(num_tests: 0) # Ruby 2.0 doesn't support required named args
      # TODO: Hack!
      TestUp.instance_variable_set(:@num_tests_being_run, num_tests)
    end

  end # class
end # module

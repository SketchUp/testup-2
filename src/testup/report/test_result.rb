#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'


module TestUp
  module Report
    TestResult = Struct.new(
        :run_time,   # Integer (seconds)
        :assertions, # Integer
        :skipped,    # Boolean
        :passed,     # Boolean
        :error,      # Boolean
        :failures,   # Array<TestFailure>
      ) do

      def to_json(*args)
        to_h.to_json(*args)
      end

    end
  end # module
end # module

#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'

require 'testup/from_hash'


module TestUp
  module Report
    TestResult = Struct.new(
        :run_time,   # Float (seconds)
        :assertions, # Integer
        :skipped,    # Boolean
        :passed,     # Boolean
        :error,      # Boolean
        :failures,   # Array<TestFailure>
      ) do

      extend FromHash

      def self.typed_structure
        {
          run_time: :to_f,
          assertions: :to_i,
          skipped: :bool,
          passed: :bool,
          error: :bool,
          failures: [Report::TestFailure]
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

    end
  end # module
end # module

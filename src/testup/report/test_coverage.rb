#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'


module TestUp
  module Report
    class TestCoverage

      attr_reader :percent, :missing

      def initialize(percent, missing)
        @percent = percent
        @missing = restructure(missing)
      end

      def to_h
        {
          percent: @percent,
          # missing: @missing,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      private

      # TODO: Refactor out this when TestUp::Coverage is cleaned up to generate
      # Report objects directly.
      def restructure(missing)
        missing.map { |test_case_name, tests_names|
          tests = tests_names.map { |test_name|
            Report::Test.new(test_name, missing: true)
          }
          Report::TestCase.new(test_case_name, tests)
        }
      end

    end # class
  end # module
end # module

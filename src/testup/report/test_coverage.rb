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
    class TestCoverage

      extend FromHash

      attr_reader :percent, :missing

      # @param [Float] percent
      # @param [Hash, Array<Report::TestCase>]
      def initialize(percent, missing)
        @percent = percent.to_f
        @missing = restructure(missing)
      end

      # @return [Hash]
      def to_h
        {
          percent: @percent,
          # missing: @missing,
        }
      end

      # @return [String]
      def to_json(*args)
        to_h.to_json(*args)
      end

      private

      def self.typed_structure
        {
          percent: :to_f,
          missing: [Report::TestCase],
        }
      end

      # TODO: Refactor out this when TestUp::Coverage is cleaned up to generate
      # Report objects directly.
      #
      # @param [Hash] missing
      # @return [Array<Report::TestCase>]
      def restructure(missing)
        return missing unless missing.is_a?(Hash)
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

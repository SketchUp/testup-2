#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'
require 'set'

require 'testup/report/collection'
require 'testup/from_hash'
require 'testup/type_check'


module TestUp
  module Report
    class TestCase

      extend FromHash
      include Comparable
      include TypeCheck

      attr_reader :title, :id, :tests
      attr_writer :enabled, :expanded

      # @param [Hash] hash
      # @return [Report::TestCase]
      def self.from_hash(hash)
        title, enabled, expanded, tests = typed_values(hash)
        test_case = new(title, tests)
        test_case.enabled = enabled
        test_case.expanded = expanded
        test_case
      end

      # @param [String] title
      # @param [Array<Report::Test>] tests
      def initialize(title, tests = [])
        expect_all_type(Report::Test, tests)
        @title = title.to_s
        @id = title.to_sym
        @tests = Collection.new(tests)
        @enabled = true
        @expanded = false
      end

      def <=>(other)
        @id <=> other.id
      end

      def enabled?
        @enabled
      end

      def expanded?
        @expanded
      end

      def hash
        @id.hash
      end

      # @param [Report::TestCase] other_test_case
      # @return [nil]
      def merge_results(other_test_case)
        other_test_case.tests.each { |other_test|
          test = @tests[other_test]
          test.merge_result(other_test) if test
        }
        nil
      end

      # @param [Report::TestCase] other_test_case
      # @return [nil]
      def rediscover(other_test_case)
        # Prune removed items:
        other_tests = other_test_case.tests
        @tests.reject! { |test| other_tests[test].nil? }
        # Add new items:
        other_test_case.tests.each { |other_test|
          @tests << other_test unless @tests[other_test]
        }
        nil
      end

      # @param [Report::Test, String] test The basename of the expected test
      def test_covered?(test)
        title = test.is_a?(Report::Test) ? test.title : test
        @tests.any? { |t| t.title.start_with?(title) }
      end

      def to_h
        {
          title: @title,
          id: @id,
          enabled: @enabled,
          expanded: @expanded,
          tests: @tests.to_a,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      private

      def self.typed_structure
        {
          title: :to_s,
          enabled: :bool,
          expanded: :bool,
          tests: [Report::Test]
        }
      end

    end # class
  end # module
end # module

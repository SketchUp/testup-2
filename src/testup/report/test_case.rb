#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'
require 'set'

require 'testup/report/collection'
require 'testup/type_check'


module TestUp
  module Report
    class TestCase

      include Comparable
      include TypeCheck

      attr_reader :title, :id, :tests

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

      # @param [Report::Test, String] test The basename of the expected test
      def test_covered?(test)
        title = test.is_a?(Report::Test) ? test.title : test
        @tests.any? { |t| t.title.start_with?(title) }
      end

      def to_h
        {
          title: @title,
          id: @id,
          enabled: true,
          expanded: false,
          tests: @tests.to_a,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

    end # class
  end # module
end # module

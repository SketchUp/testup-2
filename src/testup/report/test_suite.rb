#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'
require 'set'

require 'testup/type_check'


module TestUp
  module Report
    class TestSuite

      include TypeCheck

      attr_reader :title, :id, :path, :test_cases, :coverage

      def initialize(title, path, test_cases = [], coverage: nil)
        expect_all_type(Report::TestCase, test_cases)
        @title = title.to_s
        @id = to_id(title)
        @path = path
        @test_cases = SortedSet.new(test_cases)
        @coverage = coverage
        merge_coverage(coverage) if coverage
      end

      # @param [Report::TestCase, String]
      # @return [Report::TestCase]
      def test_case(test_case)
        title = test_case.is_a?(Report::TestCase) ? test_case.title : test_case
        @test_cases.find { |tc| tc.title == title }
      end
      alias_method :[], :test_case

      # @param [Report::TestCase, String]
      def test_case?(test_case)
        !test_case(test_case).nil?
      end

      def to_h
        {
          title: @title,
          id: @id,
          path: @path,
          test_cases: @test_cases.to_a,
          coverage: @coverage,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      private

      def find_test_case(test_case)
        # TODO: Make TestCase#hash be hashes of it's id?
        @test_cases.find { |tc| tc == test_case }
      end

      def merge_coverage(coverage)
        coverage.missing.each { |missing_test_case|
          test_case = find_test_case(missing_test_case)
          if test_case.nil?
            @test_cases << missing_test_case
          else
            test_case.tests.merge(missing_test_case.tests)
          end
        }
      end

      def to_id(string)
        string.downcase.tr(' ', '_').to_sym
      end

    end # class
  end # module
end # module

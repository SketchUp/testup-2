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
    class TestSuite

      extend FromHash
      include TypeCheck

      attr_reader :title, :id, :path, :test_cases, :coverage

      # @param [Hash] hash
      # @return [Report::TestCase]
      def self.from_hash(hash)
        title, path, test_cases, coverage = typed_values(hash)
        new(title, path, test_cases, coverage: coverage)
      end

      # @param [String] title
      # @param [String] path
      # @param [Enumerable<Report::TestCase>] test_cases
      # @param [Report::Coverage] coverage
      def initialize(title, path, test_cases = [], coverage: nil)
        expect_type(String, title, 'title')
        expect_type(String, path, 'path')
        expect_all_type(Report::TestCase, test_cases)
        @title = title.to_s
        @id = to_id(title)
        @path = path
        @test_cases = Collection.new(test_cases)
        @coverage = coverage
        merge_coverage(coverage) if coverage
      end

      # @param [Report::Coverage] coverage
      def coverage=(coverage)
        raise ArgumentError, 'Coverage already merged' if @coverage
        @coverage = coverage
        merge_coverage(coverage) if coverage
      end

      # @param [Report::TestSuite] other_test_suite
      # @return [Report::TestSuite] it self
      def merge_results(other_test_suite)
        expect_type(Report::TestSuite, other_test_suite)
        other_test_suite.test_cases.each { |other_test_case|
          test_case = @test_cases[other_test_case]
          test_case.merge_results(other_test_case) unless test_case.nil?
        }
        self
      end

      # @return [Array<String>]
      def selected_tests
        tests = []
        test_cases.each { |test_case|
          test_case.tests.each { |test|
            tests << "#{test_case.title}##{test.title}" if test.enabled?
          }
        }
        tests
      end

      # @param [Report::TestSuite] other_test_suite
      # @return [Report::TestSuite] it self
      def rediscover(other_test_suite)
        expect_type(Report::TestSuite, other_test_suite)
        # Prune removed items:
        other_test_cases = other_test_suite.test_cases
        @test_cases.reject! { |test_case| other_test_cases[test_case].nil? }
        # Add/update new items:
        other_test_suite.test_cases.each { |other_test_case|
          test_case = @test_cases[other_test_case]
          if test_case
            test_case.rediscover(other_test_case)
          else
            @test_cases << other_test_case
          end
        }
        self
      end

      # @param [Report::TestCase, Symbol, String]
      # @return [Report::TestCase]
      def test_case(test_case)
        @test_cases[test_case]
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

      def self.typed_structure
        {
          title: :to_s,
          path: :to_s,
          test_cases: [Report::TestCase],
          coverage: Report::TestCoverage,
        }
      end

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

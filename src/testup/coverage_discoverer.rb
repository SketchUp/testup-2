#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/report/test_coverage'
require 'testup/manifest'


module TestUp
  class CoverageDiscoverer

    attr_reader :manifest

    # @param [String] path
    def initialize(path)
      @path = path
      manifest_path = File.join(path, Manifest::FILENAME)
      @manifest = Manifest.new(manifest_path)
    end

    # @param [Report::TestSuite] discovered_suite
    # @return [Report::TestCoverage]
    def report(discovered_suite)
      expected_test_cases = manifest_test_cases
      missing = find_missing_test_cases(discovered_suite, expected_test_cases)
      percent = compute_percentage(expected_test_cases, missing)
      Report::TestCoverage.new(percent, missing)
    end

    private

    # @param [Array<Report::TestCase>] expected
    # @param [Array<Report::TestCase>] missing
    # @return [Float]
    def compute_percentage(expected_test_case, missing)
      count_tests = lambda { |num, test_case| num + test_case.tests.size }
      num_expected = expected_test_case.inject(0, &count_tests)
      num_missing = missing.inject(0, &count_tests)
      return 0.0 if num_missing.zero? || num_expected.zero?
      (num_missing.to_f / num_expected.to_f) * 100.0
    end

    # @param [Report::TestSuite] discovered_suite
    # @return [Array<Report::TestCase>]
    def find_missing_test_cases(discovered_suite, expected_test_cases)
      missing_test_cases = []
      expected_test_cases.each { |expected_test_case|
        if discovered_suite.test_case?(expected_test_case)
          discovered_test_case = discovered_suite[expected_test_case]
          missing_tests = find_missing_tests(discovered_test_case,
                                             expected_test_case)
          missing_test_cases << missing_tests
        else
          missing_test_cases << expected_test_case
        end
      }
      missing_test_cases
    end

    # @param [Report::TestCase] discovered_test_case
    # @param [Report::TestCase] expected_test_case
    # @return [Report::TestCase]
    def find_missing_tests(discovered_test_case, expected_test_case)
      missing_tests = []
      expected_test_case.tests.each { |expected_test|
        unless discovered_test_case.test_covered?(expected_test)
          missing_tests << expected_test
        end
      }
      Report::TestCase.new(expected_test_case.title, missing_tests)
    end

    # @return [Array<Report::TestCase>]
    def manifest_test_cases
      expected = {}
      manifest.expected_methods.each { |expected_method|
        test_case_name, test_method_name = test_name(expected_method)
        expected[test_case_name] ||= []
        expected[test_case_name] << test_method_name
      }
      expected.map { |test_case_name, test_methods|
        tests = test_methods.map { |test_method_name|
          Report::Test.new(test_method_name)
        }
        Report::TestCase.new(test_case_name, tests)
      }
    end

    # @param [String] full_method_name
    # @return [Array(String, String)]
    def test_name(full_method_name)
      parts = split_method_name(full_method_name)
      method_name = parts.pop
      test_klass_name = "TC_#{parts.join('_')}"
      test_method_name = method_test_name(method_name)
      unless test_method_name =~ /[a-z_0-9]/i
        raise "Invalid test name: #{test_method_name}"
      end
      [test_klass_name, test_method_name]
    end

    # @param [String] full_method_name
    # @return [Array<String>]
    def split_method_name(full_method_name)
      klass, method = full_method_name.split('.')
      klass.split('::') << method
    end

    # @param [String] method_name
    # @return [String]
    def method_test_name(method_name)
      case method_name

      when '+'
        'test_Operator_Plus'
      when '-'
        'test_Operator_Minus'
      when '*'
        'test_Operator_Multiply'
      when '\\'
        'test_Operator_Divide'
      when '%'
        'test_Operator_Modulo'
      when '**'
        'test_Operator_Pow'

      when '=='
        'test_Operator_Equal'
      when '!='
        'test_Operator_NotEqual'
      when '>'
        'test_Operator_GreaterThan'
      when '<'
        'test_Operator_LessThan'
      when '>='
        'test_Operator_GreaterThanOrEqual'
      when '<='
        'test_Operator_LessThanOrEqual'
      when '<=>'
        'test_Operator_Sort'
      when '==='
        'test_Operator_CaseEquality'

      when '&'
        'test_Operator_And'
      when '|'
        'test_Operator_Or'
      when '^'
        'test_Operator_Xor'
      when '~'
        'test_Operator_Not'
      when '<<'
        'test_Operator_LeftShift'
      when '<<'
        'test_Operator_RightShift'

      when '[]'
        'test_Operator_Get'
      when '[]='
        'test_Operator_Set'

      else
        test_name = "test_#{method_name}"
        test_name.gsub!("!", "_Bang")
        test_name.gsub!("?", "_Query")
        test_name.gsub!("=", "_Set")
        test_name
      end
    end

  end # class
end # module

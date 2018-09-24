#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'set'

require 'testup/report/test_case'
require 'testup/report/test_suite'
require 'testup/report/test'
require 'testup/coverage_discoverer'
require 'testup/log'
require 'testup/testcase'


module TestUp
  class TestDiscoverer

    # Error type used when loading the .rb files containing the test cases.
    class TestCaseLoadError < StandardError
      attr_reader :original_error
      def initialize(error)
        @original_error = error
      end
    end

    attr_reader :errors

    # @param [Array<String>] test_suite_paths
    def initialize(test_suite_paths)
      unless test_suite_paths.is_a?(Enumerable)
        test_suite_paths = [test_suite_paths]
      end
      @test_suite_paths = test_suite_paths
      @errors = [] # Set of errors from last discovery.
    end

    # @return [Array<Report::TestSuite>]
    def discover
      Log.trace :discover, ">>> #{self.class}.discover"
      @errors.clear

      # Reset list of runnables MiniTest knows about.
      # Undefine all TestUp::TestCase sub-classes and remove them from
      # Minitest's list of known runnables.
      MiniTest::Runnable.runnables.reject! { |klass|
        next unless Sandbox.valid_test_class?(klass)
        path = klass.name.split('::').map(&:to_sym)
        leaf = path.pop
        parent = path.inject(Object) { |klass, symbol| klass.const_get(symbol) }
        parent.send(:remove_const, leaf)
        true
      }

      discovered_suites = Set.new
      @test_suite_paths.map { |test_suite_path|
        if !File.directory?(test_suite_path)
          Log.warn "Not a valid directory: #{test_suite_path}"
          next nil
        end

        # Derive the TestSuite name from the directory name and ensure they
        # are uniquely named.
        test_suite_title = File.basename(test_suite_path)
        if discovered_suites.include?(test_suite_title)
          # TODO: raise custom error and catch later for display in UI.
          raise "Duplicate testsuites: #{test_suite_title} - #{test_suite_path}"
        end
        discovered_suites << test_suite_title

        # Discover all the tests in the test suite.
        test_cases = discover_testcases(test_suite_path)
        suite = Report::TestSuite.new(test_suite_title, test_suite_path,
                                      test_cases)
        coverage = CoverageDiscoverer.new
        suite.coverage = coverage.report(suite)
        suite
      }.compact
    end

    private

    # @param [String] testsuite_path
    # @return [Array<Report::TestCase>]
    def discover_testcases(testsuite_path)
      Log.trace :discover, ">>> #{self.class}.discover_testcases(...)"
      Log.trace :discover, ">>>   testsuite_path: #{testsuite_path}"
      testcase_source_files = discover_testcase_source_files(testsuite_path)
      # TODO: Clean up this file. The Sandbox was added as a quick and dirty
      #       performance improvement.
      # Log.debug ">>>> Sandbox.reset(...)"
      Sandbox.reset
      # Log.debug ">>>> Sandbox.load(...)"
      testcase_source_files.each { |testcase_file|
        # Log.debug ">>>>   #{testcase_file}"
        Sandbox.load(testcase_file)
      }
      # Log.debug ">>>> Sandbox.test_classes(...)"
      Log.trace :discover, ">>>   test_cases: #{Sandbox.test_classes.size}"
      Sandbox.test_classes.map { |test_case|
        tests = test_case.test_methods.map { |test_title|
          Report::Test.new(test_title)
        }
        test_case_title = test_case.name
        Report::TestCase.new(test_case_title, tests)
      }
    end

    # @param [Array<String>] testsuite_paths
    # @return [Array<String>] Path to all test case files found.
    def discover_testcase_source_files(testsuite_path)
      # Log.debug ">>> #{self.class}.discover_testcase_source_files(...)"
      testcase_filter = File.join(testsuite_path, 'TC_*.rb')
      Dir.glob(testcase_filter)
    end

    # TODO: Move to separate file.
    module Sandbox
      def self.load(testcase_filename)
        # Attempt to load the testcase so it can be inspected for testcases and
        # test methods. Any errors is wrapped up in a custom error type so it can
        # be caught further up and displayed in the UI.
        begin
          Kernel.load testcase_filename
        rescue ScriptError, StandardError => error
          testcase_name = File.basename(testcase_filename, '.*')
          warn "#{error.class} Loading #{testcase_name}"
          warn self.format_load_backtrace(error)
          raise TestCaseLoadError.new(error)
        end
      end
      def self.sym_to_class(symbol)
        self.const_get(symbol)
      end
      def self.classes
        self.constants.select { |c| self.const_get(c).is_a?(Class) }
      end
      def self.test_classes
        self.minitest_runnables - @known
      end
      def self.reset
        @known = self.minitest_runnables
      end
      def self.valid_test_class?(klass)
        # Only accept sub-classes of TestUp::TestCase.
        klass.ancestors[1..-1].include?(TestUp::TestCase)
      end
      def self.minitest_runnables
        MiniTest::Runnable.runnables.select { |klass|
          self.valid_test_class?(klass)
        }
      end
      # @param [Exception] error
      # @return [String]
      def self.format_load_backtrace(error)
        file_basename = File.basename(__FILE__)
        index = error.backtrace.index { |line|
          line =~ /testup\/#{file_basename}:\d+:in `load'/i
        }
        filtered_backtrace = error.backtrace[0..index]
        error.message << "\n" << filtered_backtrace.join("\n")
      end
    end

  end # class
end # module

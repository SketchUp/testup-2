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
require 'testup/coverage'
require 'testup/log'


module TestUp
  class TestDiscoverer2

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
      @errors.clear

      # Reset list of runnables MiniTest knows about.
      MiniTest::Runnable.runnables.clear

      discovered_suites = Set.new
      @test_suite_paths.map { |test_suite_path|
        if !File.directory?(test_suite_path)
          Log.warn "Not a valid directory: #{test_suite_path}"
          next nil
        end

        # Derive the TestSuite name from the directory name.
        test_suite_title = File.basename(test_suite_path)
        if discovered_suites.include?(test_suite_title)
          # TODO: raise custom error and catch later for display in UI.
          raise "Duplicate testsuites: #{test_suite_title} - #{test_suite_path}"
        end
        discovered_suites << test_suite_title

        test_cases = discover_testcases(test_suite_path)

        # TODO: Make Coverage return Report::Coverage
        coverage_report = nil
        coverage = Coverage.new(test_suite_path)
        if coverage.has_manifest?
          percent = coverage.percent(missing_tests)
          missing = coverage.missing_tests(test_cases)
          coverage_report = Report::Coverage.new(percent, missing)
        end

        Report::TestSuite.new(test_suite_title, test_suite_path, test_cases,
          coverage: coverage_report)
      }.compact
    end

    private

    # @param [String] testsuite_path
    # @return [Array<Report::TestCase>]
    def discover_testcases(testsuite_path)
      testcase_source_files = discover_testcase_source_files(testsuite_path)
      # TODO: Clean up this file. The Sandbox was added as a quick and dirty
      #       performance improvement.
      Sandbox.reset
      testcase_source_files.each { |testcase_file|
        Sandbox.load(testcase_file)
      }
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
      testcase_filter = File.join(testsuite_path, 'TC_*.rb')
      Dir.glob(testcase_filter)
    end

    module Sandbox
      def self.load(testcase_filename)
        # Attempt to load the testcase so it can be inspected for testcases and
        # test methods. Any errors is wrapped up in a custom error type so it can
        # be caught further up and displayed in the UI.
        begin
          module_eval(File.read(testcase_filename), testcase_filename)
          Kernel.load testcase_filename # TODO: Needed? Can we 'move' the already evaluated test?
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
        # self.classes.map { |c| self.const_get(c) }.grep(TestUp::TestCase)
        klasses = []
        self.classes.each { |c|
          # klass = self.const_get(c)
          klass = Object.const_get(c)
          # klasses << klass if klass.singleton_class.ancestors.include?(TestUp::TestCase)
          klasses << klass if klass.ancestors.include?(TestUp::TestCase)
        }
        klasses
      end
      def self.reset
        self.classes.each { |klass|
          self.send(:remove_const, klass)
          Object.send(:remove_const, klass) if Object.constants.include?(klass)
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

    # @return [Array<Class>]
    def all_test_classes
      klasses = []
      ObjectSpace.each_object(Class) { |klass|
        klasses << klass if klass.name =~ /^TC_/
      }
      klasses
    end

    # Remove the old testcase class so changes can be made without reloading
    # SketchUp. This is done because MiniTest is made to be run as a traditional
    # Ruby script on a web server where the lifespan of objects isn't persistent
    # as it is in SketchUp.
    #
    # @param [Symbol] testcase
    # @return [Nil]
    def remove_old_tests(testcase)
      if Object.constants.include?(testcase)
        Object.send(:remove_const, testcase)
        # Remove any previously loaded versions from MiniTest. Otherwise MiniTest
        # will keep running them along with the new ones.
        MiniTest::Runnable.runnables.delete_if { |klass|
          klass.to_s == testcase.to_s
        }
        GC.start
      end
      nil
    end

  end # class
end # module

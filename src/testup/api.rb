#-------------------------------------------------------------------------------
#
# Copyright 2013-2024 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'pathname'

require 'testup/report/test_case'
require 'testup/report/test_result'
require 'testup/report/test_suite'
require 'testup/report/test'
require 'testup/debugger'
require 'testup/log'
require 'testup/reporter'
require 'testup/taskbar_progress'
require 'testup/test_discoverer'
require 'testup/test_runner'


module TestUp
  # @api TestUp
  module API

    # Writes the results to STDOUT in Json format.
    #
    # @param [TestUp::Report::TestSuite, Pathname, String] test_suite
    # @param [Hash] config
    # @option config [String] 'Seed' Integer numeric for the Minitest random seed.
    # @option config [String] 'Verbose' Turns on verbose reporting if key is present.
    # @option config [String] 'Output' JSON file to output results to.
    # @option config [Array] 'Tests'
    def self.run_suite_without_gui(test_suite, config = {})
      test_suite_path = if test_suite.is_a?(TestUp::Report::TestSuite)
                          Pathname.new(test_suite.path)
                        elsif test_suite.is_a?(Pathname)
                          test_suite
                        else
                          Pathname.new(test_suite.to_s)
                        end

      unless test_suite_path.exist?
        raise ArgumentError,
              "Test suite path does not exist: #{test_suite_path.expand_path}"
      end

      # Loaded here on demand to defer gem installation.
      require 'testup/json_ci_reporter'

      options = {
        ci: true, # TODO: Config?
        ui: false,
        verbose: true,
        clear_console: false,
        show_console: true,
      }
      options[:seed] = config['Seed'].to_i if config['Seed']
      options[:verbose] = !!config['Verbose'] if config.key?('Verbose')
      options[:ci_out] = config['Output'] if config.key?('Output')
      full_path = test_suite_path.expand_path.to_s
      test_suite = TestUp::API.discover_tests([full_path]).first

      title = test_suite.title
      path = test_suite.path
      tests = config['Tests'] || test_suite.selected_tests
      run_tests(tests, title: title, path: path, options: options) { |results|
        results
      }
    end

    # @example Run a test case:
    #   TestUp::API.run_tests(["TC_Sketchup_Edge#"], path: path)
    #
    # @example Run single test:
    #   TestUp::API.run_tests(["TC_Sketchup_Edge#start"], path: path)
    #
    # @example Run a set of test cases and/or tests:
    #   tests = [
    #     "TC_Sketchup_Face#",
    #     "TC_Sketchup_Edge#start", "TC_Sketchup_Edge#end"
    #   ]
    #   path = "path/to/testsuite/"
    #   TestUp::API.run_tests(tests, path: path)
    #
    # @todo The `path` parameter is not optional.
    # @todo The `title` parameter should be extracted from the path.
    #
    # @param [Array<String>] tests list of tests or test cases to run.
    # @param [String] title Name of test_suite
    # @param [String] path Path to the test_suite
    # @param [Hash] options
    # @option options [Boolean] :show_console Open the Ruby Console before running tests.
    # @option options [Boolean] :clear_console Clear the Ruby Console before running tests.
    # @option options [Boolean] :ci Generate JSON report to STDOUT.
    # @option options [String] :ci_out Pipe JSON report to file.
    # @option options [Boolean] :ui Update the TestUp dialog.
    # @option options [Integer] :seed Set the randomization seed for Minitest.
    # @option options [Boolean] :verbose
    # @yield [Report::TestSuite]
    # @return [Boolean]
    def self.run_tests(tests, title: 'Untitled', path: nil, options: {})
      if options[:show_console]
        TESTUP_CONSOLE.show
        TESTUP_CONSOLE.clear if options[:clear_console]
      end

      if tests.empty?
        Log.warn 'No tests selected to run.'
        return false
      end

      # Dump some test information that might be useful when reviewing test runs.
      TestUp::Debugger.output("Minitest Version: #{Minitest::VERSION}")
      Log.info "Minitest Version: #{Minitest::VERSION}"
      Log.info "Running test suite: #{title}"
      Log.info "> Tests: #{tests.size}"
      Log.info "> Seed: #{options[:seed]}" if options[:seed]
      Log.info "> Verbose: #{options[:verbose].inspect}"

      runner = TestRunner.new(title: title, path: path)
      runner.run(tests, options) { |results|
        # TODO: TestRunner should carry forward title and path.
        yield test_suite_from_results(title, path, results) if block_given?
      }
    end

    # @param [Report::TestSuite] test_suite
    # @param [Hash] options
    # @yield [Report::TestSuite]
    # @return [Boolean]
    def self.run_test_suite(test_suite, options: {})
      title = test_suite.title
      path = test_suite.path
      tests = test_suite.selected_tests
      run_tests(tests, title: title, path: path, options: options) { |results|
        yield results
      }
    end

    # @param [String] title
    # @param [String] path
    # @param [Array<Hash>] results
    # @return [Report::TestSuite]
    def self.test_suite_from_results(title, path, results)
      tests = {}
      results.each { |result|
        test_case_name = result[:test_case_name]
        test_name = result[:test_name]
        result_report = Report::TestResult.from_hash(result)
        tests[test_case_name] ||= []
        tests[test_case_name] << Report::Test.new(test_name, result_report)
      }
      test_cases = tests.map { |test_case_name, test_case_tests|
        Report::TestCase.new(test_case_name, test_case_tests)
      }
      Report::TestSuite.new(title, path, test_cases)
    end

    # @param [String] test_suite_paths
    # @return [Array<Report::TestSuite>]
    def self.discover_tests(test_suite_paths)
      Debugger.time("#{self}.discover_tests") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          Log.trace :discover, ">> TestDiscoverer.new(...)"
          test_discoverer = TestDiscoverer.new(test_suite_paths)
          Log.trace :discover, ">> test_discoverer.discover"
          discoveries = test_discoverer.discover
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
        discoveries
      }
    end

    # Suppresses a number of dialogs that might be triggered by the API for the
    # duration of the given block.
    def self.suppress_warning_dialogs(&block)
      if ::Test.respond_to?(:suppress_warnings=)
        cache = ::Test.suppress_warnings?
        ::Test.suppress_warnings = true
      end
      block.call
    ensure
      if ::Test.respond_to?(:suppress_warnings=)
        ::Test.suppress_warnings = cache
      end
      nil
    end

  end # module
end # module


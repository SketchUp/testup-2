#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/debug'
require 'testup/log'
require 'testup/reporter'
require 'testup/taskbar_progress'
require 'testup/test_discoverer'


module TestUp
  # @api TestUp
  module API

    # @example Run a test case:
    #   TestUp.run_tests(["TC_Sketchup_Edge#"])
    #
    # @example Run single test:
    #   TestUp.run_tests(["TC_Sketchup_Edge#start"])
    #
    # @example Run a set of test cases and/or tests:
    #   tests = [
    #     "TC_Sketchup_Face#",
    #     "TC_Sketchup_Edge#start", "TC_Sketchup_Edge#end"
    #   ]
    #   TestUp.run_tests(tests)
    #
    # @param [Array<String>] tests list of tests or test cases to run.
    # @param [String] testsuite Name of test_suite
    # @param [Hash] options
    # @yield [Report::TestSuite]
    # @return [Boolean]
    def self.run_tests(tests, title: 'Untitled', path: nil, options: {})
      if options[:show_console] # TODO: Add option to open Ruby Console.
        TESTUP_CONSOLE.show
        TESTUP_CONSOLE.clear
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
      Log.info "> Seed: #{seed}" if seed

      runner = TestRunner.new(title: title, path: path)
      runner.run(tests, options) { |results|
        yield results
      }
    end

    # @param [String] test_suite_paths
    # @return [Array<Report::TestSuite>]
    def self.discover_tests(test_suite_paths)
      Debugger.time("#{self}.discover_tests") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          test_discoverer = TestDiscoverer.new(test_suite_paths)
          discoveries = test_discoverer.discover
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
        discoveries
      }
    end

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


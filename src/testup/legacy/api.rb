#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/legacy/test_discoverer'
require 'testup/debug'
require 'testup/reporter'
require 'testup/taskbar_progress'


module TestUp
  module LegacyAPI

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
    # def self.run_tests(tests, title: 'Untitled', path: nil, seed: nil)
    def self.run_tests(tests, testsuite = "Untitled", options = {})
      # TODO: Create TestRunner class.
      # TODO: Add option to open Ruby Console.
      TESTUP_CONSOLE.show
      TESTUP_CONSOLE.clear
      if tests.empty?
        # TODO: Create logging wrapper over `puts`.
        puts "No tests selected to run."
        return false
      end
      # `options` argument is used when re-running test runs. It doesn't change
      # the user-selected seed.
      seed = options[:seed] || TestUp.settings[:seed]
      # Dump some test information that might be useful when reviewing test runs.
      TestUp::Debugger.output("Minitest Version: #{Minitest::VERSION}")
      puts "Minitest Version: #{Minitest::VERSION}"
      puts "Discovering tests...\n"
      self.discover_tests
      puts "Running test suite: #{testsuite}"
      puts "> Tests: #{tests.size}"
      puts "> Seed: #{seed}" if seed
      # If tests end with a `#` it means the whole test case should be run.
      # Automatically fix the regex.
      tests = tests.map { |pattern|
        if pattern =~ /\#$/
          pattern << ".+"
        end
        pattern
      }
      arguments = []
      arguments << "-n /^(#{tests.join('|')})$/"
      arguments << '--verbose' if TestUp.settings[:verbose_console_tests]
      if seed
        arguments << '--seed'
        arguments << seed.to_s
      end
      arguments << '--testup' if TestUp.settings[:run_in_gui]
      # TODO: Update progressbar based on tests run.
      TestUp.instance_variable_set(:@num_tests_being_run, tests.size) # TODO: Hack!
      progress = TaskbarProgress.new
      begin
        progress.set_state(TaskbarProgress::NORMAL)
        self.suppress_warning_dialogs {
          MiniTest.run(arguments)
        }
      rescue SystemExit
        puts 'Minitest called exit.'
      ensure
        progress.set_state(TaskbarProgress::NOPROGRESS)
      end
      puts "All tests done!"
      yield Reporter.results
      true
    end

    # @api TestUp
    #
    # @return [Hash{String => Hash}]
    #
    # TODO:
    # @param [String] test_suite_paths
    # @return [Array<Report::TestSuite>]
    def self.discover_tests
      Debugger.time("TestUp.discover_tests") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          paths = TestUp.settings[:paths_to_testsuites]
          test_discoverer = TestDiscovererLegacy.new(paths)
          discoveries = test_discoverer.discover
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
        discoveries
      }
    end

    # @api TestUp
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

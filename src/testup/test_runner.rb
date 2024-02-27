#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/api'
require 'testup/debug'
require 'testup/file_reporter'
require 'testup/log'
require 'testup/reporter'
require 'testup/test_progress'


module TestUp
  class TestRunner

    # @param [String] title
    # @param [String, nil] path
    def initialize(title: 'Untitled', path: nil)
      @title = title
      @path = path
    end

    # @param [Array<String>] tests
    # @param [Hash] options
    # @option options [Boolean] :ci Generate JSON report to STDOUT.
    # @option options [String] :ci_out Pipe JSON report to file.
    # @option options [Boolean] :ui Update the TestUp dialog.
    # @option options [Integer] :seed Set the randomization seed for Minitest.
    # @option options [Boolean] :verbose
    # @yield [Array<Report::TestSuite>]
    # return [Boolean]
    def run(tests, options = {})
      return false if tests.empty?
      API.discover_tests([@path])
      test_pattern = parse(tests)
      run_tests(test_pattern, options)
      yield Reporter.results
      true
    end

    private

    # @param [Array<String>] tests
    # @param [Hash] options
    # @option options [Boolean] :ci Generate JSON report to STDOUT.
    # @option options [String] :ci_out Pipe JSON report to file.
    # @option options [Boolean] :ui Update the TestUp dialog.
    # @option options [Integer] :seed Set the randomization seed for Minitest.
    # @option options [Boolean] :verbose
    # return [nil]
    def run_tests(tests, options)
      TestUp::FileReporter.set_run_info(@title, @path) # Hack!
      arguments = minitest_arguments(tests, options)
      # TODO: Update progressbar based on tests run.
      # `tests` is just a list of patterns, the actual number of matching tests
      # is different.
      progress = TestProgress.new(num_tests: tests.size)
      begin
        progress.set_state(TaskbarProgress::NORMAL)
        API.suppress_warning_dialogs {
          Minitest.run(arguments)
        }
      rescue SystemExit
        Log.warn 'Minitest called exit.'
      ensure
        progress.set_state(TaskbarProgress::NOPROGRESS)
      end
      Log.info "All tests done!"
      nil
    end

    # @param [Array<String>] tests
    # @param [Hash] options
    # @option options [Boolean] :ci Generate JSON report to STDOUT.
    # @option options [String] :ci_out Pipe JSON report to file.
    # @option options [Boolean] :ui Update the TestUp dialog.
    # @option options [Integer] :seed Set the randomization seed for Minitest.
    # @option options [Boolean] :verbose
    # return [Array<String>]
    def minitest_arguments(tests, options)
      arguments = []
      # List of patterns matching which tests to run.
      arguments << "-n /^(#{tests.join('|')})$/"
      # Enable for more verbose feedback.
      # arguments << '--verbose' if options[:verbose_console_tests]
      arguments << '--verbose' if options[:verbose] # TODO:
      # Allow tests to be run with a given seed, useful for replaying a test
      # that fails when run in a specific order.
      if options[:seed]
        arguments << '--seed'
        arguments << options[:seed].to_s
      end
      # When running TestUp from the UI, make sure to load the Minitest plugin.
      # arguments << '--testup' if options[:run_in_gui]
      arguments << '--testup' if options[:ui] # TODO:
      arguments << '--testup_ci' if options[:ci]
      arguments << "--testup_ci_out=#{options[:ci_out]}" if options[:ci_out]
      arguments
    end

    # @param [Array<String>] tests
    # return [Array<String>]
    def parse(tests)
      # If tests end with a `#` it means the whole test case should be run.
      # Automatically fix the regex so Minitest pick it up correctly.
      tests.map { |pattern|
        pattern << '.+' if pattern =~ /\#$/
        pattern
      }
    end

  end # class
end # module

#-------------------------------------------------------------------------------
#
# Copyright 2013-2024 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/minitest_setup.rb'


module TestUp
# Doc comment from Minitest::StatisticsReporter:
#
#   A reporter that gathers statistics about a test run. Does not do
#   any IO because meant to be used as a parent class for a reporter
#   that does.
#
#   If you want to create an entirely different type of output (eg,
#   CI, HTML, etc), this is the place to start.
#
# Records the result of each test, for {API.run_tests} to pass on. Used in
# every run, whether or not it is shown in the TestUp window, and prints
# nothing.
class Reporter < Minitest::StatisticsReporter

  @@results = []

  def self.results
    @@results
  end

  def start
    super
    # TODO(thomthom): Make this into an instance variable.
    @@results = []
  end

  def record(result)
    super
    @@results << process_results(result)
    TestUp.update_testing_progress(@@results.size)
  end

  private

  def process_results(result)
    {
      test_case_name: result.klass,
      test_name:      result.name,
      run_time:       result.time,
      skipped:        result.skipped?,
      error:          result.error?,
      passed:         result.passed?,
      assertions:     result.assertions,
      failures:       result.failures.map { |failure|
        {
          type:     failure.result_label,
          message:  failure.message,
          location: failure.location,
          # backtrace: failure.backtrace,
        }
      }
    }
  end

end # class

# Prints a summary of the run to the console, in place of Minitest's own
# output, which is turned off when tests run in the TestUp window.
class SummaryReporter < Minitest::StatisticsReporter

  def report
    super
    io.puts separator
    io.puts
    io.puts 'TestUp Results'.center(40)
    io.puts
    io.puts separator
    io.puts
    io.puts "     Tests: #{self.count}"
    io.puts "Assertions: #{self.assertions}"
    io.puts "  Failures: #{self.failures}"
    io.puts "    Errors: #{self.errors}"
    io.puts "     Skips: #{self.skips}"
    io.puts
    io.puts separator
  end

  private

  def separator
    '-' * 40
  end

end # class
end # module TestUp

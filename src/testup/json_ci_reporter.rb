#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/config'
require 'testup/gem_helper'

module TestUp

require 'json'
require 'time'

require 'minitest'

  GemHelper.require('minitest-reporters', 'minitest/reporters', version: '1.1.19')

  # https://github.com/edhowland/minitest-reporters-json_reporter
  # This gem hasn't been updated for a long time. It works with Ruby 3.x, but
  # the gemspec require Ruby 2.x. Vendoring a copy of it directly to work
  # around this. It has also been patched to work with Minitest 5.15.0.

  ##
  # Minitest Reporter that produces a JSON output for interface in
  # IDEs, CD/CI tools and codeeditors
  class JsonReporter < Minitest::Reporters::BaseReporter
    ##
    # Version of the Minitest::Reporters::JsonReporter gem.
    VERSION = '1.0.0'.freeze

    ##
    # Constructor for Minitest::Reporters::JsonReporter
    # Takes possible options. E.g. :verbose => true
    # def initialize(options = {})
    #   super
    # end

    ##
    # Hash that represents the final elements prior to being converted to JSON
    attr_accessor :storage

    ##
    # Called by runner to report the conclusion of the test run
    # Converts result of to_h to JSON and calls io.write to output it.
    def report
      super

      @storage = to_h
      # formate @storage as JSON and write to output stream
      io.write(JSON.dump(@storage))
    end

    protected

    ##
    # Convert summary and detail to  hash
    def to_h
      summary_h.merge(detail_h)
    end

    ##
    # Create the summary part of the JSON
    def summary_h
      {
        status: status_h,
        metadata: metadata_h,
        statistics: statistics_h,
        timings: timings_h
      }
    end

    ##
    # Create the detail part of the JSON.
    def detail_h
      h = { fails: failures_a }
      if options[:verbose]
        h[:skips] = skips_a
        h[:passes] = passes_a
      end
      h
    end

    ##
    # Returns the statushash portion of the output.
    def status_h
      {
        code: ['Failed', 'Passed with skipped tests', 'Success'][color_i],
        color: %w(red yellow green)[color_i]
      }.merge(extra_message_h)
    end

    ##
    # return index corresponding to red, yellow or green
    # if errors or failures, skips or passes (default)
    def color_i
      if (failures + errors) > 0
        0
      elsif skips > 0
        1
      else
        2
      end
    end

    ##
    # return a hash with status:message if skips > 0 and no verboseoption
    def extra_message_h
      if !options[:verbose] && skips > 0
        { message:
          'You have skipped tests. Run with --verbose for details.' }
      else
        {}
      end
    end

    ##
    # Returns the metadata hash portion of the output.
    def metadata_h
      {
        generated_by: self.class.name,
        version: self.class::VERSION,
        ruby_version: RUBY_VERSION,
        ruby_patchlevel: RUBY_PATCHLEVEL,
        ruby_platform: RUBY_PLATFORM,
        time: Time.now.utc.iso8601,
        options: transform(options)
      }
    end

    ##
    # Transforms the options hash part of the metadata object to represent the
    # 'io' object as the string 'STDOUT' if it is $stdout.
    def transform(opts)
      o = opts.clone
      o[:io] = o[:io].class.name
      o[:io] = 'STDOUT' if opts[:io] == STDOUT
      o
    end

    ##
    # Returns the statistics hash object as part of the output.
    def statistics_h
      {
        total: count,
        assertions: assertions,
        failures: failures,
        errors: errors,
        skips: skips,
        passes: (count - (failures + errors + skips))
      }
    end

    ##
    # Returns the timings hash object as part of the output.
    def timings_h
      {
        total_seconds: total_time,
        runs_per_second: count / total_time,
        assertions_per_second: assertions / total_time
      }
    end

    ##
    # Returns the fails array of failure or error hash objects as part of
    # the output.
    def failures_a
      tests.reject { |e| e.skipped? || e.passed? || e.failure.nil? }
            .map { |e| failure_h(e) }
    end

    ##
    # Returns either a failed_h or error_h given a result (test).
    def failure_h(result)
      if result.error?
        error_h(result)
      else
        failed_h(result)
      end
    end

    ##
    # Returns the error hash object given a result (test) as part of the
    # fails[] array.
    def error_h(result)
      h = result_h(result, 'error')
      h[:message] = result.failure.message
      h[:location] = location(result.failure)
      h[:backtrace] = filter_backtrace(result.failure.backtrace)
      h
    end

    ##
    # Returns the failure hash object given a result (test).
    def failed_h(result)
      h = result_h(result, 'failed')
      h[:message] = result.failure.message
      h[:location] = location(result.failure)
      h
    end

    ##
    # Returns the skips[] array object as part of the output.
    def skips_a
      tests.select(&:skipped?).map { |e| skip_h(e) }
    end

    ##
    # Returns the formatted skip hash object given a result (test).
    def skip_h(result)
      h = result_h(result, 'skipped')
      h[:message] = result.failure.message
      h[:location] = location(result.failure)
      h
    end

    ##
    # Returns the passes[] array object as part of the output.
    def passes_a
      tests.select(&:passed?).map { |e| result_h(e, 'passed') }
    end

    ##
    # Returns the common part of a result hash.
    # Given a type string and a result (test).
    # Includes the type, the class, the name and the time of the result.
    def result_h(result, type)
      {
        type: type,
        class: result.klass,
        name: result.name,
        assertions: result.assertions,
        time: result.time
      }
    end

    ##
    # Returns the location (pathname:line_number) of the line that produced
    # the failure or error.
    def location(exception)
      last_before_assertion = ''

      exception.backtrace.reverse_each do |s|
        break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
        last_before_assertion = s
      end

      last_before_assertion.sub(/:in .*$/, '')
    end
  end


  class CIJsonReporter < JsonReporter
    def initialize(options = {})
      super
      # Force the output to STDOUT, which allows it to be piped to file from the
      # terminal. The output will not be visible in the Ruby Console.
      out = STDOUT
      if options[:testup_ci_out]
        # $stdout.puts options[:testup_ci_out].inspect
        out = File.open(options[:testup_ci_out], 'w')
      end
      # $stdout.puts "CIJsonReporter"
      # $stdout.puts "> out: #{out.inspect}"
      self.io = out
    end
  end

end # module

#-------------------------------------------------------------------------------
#
# Copyright 2014-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/config'
require 'testup/log'
# require 'testup/debug_reporter' # TODO(thomthom)
require 'testup/file_reporter'
require 'testup/reporter'


module Minitest

  TestUp::Log.trace :minitest, 'Minitest TestUp Extension discovered...'

  def self.plugin_testup_options opts, options # :nodoc:
    opts.on '-t', '--testup', 'Run tests in TestUp GUI.' do
      TestUp.settings[:run_in_gui] = true
      options[:testup_gui] = true
    end
    opts.on '--testup_ci', 'Generate JSON report to STDOUT.' do
      options[:testup_ci] = true
    end
    opts.on '--testup_ci_out=PATH', 'Switch JSON report to file.' do |value|
      # p [:plugin_testup_options, :testup_ci_out, value]
      options[:testup_ci_out] = value
    end
  end

  # @param [Hash] options Options provided by {.plugin_testup_options}
  def self.plugin_testup_init(options)
    TestUp::Log.trace :minitest, 'Minitest TestUp Extension loading...'
    if options[:testup_gui]
      TestUp::Log.trace :minitest, 'Minitest TestUp Extension in GUI mode'
      # Disable the default reporters as otherwise they'll print lots of data to
      # the console while the test runs. No need for that.
      self.reporter.reporters.clear
      # Add the reporters needed for TestUp.
      self.reporter << TestUp::Reporter.new($stdout, options)
    else
      TestUp::Log.trace :minitest, 'Minitest TestUp Extension in console mode'
    end
    # Always log to file.
    # TODO(thomthom): Will this add multiple FileReporters?
    self.reporter << TestUp::FileReporter.new(options)
    # TODO(thomthom): Add option to enable DebugReporter
    # self.reporter << TestUp::DebugReporter.new(options)

    if options[:testup_ci]
      require 'testup/json_ci_reporter'
      self.reporter << TestUp::CIJsonReporter.new(options)
    end
  end

end # module Minitest

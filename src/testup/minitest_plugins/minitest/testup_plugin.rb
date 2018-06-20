#-------------------------------------------------------------------------------
#
# Copyright 2014-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/config'
require 'testup/log'
require 'testup/file_reporter'
require 'testup/reporter'


module Minitest

  TestUp::Log.trace :minitest, 'MiniTest TestUp Extension discovered...'

  def self.plugin_testup_options opts, options # :nodoc:
    opts.on '-t', '--testup', 'Run tests in TestUp GUI.' do
      TestUp.settings[:run_in_gui] = true
    end
  end

  def self.plugin_testup_init(options)
    TestUp::Log.trace :minitest, 'MiniTest TestUp Extension loading...'
    if TestUp.settings[:run_in_gui]
      TestUp::Log.trace :minitest, 'MiniTest TestUp Extension in GUI mode'
      # Disable the default reporters as otherwise they'll print lots of data to
      # the console while the test runs. No need for that.
      self.reporter.reporters.clear
      # Add the reporters needed for TestUp.
      self.reporter << TestUp::Reporter.new($stdout, options)
    else
      TestUp::Log.trace :minitest, 'MiniTest TestUp Extension in console mode'
    end
    # Always log to file.
    # TODO(thomthom): Will this add multiple FileReporters?
    self.reporter << TestUp::FileReporter.new(options)
  end

end # module Minitest

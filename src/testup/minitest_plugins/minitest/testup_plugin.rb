# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require File.join(__dir__, '..', '..', 'file_reporter.rb')
require File.join(__dir__, '..', '..', 'reporter.rb')


puts 'MiniTest TestUp Extension discovered...' # DEBUG

module Minitest

  def self.plugin_testup_options opts, options # :nodoc:
    opts.on '-t', '--testup', 'Run tests in TestUp GUI.' do
      TestUp.settings[:run_in_gui] = true
    end
  end

  def self.plugin_testup_init(options)
    puts 'MiniTest TestUp Extension loading...' # DEBUG
    if TestUp.settings[:run_in_gui]
      puts 'MiniTest TestUp Extension in GUI mode' # DEBUG
      # Disable the default reporters as otherwise they'll print lots of data to
      # the console while the test runs. No need for that.
      self.reporter.reporters.clear
      # Add the reporters needed for TestUp.
      self.reporter << TestUp::Reporter.new($stdout, options)
    else
      puts 'MiniTest TestUp Extension in console mode' # DEBUG
    end
    # Always log to file.
    # TODO(thomthom): Will this add multiple FileReporters?
    self.reporter << TestUp::FileReporter.new(options)
  end

end # module Minitest

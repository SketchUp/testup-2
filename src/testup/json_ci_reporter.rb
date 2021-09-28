#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/config'
require 'testup/gem_helper'

module TestUp

  GemHelper.require('minitest-reporters-json_reporter',
                    'minitest/reporters/json_reporter')
  # https://github.com/edhowland/minitest-reporters-json_reporter#usage
  # Minitest::Reporters.use! [ Minitest::Reporters::JsonReporter.new ]

  class CIJsonReporter < Minitest::Reporters::JsonReporter
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

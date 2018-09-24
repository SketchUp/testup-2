#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/config'


module TestUp
  module Debug

    module Timing

      def time(title = '', &block)
        start = Time.now
        result = block.call
        lapsed_time = Time.now - start
        Log.trace :timing, "Timing #{title}: #{lapsed_time}s"
        result
      end

    end # module

  end # module

  # Prints the Minitest help to the Ruby Console. Also shows a list of Minitest
  # plugins has been loaded.
  def self.display_minitest_help
    TESTUP_CONSOLE.show
    MiniTest.run(['--help'])
  rescue SystemExit
  end

  # TestUp.reload
  def self.reload
    original_verbose = $VERBOSE
    $VERBOSE = nil
    filter = File.join(PATH, '**/*.{rb,rbs}')
    files = Dir.glob(filter).each { |file|
      load file
    }
    @window_vue = nil
    files.length
  ensure
    $VERBOSE = original_verbose
  end

end # module

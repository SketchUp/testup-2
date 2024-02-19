#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/debugger'

# Load required extensions to the Sketchup::Console class in order to run the
# tests in the SketchUp console.
require 'testup/console'
$stdout = TestUp::TESTUP_CONSOLE
$stderr = TestUp::TESTUP_CONSOLE


# Load Minitest. This is a modification from minitest/autoload.rb which doesn't
# run the tests when SketchUp exits because Minitest.autoload uses at_exit {}.

require "rubygems"
require "minitest/spec"
require "minitest/mock"

module TestUp
  module MinitestPrepend
    def run_one_method(klass, method_name)
      TestUp::Debugger.output("Running: #{klass.name}.#{method_name}")
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = super
      elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
      TestUp::Debugger.output("> Elapsed time: #{'%.5f' % elapsed_time}s")
      result
    end
  end

  module RunnablePrepend
    def run(reporter, options = {})
      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//

      filtered_methods = runnable_methods.find_all { |m|
        filter === m || filter === "#{self}##{m}"
      }

      with_info_handler reporter do
        # Custom TestUp hook
        if !filtered_methods.empty? && self.respond_to?(:setup_testcase)
          TestUp::Debugger.output("setup_testcase: #{self.name}")
          setup_testcase
        end

        filtered_methods.each do |method_name|
          run_one_method self, method_name, reporter
        end

        # Custom TestUp hook
        if !filtered_methods.empty? && self.respond_to?(:teardown_testcase)
          TestUp::Debugger.output("teardown_testcase: #{self.name}")
          teardown_testcase
        end
      end
    end # def run
  end
end

# TestUp modifications of Minitest
Minitest.singleton_class.prepend TestUp::MinitestPrepend

Minitest::Runnable.prepend TestUp::RunnablePrepend


# TODO(thomthom): Not sure if this is needed.
# Force the parallel executer to not spawn any threads.
# With older versions (5.4) of Minitest there were no issues. But later in 5.9
# we started seeing Error: #<fatal: No live threads left. Deadlock?>.
# The SketchUp Ruby API can only be used from the main thread so we must ensure
# that Minitest doesn't start spawning threads.
Minitest.parallel_executor = Minitest::Parallel::Executor.new(0)


# Configure Ruby such that the TestUp reporter can be found without creating
# gem for it.
#
# Minitest uses Gem.find_files to look for extensions by globbing
# { }"minitest/*_plugin.rb". To avoid making a gem that needs installing, make
# use of the fact that by default Gem.find_files will search in $LOAD_PATH.
#
# Verify by checking after `Minitest.run`:
# Minitest.extensions
# > ["pride", "testup"]
$LOAD_PATH << File.join(__dir__, 'minitest_plugins')

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


# Load MiniTest. This is a modification from minitest/autoload.rb which doesn't
# run the tests when SketchUp exits because MiniTest.autoload uses at_exit {}.

require "rubygems"
gem "minitest"
require "minitest"
require "minitest/spec"
require "minitest/mock"


# TestUp modifications of Minitest.
module Minitest

  class << self

    # In case some tests cause crashes it's nice if the name of the test is
    # output to the debugger before the test is run.
    # TODO(thomthom): Review if this can be done without overriding the method.
    unless method_defined?(:testup_run_one_method)
      alias :testup_run_one_method :run_one_method
      def run_one_method(*args)
        klass, method_name, reporter = args
        TestUp::Debugger.output("Running: #{klass.name}.#{method_name}")
        start_time = Time.now
        result = self.testup_run_one_method(*args)
        lapsed_time = Time.now - start_time
        TestUp::Debugger.output("> Elapsed time: #{lapsed_time}s")
        result
      end
    end

  end # class << self

  class Runnable
    class << self
      unless method_defined?(:testup_run)
        alias :testup_run :run
        # This is mostly a copy+paste of Minitest::Runnable.run method from v5.4.3.
        # It adds hooks called before and after a testcase is run.
        # It's to allow setup or tests that might be slow to setup.
        def run(reporter, options = {})
          filter = options[:filter] || '/./'
          filter = Regexp.new $1 if filter =~ /\/(.*)\//

          filtered_methods = self.runnable_methods.find_all { |m|
            filter === m || filter === "#{self}##{m}"
          }

          with_info_handler reporter do
            # Custom TestUp hook
            if !filtered_methods.empty? && self.respond_to?(:setup_testcase)
              TestUp::Debugger.output("setup_testcase: #{self.name}")
              self.setup_testcase
            end

            filtered_methods.each do |method_name|
              run_one_method self, method_name, reporter
            end

            # Custom TestUp hook
            if !filtered_methods.empty? && self.respond_to?(:teardown_testcase)
              TestUp::Debugger.output("teardown_testcase: #{self.name}")
              self.teardown_testcase
            end
          end
        end # def run
      end
    end # class << self
  end # class Runnable

end # module Minitest


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
# MiniTest uses Gem.find_files to look for extensions by globbing
# { }"minitest/*_plugin.rb". To avoid making a gem that needs installing, make
# use of the fact that by default Gem.find_files will search in $LOAD_PATH.
#
# Verify by checking after `MiniTest.run`:
# Minitest.extensions
# > ["pride", "testup"]
$LOAD_PATH << File.join(__dir__, 'minitest_plugins')

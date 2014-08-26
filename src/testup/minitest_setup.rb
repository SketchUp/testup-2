#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


# Load required extensions to the Sketchup::Console class in order to run the
# tests in the SketchUp console.
require File.join(__dir__, 'console.rb')
$stdout = TestUp::TESTUP_CONSOLE
$stderr = TestUp::TESTUP_CONSOLE


# Load MiniTest. This is a modification from minitest/autoload.rb which doesn't
# run the tests when SketchUp exits because MiniTest.autoload uses at_exit {}.

begin
  require "rubygems"
  gem "minitest"
rescue Gem::LoadError
  # do nothing
  raise # For now we want to raise it so we know something is wrong.
end

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
        self.testup_run_one_method(*args)
      end
    end

  end # class << self

end # module Minitest


# Configure Ruby such that the TestUp reporter can be found without creating a
# gem for it.
#
# MiniTest uses Gem.find_files to look for extensions by globbing
#{ }"minitest/*_plugin.rb". To avoid making a gem that needs installing, make
# use of the fact that by default Gem.find_files will search in $LOAD_PATH.
#
# Verify by checking after `MiniTest.run`:
# Minitest.extensions
# > ["pride", "testup"]
$LOAD_PATH << File.join(__dir__, 'minitest_plugins')

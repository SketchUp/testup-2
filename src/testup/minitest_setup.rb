# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


# Load required extensions to the Sketchup::Console class in order to run the
# tests in the SketchUp console.
require File.join(__dir__, 'sketchup_console.rb')


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

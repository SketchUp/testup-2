#-------------------------------------------------------------------------------
#
# Copyright 2014, Trimble Navigation Limited
#
# This software is provided as an example of using the Ruby interface
# to SketchUp.
#
# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#-------------------------------------------------------------------------------


# Third party dependencies.

# TODO(thomthom): Install minitest if it's missing.
require 'rubygems'
gem 'minitest'
require 'minitest'

# TODO(thomthom): Embed SKUI into project.
require 'SKUI/core.rb'


module TestUp

  ### Constants ### ------------------------------------------------------------

  SKETCHUP_CONSOLE.show # DEBUG

  PATH_IMAGES     = File.join(PATH, 'images').freeze
  PATH_JS_SCRIPTS = File.join(PATH, 'js').freeze

  # TEMP constant.
  PATH_OLD_TESTUP = 'C:/src/thomthom-su2014-pc/src/googleclient/sketchup/source/testing/testup'.freeze


  ### Dependencies ### ---------------------------------------------------------

  require File.join(PATH, 'compatibility.rb')
  require File.join(PATH, 'debug.rb')
  require File.join(PATH, 'sketchup_console.rb')
  require File.join(PATH, 'test_discoverer.rb')
  require File.join(PATH, 'test_window.rb')
  require File.join(PATH, 'ui.rb')


  ### UI ### -------------------------------------------------------------------

  self.init_ui


  ### Configuration ### --------------------------------------------------------

  @run_in_gui = true

  @verbose_console_tests = true

  # TODO(thomthom): Make configurable.
  @paths_to_testsuites = [
    File.join(__dir__, '..', '..', 'tests'),
    File.join(ENV['HOME'], 'SourceTree', 'SUbD', 'Ruby', 'tests'),
    File.join(PATH_OLD_TESTUP, 'tests')
  ]


  class << self
    attr_accessor :paths_to_testsuites
    attr_accessor :run_in_gui
    attr_accessor :verbose_console_tests
    attr_accessor :window
  end


  ### Extension ### ------------------------------------------------------------

  def self.toggle_testup
    @window ||= TestUpWindow.new
    @window.toggle
  end


  def self.toggle_run_in_gui
    @run_in_gui = !@run_in_gui
  end


  def self.toggle_verbose_console_tests
    @verbose_console_tests = !@verbose_console_tests
  end


  def self.run_tests
    unless @window && @window.visible?
      warn 'TestUp window not open.'
      UI.beep
      return
    end
    SKETCHUP_CONSOLE.show
    SKETCHUP_CONSOLE.clear
    testsuite = @window.selected_testsuite
    tests = @window.selected_tests
    puts "Running test suite: #{testsuite}"
    arguments = []
    arguments << "-n /^(#{tests.join('|')})$/"
    arguments << '--verbose' if @verbose_console_tests
    arguments << '--testup' if self.run_in_gui
    MiniTest.run(arguments)
    #puts Reporter.results.pretty_inspect
    @window.update_results(Reporter.results)
  end


end # module

#-------------------------------------------------------------------------------

file_loaded(__FILE__)

#-------------------------------------------------------------------------------

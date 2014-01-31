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

require 'rubygems'
begin
  gem 'minitest'
rescue Gem::LoadError
  Gem.install('minitest')
  gem 'minitest'
end
require 'minitest'


module TestUp

  ### Constants ### ------------------------------------------------------------

  SKETCHUP_CONSOLE.show # DEBUG

  PATH_IMAGES     = File.join(PATH, 'images').freeze
  PATH_JS_SCRIPTS = File.join(PATH, 'js').freeze

  # TEMP constant.
  PATH_OLD_TESTUP = 'C:/src/thomthom-su2014-pc/src/googleclient/sketchup/source/testing/testup'.freeze


  ### Dependencies ### ---------------------------------------------------------

  unless defined?(TestUp::SKUI)
    skui_path = File.join(PATH, 'third-party', 'SKUI', 'src', 'SKUI')
    require File.join(skui_path, 'embed_skui.rb')
    ::SKUI.embed_in(self)
  end

  require File.join(PATH, 'compatibility.rb')
  require File.join(PATH, 'debug.rb')
  require File.join(PATH, 'editor.rb')
  require File.join(PATH, 'preferences_window.rb')
  require File.join(PATH, 'settings.rb')
  require File.join(PATH, 'sketchup_console.rb')
  require File.join(PATH, 'taskbar_progress.rb')
  require File.join(PATH, 'test_discoverer.rb')
  require File.join(PATH, 'test_window.rb')
  require File.join(PATH, 'ui.rb')
  require File.join(PATH, 'win32.rb')


  ### UI ### -------------------------------------------------------------------

  self.init_ui


  ### Configuration ### --------------------------------------------------------

  defaults = {
    :editor => Editor.get_default,
    :run_in_gui => true,
    :verbose_console_tests => true,
    :paths_to_testsuites => [
      File.expand_path(File.join(__dir__, '..', '..', 'tests')),
      File.join(ENV['HOME'], 'SourceTree', 'SUbD', 'Ruby', 'tests'),
      File.join(PATH_OLD_TESTUP, 'tests')
    ]
  }
  @settings = Settings.new(PLUGIN_ID, defaults)


  class << self
    attr_reader :settings
    attr_accessor :window
  end


  def self.reset_settings
    # This will make the default values be used. (At least under Windows.)
    # TODO: Confirm this works under OSX.
    @settings[:editor] = nil
    @settings[:run_in_gui] = nil
    @settings[:verbose_console_tests] = nil
    @settings[:paths_to_testsuites] = nil
  end


  ### Extension ### ------------------------------------------------------------

  def self.toggle_testup
    @window ||= TestUpWindow.new
    @window.toggle
  end


  def self.toggle_run_in_gui
    @settings[:run_in_gui] = !@settings[:run_in_gui]
  end


  def self.toggle_verbose_console_tests
    @settings[:verbose_console_tests] = !@settings[:verbose_console_tests]
  end


  def self.run_tests
    unless @window && @window.visible?
      warn 'TestUp window not open.'
      UI.beep
      return
    end
    SKETCHUP_CONSOLE.show
    SKETCHUP_CONSOLE.clear
    testsuite = @window.active_testsuite
    tests = @window.selected_tests
    puts "Running test suite: #{testsuite}"
    arguments = []
    arguments << "-n /^(#{tests.join('|')})$/"
    arguments << '--verbose' if @settings[:verbose_console_tests]
    arguments << '--testup' if @settings[:run_in_gui]
    progress = TaskbarProgress.new
    begin
      progress.set_state(TaskbarProgress::INDETERMINATE)
      MiniTest.run(arguments)
    ensure
      progress.set_state(TaskbarProgress::NOPROGRESS)
    end
    #puts Reporter.results.pretty_inspect
    @window.update_results(Reporter.results)
  end


end # module

#-------------------------------------------------------------------------------

file_loaded(__FILE__)

#-------------------------------------------------------------------------------

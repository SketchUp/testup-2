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

  # <debug>
  if defined?(SKETCHUP_CONSOLE)
    SKETCHUP_CONSOLE.show
  elsif defined?(LAYOUT_CONSOLE)
    LAYOUT_CONSOLE.show
  end
  # /<debug>

  PATH_IMAGES     = File.join(PATH, 'images').freeze
  PATH_JS_SCRIPTS = File.join(PATH, 'js').freeze


  ### Dependencies ### ---------------------------------------------------------

  if defined?(UI::WebDialog)
    if !defined?(TestUp::SKUI)
      skui_path = File.join(PATH, 'third-party', 'SKUI', 'src', 'SKUI')
      require File.join(skui_path, 'embed_skui.rb')
      ::SKUI.embed_in(self)
    end
    require File.join(PATH, 'preferences_window.rb')
    require File.join(PATH, 'test_window.rb')
  end

  require File.join(PATH, 'console.rb')
  require File.join(PATH, 'coverage.rb')
  require File.join(PATH, 'debug.rb')
  require File.join(PATH, 'editor.rb')
  require File.join(PATH, 'settings.rb')
  require File.join(PATH, 'taskbar_progress.rb')
  require File.join(PATH, 'test_discoverer.rb')
  require File.join(PATH, 'ui.rb')
  require File.join(PATH, 'win32.rb')


  ### UI ### -------------------------------------------------------------------

  self.init_ui


  ### Configuration ### --------------------------------------------------------

  tests_path = File.join(__dir__, '..', '..', 'tests')
  if defined?(Sketchup)
    defaults = {
      :editor => Editor.get_default,
      :run_in_gui => true,
      :verbose_console_tests => true,
      :paths_to_testsuites => [
        File.expand_path(File.join(tests_path, 'SketchUp Ruby API')),
        File.expand_path(File.join(tests_path, 'TestUp'))
      ]
    }
  elsif defined?(Layout)
    defaults = {
      :editor => Editor.get_default,
      :run_in_gui => false,
      :verbose_console_tests => true,
      :paths_to_testsuites => [
        File.expand_path(File.join(tests_path, 'LayOut Ruby API'))#,
        #File.expand_path(File.join(tests_path, 'TestUp'))
      ]
    }
  end
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


  def self.run_tests_gui
    unless @window && @window.visible?
      warn 'TestUp window not open.'
      UI.beep
      return
    end
    testsuite = @window.active_testsuite
    tests = @window.selected_tests
    self.run_tests(tests, testsuite)
    #puts Reporter.results.pretty_inspect
    @window.update_results(Reporter.results)
  end

  # @example Run a test case:
  #   TestUp.run_tests(["TC_Edge#"])
  #
  # @example Run single test:
  #   TestUp.run_tests(["TC_Edge#start"])
  #
  # @example Run single test:
  #   tests = [
  #     "TC_Face#",
  #     "TC_Edge#start", "TC_Edge#end"
  #   ]
  #   TestUp.run_tests(tests)
  #
  # @param [Array<String>] list of tests or test cases to run.
  def self.run_tests(tests, testsuite = "Untitled")
    TESTUP_CONSOLE.show
    TESTUP_CONSOLE.clear
    puts "Discovering tests...\n"
    self.discover_tests
    puts "Running test suite: #{testsuite}"
    # If tests end with a `#` it means the whole test case should be run.
    # Automatically fix the regex.
    tests = tests.map { |pattern|
      if pattern =~ /\#$/
        pattern << ".+"
      end
      pattern
    }
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
  end


  # TODO(thomthom): Merge this with TestWindow.discover_tests.
  require "pp"
  def self.discover_tests
    #progress = TaskbarProgress.new
    begin
      #progress.set_state(TaskbarProgress::INDETERMINATE)
      paths = TestUp.settings[:paths_to_testsuites]
      test_discoverer = TestDiscoverer.new(paths)
      discoveries = test_discoverer.discover
    ensure
      #progress.set_state(TaskbarProgress::NOPROGRESS)
    end
    nil
  end


end # module

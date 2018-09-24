#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'

# TODO: Defer this to a point so it doesn't happen during SketchUp startup.
require 'testup/gem_helper'
TestUp::GemHelper.require('minitest', 'minitest', version: '5.4.3')

require 'testup/ui/runner' if defined?(UI::WebDialog)
require 'testup/app'
require 'testup/app_files'
require 'testup/config'
require 'testup/console'
require 'testup/debug'
require 'testup/editor'
require 'testup/taskbar_progress'
require 'testup/ui'
require 'testup/win32' if RUBY_PLATFORM =~ /mswin|mingw/


module TestUp

  extend AppFiles

  ### Constants ### ------------------------------------------------------------

  # Set to true to expose more debug tools in the UI when developing TestUp.
  # Sketchup.write_default(TestUp::PLUGIN_ID, 'dev-mode', true)
  DEBUG = Sketchup.read_default(PLUGIN_ID, 'dev-mode', false)

  if Sketchup.read_default(PLUGIN_ID, 'open_console_on_startup', false)
    if defined?(SKETCHUP_CONSOLE)
      SKETCHUP_CONSOLE.show
    elsif defined?(LAYOUT_CONSOLE)
      LAYOUT_CONSOLE.show
    end
  end

  PATH_UI         = File.join(PATH, 'ui').freeze
  PATH_IMAGES     = File.join(PATH, 'images').freeze


  class << self
    attr_accessor :window
  end


  self.init_ui
  App.process_arguments


  # Toggle the test runner dialog.
  def self.toggle_test_runner_window
    @window ||= TestRunnerWindow.new
    @window.toggle
  end

  # Call after switching dialog type to be used. Or after making changes that
  # require the dialog to be recreated.
  def self.reset_dialogs
    @window = nil
  end

  # TODO(thomthom): Move to API.
  # Toggle whether TestUp display the test results in a dialog or if it displays
  # it in the Ruby Console, similar to running Minitest from a terminal.
  def self.toggle_run_in_gui
    @settings[:run_in_gui] = !@settings[:run_in_gui]
  end

  # TODO(thomthom): Move to API.
  # Toggle verbose test results. Only relevant if TestUp is configured to output
  # results in the Ruby Console.
  def self.toggle_verbose_console_tests
    @settings[:verbose_console_tests] = !@settings[:verbose_console_tests]
  end

  # TODO(thomthom): Move this method. Maybe to the Reporter class if the
  # @num_tests_being_run instance variable also can be moved there.
  def self.update_testing_progress(num_tests_run)
    progress = TaskbarProgress.new
    progress.set_value(num_tests_run, @num_tests_being_run)
    nil
  end

  # TODO(thomthom): Move to API.
  # Prompts the user for a custom seed for the run-order of Minitest.
  # This allows the user to re-run a given test run.
  def self.set_custom_seed
    prompts = ['Seed (Negative for Random)']
    defaults = [self.settings[:seed] || -1]
    begin
      result = UI.inputbox(prompts, defaults, 'TestUp Custom Seed')
    rescue ArgumentError => error
      UI.messagebox(error.message)
      retry
    end
    return unless result
    seed = result[0].to_i < 0 ? nil : result[0].to_i
    self.settings[:seed] = seed
    seed
  end

  # Opens the Log directory in the system file explorer.
  def self.open_log_folder
    UI.openURL(log_path)
  end

end # module

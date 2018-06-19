#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'testup/app_files'
require 'testup/ui/runner'


# Third party dependencies.

require 'rubygems'
begin
  gem 'minitest'
rescue Gem::LoadError
  begin
    # Minitest 5.9.1 caused problems for reasons unknown. For now locking to
    # an older version known to work.
    Gem.install('minitest', '5.4.3')
  rescue Gem::LoadError
    # Needed because of Ruby 2.2. Ruby 2.0 did not need this. Seems like a bug.
    # This pattern is probably not that common, to be programmatically installing
    # gems.
  end
  gem 'minitest'
end
require 'minitest'


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


  ### Accessors ### ------------------------------------------------------------

  class << self
    attr_reader :settings
    attr_accessor :window
  end


  ### Dependencies ### ---------------------------------------------------------

  if defined?(UI::WebDialog)
    require 'testup/ui/runner'
  end

  require 'testup/console.rb'
  require 'testup/debug.rb'
  require 'testup/editor.rb'
  require 'testup/settings.rb'
  require 'testup/taskbar_progress.rb'
  require 'testup/ui.rb'
  if RUBY_PLATFORM =~ /mswin|mingw/
    require 'testup/win32.rb'
  end


  ### Configuration ### --------------------------------------------------------

  tests_path = File.join(__dir__, '..', '..', 'tests')
  if defined?(Sketchup)
    defaults = {
      :editor_application => Editor.get_default[0],
      :editor_arguments => Editor.get_default[1],
      :seed => nil,
      :run_in_gui => true,
      :verbose_console_tests => true,
      :paths_to_testsuites => [
        File.expand_path(File.join(tests_path, 'TestUp')),
        File.expand_path(File.join(tests_path, 'SketchUp Ruby API'))
      ]
    }
  elsif defined?(Layout)
    defaults = {
      :editor_application => Editor.get_default[0],
      :editor_arguments => Editor.get_default[1],
      :seed => nil,
      :run_in_gui => false,
      :verbose_console_tests => true,
      :paths_to_testsuites => [
        # ...
      ]
    }
  end
  @settings = Settings.new(PLUGIN_ID, defaults)


  ### UI ### -------------------------------------------------------------------

  self.init_ui


  def self.reset_settings
    # This will make the default values be used. (At least under Windows.)
    # TODO: Confirm this works under OSX.
    @settings[:debugger_output_enabled] = nil
    @settings[:editor] = nil
    @settings[:editor_application] = nil
    @settings[:editor_arguments] = nil
    @settings[:run_in_gui] = nil
    @settings[:verbose_console_tests] = nil
    @settings[:paths_to_testsuites] = nil
    @settings[:open_console_on_startup] = nil
  end


  ### Extension ### ------------------------------------------------------------

  def self.toggle_testup
    @window ||= TestRunnerWindow.new
    @window.toggle
  end

  # Call after switching dialog type to be used. Or after making changes that
  # require the dialog to be recreated.
  def self.reset_dialogs
    @window = nil
  end


  def self.toggle_run_in_gui
    @settings[:run_in_gui] = !@settings[:run_in_gui]
  end


  def self.toggle_verbose_console_tests
    @settings[:verbose_console_tests] = !@settings[:verbose_console_tests]
  end

  def self.update_testing_progress(num_tests_run)
    progress = TaskbarProgress.new
    progress.set_value(num_tests_run, @num_tests_being_run)
    # puts "Test Progress: #{num_tests_run} of #{@num_tests_being_run}"
    nil
  end

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

  def self.open_log_folder
    UI.openURL(log_path)
  end


  # TODO: Move to a separate utility file. Mixin?
  def self.suppress_warning_dialogs(&block)
    if Test.respond_to?(:suppress_warnings=)
      cache = Test.suppress_warnings?
      Test.suppress_warnings = true
    end
    block.call
  ensure
    if Test.respond_to?(:suppress_warnings=)
      Test.suppress_warnings = cache
    end
    nil
  end


  # TODO: Move to a separate utility file. Mixin?
  def self.defer(&block)
    done = false
    UI.start_timer(0, false) {
      # Any modal dialog would cause this timer to repeat. We avoid this
      # potential problem by breaking out early if we already have run.
      next if done
      done = true
      block.call
    }
  end


end # module

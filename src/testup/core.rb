#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'testup/app_files'


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

  # <debug>
  if defined?(SKETCHUP_CONSOLE)
    SKETCHUP_CONSOLE.show
  elsif defined?(LAYOUT_CONSOLE)
    LAYOUT_CONSOLE.show
  end
  # </debug>

  PATH_IMAGES     = File.join(PATH, 'images').freeze
  PATH_JS_SCRIPTS = File.join(PATH, 'js').freeze


  ### Accessors ### ------------------------------------------------------------

  class << self
    attr_reader :settings
    attr_accessor :window
  end


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
  require File.join(PATH, 'p4.rb')
  require File.join(PATH, 'settings.rb')
  require File.join(PATH, 'taskbar_progress.rb')
  require File.join(PATH, 'test_discoverer.rb')
  require File.join(PATH, 'ui.rb')
  if RUBY_PLATFORM =~ /mswin|mingw/
    require File.join(PATH, 'win32.rb')
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


  def self.run_tests_gui(run_config = nil)
    unless @window && @window.visible?
      warn 'TestUp window not open.'
      UI.beep
      return
    end
    # If a run_config is provided we use that instead of the selected tests.
    if run_config
      options = {
        seed: run_config[:seed]
      }
      testsuite = @window.active_testsuite # TODO(thomthom): get from run log.
      tests = run_config[:tests]
    else
      options = {}
      testsuite = @window.active_testsuite
      tests = @window.selected_tests
    end
    # Number of tests is currently incorrect as the list include stubs from the
    # manifest.
    @num_tests_being_run = tests.size
    if self.run_tests(tests, testsuite, options)
      #puts Reporter.results.pretty_inspect
      @window.update_results(Reporter.results)
    else
      @window.update_results({})
    end
  end

  def self.update_testing_progress(num_tests_run)
    progress = TaskbarProgress.new
    progress.set_value(num_tests_run, @num_tests_being_run)
    #puts "Test Progress: #{num_tests_run} of #{@num_tests_being_run}"
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
  def self.run_tests(tests, testsuite = "Untitled", options = {})
    TESTUP_CONSOLE.show
    TESTUP_CONSOLE.clear
    if tests.empty?
      puts "No tests selected to run."
      return false
    end
    # `options` argument is used when re-running test runs. It doesn't change
    # the user-selected seed.
    seed = options[:seed] || @settings[:seed]
    # Dump some test information that might be useful when reviewing test runs.
    TestUp::Debugger.output("Minitest Version: #{Minitest::VERSION}")
    puts "Minitest Version: #{Minitest::VERSION}"
    puts "Discovering tests...\n"
    self.discover_tests
    puts "Running test suite: #{testsuite}"
    puts "> Tests: #{tests.size}"
    puts "> Seed: #{seed}" if seed
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
    if seed
      arguments << '--seed'
      arguments << seed.to_s
    end
    arguments << '--testup' if @settings[:run_in_gui]
    progress = TaskbarProgress.new
    begin
      progress.set_state(TaskbarProgress::NORMAL)
      self.suppress_warning_dialogs {
        MiniTest.run(arguments)
      }
    rescue SystemExit
      puts 'Minitest called exit.'
    ensure
      progress.set_state(TaskbarProgress::NOPROGRESS)
    end
    puts "All tests done!"
    true
  end


  def self.discover_tests
    Debugger.time("TestUp.discover_tests") {
      progress = TaskbarProgress.new
      begin
        progress.set_state(TaskbarProgress::INDETERMINATE)
        paths = TestUp.settings[:paths_to_testsuites]
        test_discoverer = TestDiscoverer.new(paths)
        discoveries = test_discoverer.discover
      ensure
        progress.set_state(TaskbarProgress::NOPROGRESS)
      end
      discoveries
    }
  end


  # noinspection RubyResolve,RubyScope
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

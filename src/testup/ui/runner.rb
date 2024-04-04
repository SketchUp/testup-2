#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/ui/preferences'
require 'testup/ui/window'
require 'testup/api'
require 'testup/config'
require 'testup/debug'
require 'testup/debugger'
require 'testup/defer'
require 'testup/editor'
require 'testup/log'
require 'testup/runs'
require 'testup/taskbar_progress'


module TestUp
  class TestRunnerWindow < Window

    include Debug::Timing

    def initialize
      super
      # on(:close) {
      #   @preferences_window.close unless @preferences_window.nil?
      # }
    end

    def toggle
      time('TestRunnerWindow#toggle') { super }
    end

    # Clears and reloads the test suites.
    def reload
      return false unless visible?
      call('app.reset')
      true
    end

    private

    # @return [Hash]
    def window_options
      {
        :title           => PLUGIN_NAME,
        :preferences_key => PLUGIN_ID,
        :width           => 600,
        :height          => 400,
        :min_width       => 300,
        :min_height      => 300,
        :resizable       => true,
        # This cause errors in JS:
        #   Uncaught TypeError: Cannot read property 'style' of null
        #   document.body.style.overflow="hidden";
        # :scrollable      => false,
      }
    end

    # @return [String]
    def window_source
      filename = File.join(PATH_UI, 'html', 'runner.html')
    end

    def register_callbacks(dialog)
      super
      dialog.register_callback('runTests') { |dialog, test_suite_json|
        Log.trace :callback, "runTests(...)"
        event_run_tests(test_suite_json)
      }
      dialog.register_callback('reRunTests') { |dialog|
        Log.trace :callback, "reRunTests(...)"
        event_rerun_tests
      }
      dialog.register_callback('discoverTests') { |dialog, test_suites_json|
        Log.trace :callback, "discoverTests(...)"
        # Workaround for a sporadic crash where it appear SU crash, without
        # BugSplat when passing a JS object back to Ruby. For some reason it
        # had only been seen in this callback. Not sure if it's the content of
        # the object or the amount of data. The crash would manifest itself at
        # various places, which indicate some kind of memory issue.
        # The workaround is to have JS convert to JSON string and decode in
        # Ruby. Doesn't appear to have any significant impact on performance.
        test_suites_json = JSON.parse(test_suites_json)
        event_discover(test_suites_json)
      }
      dialog.register_callback('changeActiveTestSuite') { |dialog, title|
        Log.trace :callback, "event_change_testsuite(#{title})"
        event_change_testsuite(title)
      }
      dialog.register_callback('openSourceFile') { |dialog, location|
        Log.trace :callback, "openSourceFile(#{location})"
        event_open_source_file(location)
      }
      dialog.register_callback('openPreferences') { |dialog|
        Log.trace :callback, "openPreferences(.)"
        event_open_preferences
      }

      dialog
    end

    def event_window_ready
      time('event_window_ready') {
        discover_tests
        config = {
          :active_tab => TestUp.settings[:last_active_testsuite],
        }
        time('app.configure') { call('app.configure', config) }
      }
    end

    # @param [Hash] test_suite_json JSON data from JavaScript side.
    def event_run_tests(test_suite_json)
      Log.trace :callback, 'event_run_tests(...)'
      options = {
        ui: TestUp.settings[:run_in_gui],
      }
      if TestUp.settings[:seed] && TestUp.settings[:seed] >= 0
        options[:seed] = TestUp.settings[:seed]
      end
      test_suite = Report::TestSuite.from_hash(test_suite_json)
      TestUp::API.run_test_suite(test_suite, options: options) { |results|
        test_suite.merge_results(results)
        time('app.update_results') { call('app.update_results', test_suite) }
      }
    end

    def event_rerun_tests
      Log.trace :callback, 'event_rerun_tests(...)'
      # TODO: Refactor Runs into API.
      run_file = TestUp::Runs.select_config
      return unless run_file
      run_config = TestUp::Runs.read_config(run_file)
      options = {
        seed: run_config[:seed],
        ui: TestUp.settings[:run_in_gui],
      }
      tests = run_config[:tests]
      title = run_config[:test_suite]
      path = run_config[:path]
      raise 'path missing from run-config' if path.nil?

      # Bah... all this re-run code is really fragile... :(
      test_suite = TestUp::API.discover_tests([path]).first

      TestUp::API.run_tests(tests, title: title, path: path,  options: options) { |results|
        test_suite.merge_results(results)
        time('app.update_results') { call('app.update_results', test_suite) }
      }
    end

    # @param [Array<Hash>] test_suites_json JSON data from JavaScript side.
    def event_discover(test_suites_json)
      time('event_discover') {
        Log.trace :callback, 'event_discover(...)'
        test_suites = test_suites_json.map { |test_suite_json|
          Log.trace :discover, '> Report::TestSuite.from_hash(...)'
          Report::TestSuite.from_hash(test_suite_json)
        }
        Log.trace :discover, '> time("rediscover")'
        time('rediscover') { rediscover_tests(test_suites) }
      }
    end

    # @param [String] test_suite_title
    def event_change_testsuite(test_suite_title)
      TestUp.settings[:last_active_testsuite] = test_suite_title
    end

    def event_console_output(value)
      Debugger.output(value)
    end

    # @param [String] location
    def event_open_source_file(location)
      Log.trace :callback, "event_open_source_file(#{location})"
      result = location.match(/^(.+):(\d+)?$/)
      if result
        filename = result[1]
        line_number = result[2]
      else
        filename = location
        line_number = 0
      end
      unless File.exist?(filename)
        warn "Unable to find: #{filename}"
        warn 'Trying to account for encoding bug...'
        warn filename
        filename = filename.encode('ISO-8859-1')
        warn filename
        filename.force_encoding('UTF-8')
        warn filename
        warn "Exists: #{File.exist?(filename)}"
      end
      if File.exist?(filename)
        Editor.open_file(filename, line_number)
      else
        UI.beep
        warn "Unable to open: #{filename}"
        p filename.bytes
      end
    end

    def event_open_preferences
      # Work around a crash in SketchUp 2018 (maybe others) by deferring
      # the Preferences dialog. Maybe it's related to Chromiums event thread.
      Execution.defer {
        @preferences_window = PreferencesWindow.new
        @preferences_window.show
      }
    end

    # @return [nil]
    def discover_tests
      Log.trace :discover, "discover_tests()"
      paths = TestUp.settings[:paths_to_testsuites]
      discoveries = time('discover') { TestUp::API.discover_tests(paths) }
      Debugger.time("JS:update(...)") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          time('app.discover') { call('app.discover', discoveries) }
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
      }
      nil
    end

    # @param [Report::TestSuite] test_suites
    # @return [nil]
    def rediscover_tests(test_suites)
      Log.trace :discover, "rediscover_tests(...)"
      paths = TestUp.settings[:paths_to_testsuites]
      Log.trace :discover, "> TestUp::API.discover_tests(...):"
      discoveries = time('discover') { TestUp::API.discover_tests(paths) }
      Log.trace :discover, "> discoveries.map:"
      discoveries.map! { |discovery|
        test_suite = test_suites.find { |suite| suite.title == discovery.title }
        test_suite ? test_suite.rediscover(discovery) : discovery
      }
      Log.trace :discover, "> JS:rediscover:"
      Debugger.time("JS:rediscover(...)") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          time('app.rediscover') { call('app.rediscover', discoveries) }
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
      }
      nil
    end

  end # class
end # module

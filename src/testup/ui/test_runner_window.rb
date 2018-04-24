#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/api'
require 'testup/log'


module TestUp
  class TestRunnerWindow

    def initialize
      @dialog = create_dialog
      # on(:close) {
      #   @preferences_window.close unless @preferences_window.nil?
      # }
    end

    def toggle
      if @dialog.visible?
        @dialog.close
        @dialog = nil
      else
        @dialog ||= create_dialogs
        add_callbacks(@dialog)
        @dialog.show
      end
    end

    private

    def create_dialog
      filename = File.join(PATH, 'html', 'runner.html')
      options = {
        :title           => PLUGIN_NAME,
        :preferences_key => PLUGIN_ID,
        :width           => 600,
        :height          => 400,
        :min_width       => 300,
        :min_height      => 300,
        :resizable       => true,
        :scrollable      => false,
      }
      # dialog = UI::WebDialog.new(options)
      dialog = UI::HtmlDialog.new(options)
      dialog.set_file(filename)
      dialog
    end

    def add_callbacks(dialog)
      dialog.add_action_callback('ready') { |dialog, params|
        Log.info "ready(...)"
        event_testup_ready
      }
      dialog.add_action_callback('runTests') { |dialog, test_suite_json|
        Log.info "runTests(...)"
        event_run_tests(test_suite_json)
      }
      dialog.add_action_callback('discoverTests') { |dialog, test_suites_json|
        Log.info "discoverTests(...)"
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
      dialog.add_action_callback('openSourceFile') { |dialog, location|
        Log.info "openSourceFile(#{location})"
        event_open_source_file(location)
      }
      dialog
    end

    def call(function, *args)
      arguments = args.map { |arg| JSON.pretty_generate(arg) }
      argument_js = arguments.join(', ');
      @dialog.execute_script("#{function}(#{argument_js});")
    end

    # TODO: Move to a mix-in module.
    def time(title = '', &block)
      start = Time.now
      result = block.call
      lapsed_time = Time.now - start
      Log.debug "Timing #{title}: #{lapsed_time}s"
      result
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

    # @param [Report::TestSuite] test_suite
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

    def event_testup_ready
      config = {
        :active_tab => TestUp.settings[:last_active_testsuite],
        :debugger   => ScriptDebugger.attached?,
        :path       => PATH
      }
      # TODO: Push config to dialog.
      discover_tests
    end

    # @param [Hash] test_suite_json JSON data from JavaScript side.
    def event_run_tests(test_suite_json)
      Log.info 'event_run_tests(...)'
      options = {}
      test_suite = Report::TestSuite.from_hash(test_suite_json)
      TestUp::API.run_test_suite(test_suite, options: options) { |results|
        test_suite.merge_results(results)
        call('app.update_results', test_suite)
      }
    end

    # TODO: Remove
    def event_testup_run
      # To avoid the "Slow running script" dialog in IE the call to execute
      # the tests is deferred.
      TestUp.defer {
        discover_tests # TODO(thomthom): Why is this needed?
        TestUp.run_tests_gui
      }
    end

    def event_testup_rerun
      run_file = TestUp::Runs.select_config
      return unless run_file
      run_config = TestUp::Runs.read_config(run_file)
      # To avoid the "Slow running script" dialog in IE the call to execute
      # the tests is deferred.
      TestUp.defer {
        discover_tests # TODO(thomthom): Why is this needed?
        TestUp.run_tests_gui(run_config)
        Log.info "Re-run of: #{run_file}"
      }
    end

    # @param [Array<Hash>] test_suites_json JSON data from JavaScript side.
    def event_discover(test_suites_json)
      Log.info 'event_discover(...)'
      test_suites = test_suites_json.map { |test_suite_json|
        Log.trace :discover, '> Report::TestSuite.from_hash(...)'
        Report::TestSuite.from_hash(test_suite_json)
      }
      Log.trace :discover, '> time("rediscover")'
      time('rediscover') { rediscover_tests(test_suites) }
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
      Log.info "TestUp.open_source_file(#{location})"
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

    def event_on_open_preferences
      #@preferences_window ||= PreferencesWindow.new
      @preferences_window = PreferencesWindow.new
      @preferences_window.show
    end

  end # class
end # module

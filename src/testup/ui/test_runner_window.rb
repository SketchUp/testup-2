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

    # @param [Hash] test_suite JSON data from JavaScript side.
    def event_run_tests(test_suite)
      Log.debug 'event_run_tests'
      options = {}
      tests = selected_tests(test_suite)
      TestUp::API.run_tests(tests, test_suite['title'], options) { |results|
        merge_results(test_suite, results)
        call('app.update_test_suite', test_suite)
      }
    end

    def merge_results(test_suite, results)
      results.each { |result|
        test_case_name, test_name = result[:testname].split('#')
        test_case = test_suite['test_cases'].find { |tc| tc['title'] == test_case_name }
        test = test_case['tests'].find { |t| t['title'] == test_name }
        test['result'] = {
          run_time: result[:time],
          assertions: result[:assertions],
          skipped: result[:skipped],
          passed: result[:passed],
          error: result[:error],
          # TODO: Compute :failed
          failures: result[:failures], # TODO: This is really 'messages'
        }
      }
      test_suite
    end

    def selected_tests(test_suite)
      tests = []
      test_suite['test_cases'].each { |test_case|
        test_case['tests'].each { |test|
          next unless test['enabled']
          tests << "#{test_case['title']}##{test['title']}"
        }
      }
      tests
    end

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
        Log.debug "ready(...)"
        event_testup_ready
      }
      dialog.add_action_callback('runTests') { |dialog, run_config|
        Log.debug "runTests(...)"
        event_run_tests(run_config)
      }
      dialog.add_action_callback('discoverTests') { |dialog, run_config|
        Log.debug "discoverTests(...)"
        event_discover
      }
      dialog.add_action_callback('openSourceFile') { |dialog, location|
        Log.debug "openSourceFile(#{location})"
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

    def discover_tests
      discoveries = time('discover') { TestUp::API.discover_tests }
      discoveries = time('restructure') { restructure(discoveries) }
      Debugger.time("JS:update(...)") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          time('app.update') { call('app.update', discoveries) }
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
      }
      nil
    end

    # TODO: Consider creating this structure when discovering.
    # TODO: Create custom classes for each type, which support to_json.
    def restructure(discoveries)
      discoveries.map { |test_suite_name, test_suite|
        missing = test_suite[:missing_coverage]
        test_cases = restructure_test_cases(test_suite[:testcases])
        merge_missing_tests(test_cases, missing)
        # TODO: Clean up these pesky .to_s calls. (Find out why we get Class instead of String)
        {
          id: test_suite_name.to_s,
          title: test_suite_name.to_s,
          test_cases: test_cases,
          coverage: test_suite[:coverage],
          missing_coverage: test_suite[:missing_coverage],
        }
      }
    end

    def merge_missing_tests(test_cases, missing)
      missing.each { |test_case_name, tests|
        missing_test_case = missing[test_case_name] || {}
        missing_tests = restructure_missing_tests(missing_test_case)
        # TODO: Clean up these pesky .to_s calls. (Find out why we get Class instead of String)
        test_case = test_cases.find { |tc| tc[:title].to_s == test_case_name }
        if test_case.nil?
          test_case = ensure_test_case(test_case_name)
          test_cases << test_case
        end
        test_case[:tests].concat(missing_tests)
        test_case[:tests].sort! { |a, b|
          a[:title].to_s <=> b[:title].to_s
        }
      }
      test_cases.sort! { |a, b| a[:title].to_s <=> b[:title].to_s }
      nil
    end

    def ensure_test_case(test_case_name)
      {
        id: test_case_name,
        title: test_case_name,
        tests: [],
        enabled: true,
        expanded: false,
      }
    end

    def restructure_missing_tests(tests)
      tests.map { |test_name|
        {
          id: test_name,
          title: test_name,
          enabled: true,
          missing: true,
          result: nil,
        }
      }
    end

    def restructure_test_cases(test_cases)
      test_cases.map { |test_case_name, tests|
        {
          id: test_case_name,
          title: test_case_name,
          tests: restructure_tests(tests),
          enabled: true,
          expanded: false,
        }
      }
    end

    def restructure_tests(tests)
      tests.map { |test_name|
        {
          id: test_name,
          title: test_name,
          enabled: true,
          missing: false,
          result: nil,
          # result: {
            # run_time: 0.0,
            # assertions: 0;
            # skipped: false,
            # passed: false,
            # error: false,
            # failures: [],
            # failures: [
            #   {
            #     type: "Error",
            #     message: "ArgumentError: Hello World",
            #     location: "tests/TestUp/TC_TestErrors.rb:32",
            #   },
            # ],
          # }
        }
      }
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
        Log.debug "Re-run of: #{run_file}"
      }
    end

    def event_discover
      # TODO: Merge newly discovered tests with existing data.
      discover_tests
    end

    def event_change_testsuite(testsuite)
      TestUp.settings[:last_active_testsuite] = testsuite
    end

    def event_console_output(value)
      Debugger.output(value)
    end

    def event_open_source_file(location)
      Log.debug "TestUp.open_source_file(#{location})"
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

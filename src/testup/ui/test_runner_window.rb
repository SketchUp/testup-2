#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

# require 'testup/runs'

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
      else
        @dialog.show
      end
    end

    def event_run_tests(test_suite)
      puts "event_run_tests"
      options = {}
      tests = selected_tests(test_suite)
      TestUp.instance_variable_set(:@num_tests_being_run, tests.size) # TODO: Hack!
      if TestUp.run_tests(tests, test_suite["title"], options)
        # puts Reporter.results.pretty_inspect
        merge_results(test_suite, Reporter.results)
        # JSON.pretty_generate(test_suite)
        call('app.update_test_suite', test_suite)
        # @window.update_results(Reporter.results)
      else
        # @window.update_results({})
      end
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
      test_suite["test_cases"].each { |test_case|
        test_case["tests"].each { |test|
          next unless test["enabled"]
          tests << "#{test_case["title"]}##{test["title"]}"
        }
      }
      tests
    end

    # --------------------------------------------------------------------------

    # def active_testsuite
      # @bridge.call('TestUp.TestSuites.active')
    # end

    # def selected_tests
      # @bridge.call('TestUp.TestSuite.selected_tests')
    # end

    # @param [Array<Hash>] results
    def update_results(results)
      # Debugger.time('JS:TestUp.update_results') {
      #   @bridge.call('TestUp.update_results', results)
      # }
    end

    # Clears and reloads the test suites.
    def reload
      # return false unless visible?
      # self.bridge.call('TestUp.reset')
      # discover_tests
      # true
    end

    private

    def create_dialog
      filename = File.join(PATH, 'html', 'runner.html')
      options = {
        :title           => PLUGIN_NAME,
        :preferences_key => PLUGIN_ID,
        :width           => 400,
        :height          => 400,
        :resizable       => true
      }
      # dialog = UI::WebDialog.new(options)
      dialog = UI::HtmlDialog.new(options)
      dialog.set_file(filename)
      dialog.add_action_callback('ready') { |dialog, params|
        puts 'Log: Ready'
        event_testup_ready
      }
      dialog.add_action_callback('runTests') { |dialog, run_config|
        event_run_tests(run_config)
      }
      dialog
    end

    def call(function, *args)
      arguments = args.map { |arg| JSON.pretty_generate(arg) }
      argument_js = arguments.join(', ');
      @dialog.execute_script("#{function}(#{argument_js});")
    end

    # Intercept callbacks from the SKUI window before passing it on to SKUI.
    def callback_handler(webdialog, callback, arguments)
      case callback
      when 'TestUp.on_script_debugger_attached'
        ScriptDebugger.attach
      when 'TestUp.on_run'
        event_testup_run
      when 'TestUp.on_rerun'
        event_testup_rerun
      when 'TestUp.on_discover'
        event_discover
      when 'TestUp.on_open_source_file'
        event_opent_source_file(arguments[0])
      when 'TestUp.on_preferences'
        event_on_open_preferences
      when 'TestUp.TestSuites.on_change'
        event_change_testsuite(arguments[0])
      when 'TestUp.Console.output'
        event_console_output(arguments[0])
      end
    ensure
      super
      nil
    end

    def discover_tests
      discoveries = restructure(TestUp.discover_tests)
      # TODO: Restructure the test data to include the required state for
      # - Expanded Testcase
      # - Enabled Testcase
      # - Enabled Test
      Debugger.time("JS:update(...)") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          call('app.update', discoveries)
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
      }
      nil
    end

    TEST_NOT_RUN = 0
    TEST_SUCCESS = 1 << 0
    TEST_SKIPPED = 1 << 1
    TEST_FAILED  = 1 << 2
    TEST_ERROR   = 1 << 3
    TEST_MISSING = 1 << 4

    # TODO: Consider creating this structure when discovering.
    # TODO: Create custom classes for each type, which support to_json.
    def restructure(discoveries)
      discoveries.map { |test_suite_name, test_suite|
        {
          id: test_suite_name,
          title: test_suite_name,
          test_cases: restructure_test_cases(test_suite[:testcases]),
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
          # state: TEST_NOT_RUN | TEST_MISSING,
        }
      }
    end

    def restructure_tests(tests)
      tests.map { |test_name|
        {
          id: test_name,
          title: test_name,
          enabled: true,
          # state: TEST_NOT_RUN,
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
        puts "Re-run of: #{run_file}"
      }
    end

    def event_discover
      discover_tests
    end

    def event_change_testsuite(testsuite)
      TestUp.settings[:last_active_testsuite] = testsuite
    end

    def event_console_output(value)
      Debugger.output(value)
    end

    def event_opent_source_file(location)
      puts "TestUp.open_source_file(#{location})"
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

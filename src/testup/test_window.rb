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


module TestUp
  class TestUpWindow < SKUI::Window

    def initialize
      options = {
        :title           => PLUGIN_NAME,
        :preferences_key => PLUGIN_ID,
        :width           => 400,
        :height          => 400,
        :resizable       => true
      }
      super(options)
      [
        'testup.js',
        'commands.js',
        'toolbar.js',
        'tabs.js',
        'testsuites.js',
        'testsuite.js',
        'testcase.js',
        'test.js',
        'statusbar.js'
      ].each { |script_basename|
        script = File.join(PATH_JS_SCRIPTS, script_basename)
        window.add_script(script)
      }
      on(:scripts_loaded) {
        puts 'All scripts loaded!'
        event_testup_ready()
      }
      on(:close) {
        @preferences_window.close unless @preferences_window.nil?
      }
    end

    def active_testsuite
      @bridge.call('TestUp.TestSuites.active')
    end

    def selected_tests
      @bridge.call('TestUp.TestSuite.selected_tests')
    end

    # TODO: Fix this in SKUI.
    # Hack, as SKUI currently doesn't support subclassing of it's controls.
    def typename
      SKUI::Window.to_s.split('::').last
    end

    # @param [Array<Hash>] results
    def update_results(results)
      @bridge.call('TestUp.update_results', results)
    end

    # Clears and reloads the test suites.
    def reload
      return false unless visible?
      self.bridge.call('TestUp.reset')
      discover_tests()
      true
    end

    private

    # Intecept callbacks from the SKUI window before passing it on to SKUI.
    def callback_handler(webdialog, params)
      #puts( '>> TestWindow Callback' )
      callback, *arguments = params.split('||')
      #puts "#{callback}(#{arguments})"
      case callback
      when 'TestUp.on_script_debugger_attached'
        ScriptDebugger.attach
      when 'TestUp.on_run'
        event_testup_run()
      when 'TestUp.on_discover'
        event_discover()
      when 'TestUp.on_open_source_file'
        event_opent_source_file(arguments[0])
      when 'TestUp.on_preferences'
        event_on_open_preferences()
      when 'TestUp.TestSuites.on_change'
        event_change_testsuite(arguments[0])
      end
    ensure
      super
      nil
    end

    def discover_tests
      progress = TaskbarProgress.new
      begin
        progress.set_state(TaskbarProgress::INDETERMINATE)
        paths = TestUp.settings[:paths_to_testsuites]
        test_discoverer = TestDiscoverer.new(paths)
        discoveries = test_discoverer.discover
        self.bridge.call('TestUp.TestSuites.update', discoveries)
      ensure
        progress.set_state(TaskbarProgress::NOPROGRESS)
      end
      nil
    end

    def event_testup_ready
      config = {
        :active_tab => TestUp.settings[:last_active_testsuite],
        :debugger   => ScriptDebugger.attached?,
        :path       => PATH
      }
      self.bridge.call('TestUp.init', config)
      discover_tests()
    end

    def event_testup_run
      discover_tests()
      TestUp.run_tests_gui
    end

    def event_discover
      discover_tests()
    end

    def event_change_testsuite(testsuite)
      TestUp.settings[:last_active_testsuite] = testsuite
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
      Editor.open_file(filename, line_number)
    end

    def event_on_open_preferences()
      #@preferences_window ||= PreferencesWindow.new
      @preferences_window = PreferencesWindow.new
      @preferences_window.show
    end

  end # class
end # module

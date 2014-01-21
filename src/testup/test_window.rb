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
        'toolbar.js',
        'testsuites.js',
        'testcases.js'
      ].each { |script_basename|
        script = File.join(PATH_JS_SCRIPTS, script_basename)
        window.add_script(script)
      }
      on(:scripts_loaded) {
        puts 'All scripts loaded!'
        event_testup_ready()
      }
    end

    def selected_testsuite
      @bridge.call('TestUp.TestSuites.selected')
    end

    def selected_tests
      @bridge.call('TestUp.TestCases.selected_tests')
    end

    # Hack, as SKUI currently doesn't support subclassing of it's controls.
    def typename
      SKUI::Window.to_s.split('::').last
    end

    private

    # Intecept callbacks from the SKUI window before passing it on to SKUI.
    def callback_handler(webdialog, params)
      #puts( '>> TestWindow Callback' )
      callback, *arguments = params.split('||')
      case callback
      when 'TestUp.on_run'
        event_testup_run()
      end
    ensure
      super
      nil
    end

    def discover_tests
      test_discoverer = TestDiscoverer.new(TestUp.paths_to_testsuites)
      tests = test_discoverer.discover
      self.bridge.call('TestUp.TestSuites.update', tests)
      nil
    end

    def event_testup_ready
      self.bridge.call('TestUp.init', PATH)
      discover_tests()
    end

    def event_testup_run
      TestUp.run_tests
    end

  end # class
end # module

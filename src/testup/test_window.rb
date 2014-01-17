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
      testup_script = File.join(PATH_JS_SCRIPTS, 'testup.js')
      window.add_script(testup_script)
    end

    # Hack, as SKUI currently doesn't support subclassing of it's controls.
    def typename
      SKUI::Window.to_s.split( '::' ).last
    end

    private

    # Intecept callbacks from the SKUI window before passing it on to SKUI.
    def callback_handler(webdialog, params)
      #puts( '>> TestWindow Callback' )
      callback, *arguments = params.split('||')
      case callback
      when 'TestUp.on_ready'
        event_testup_ready()
      when 'TestUp.on_run'
        event_testup_run()
      end
    ensure
      super
      nil
    end

    def event_testup_ready
      self.bridge.call('TestUp.init', PATH)

      testsuites = TestUp.discover_testsuites(TestUp.paths_to_testsuites)
      self.bridge.call('TestUp.update_testsuites', testsuites)
    end

    def event_testup_run
      TestUp.run_tests
    end

  end # class
end # module

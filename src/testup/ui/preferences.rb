#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/ui/window'
require 'testup/debug'
require 'testup/log'
require 'testup/ui'


module TestUp
  class PreferencesWindow < Window

    include Debug::Timing

    private

    def show_window
      @dialog.show_modal
    end

    # @return [Hash]
    def window_options
      {
        :title           => "#{PLUGIN_NAME} - Preferences",
        :preferences_key => "#{PLUGIN_ID}_Preferences",
        :width           => 650,
        :height          => 550,
        :min_width       => 650,
        :min_height      => 550,
        :max_width       => 800,
        :max_height      => 600,
        :resizable       => true,
      }
    end

    # @return [String]
    def window_source
      filename = File.join(PATH_UI, 'html', 'preferences.html')
    end

    def register_callbacks(dialog)
      super
      dialog.register_callback('addPath') { |dialog|
        Log.info "addPath"
        event_add_path
      }
      dialog.register_callback('editPath') { |dialog, path, index|
        Log.info "editPath"
        event_edit_path(path, index)
      }
      dialog.register_callback('save') { |dialog, config|
        Log.info "save(...)"
        event_save_config(config)
      }
      dialog.register_callback('cancel') { |dialog|
        Log.info "cancel()"
        event_cancel
      }
      dialog
    end

    def event_window_ready
      config = {
        test_suite_paths: TestUp.settings[:paths_to_testsuites],
        editor: {
          executable: Editor.application,
          arguments: Editor.arguments,
        },
      }
      time('app.configure') { call('app.configure', config) }
    end

    def event_add_path
      message = 'Select folders that includes the test cases.'
      paths = SystemUI.select_directory(
        select_multiple: true,
        message: message
      )
      call('app.addPaths', paths) unless paths.nil?
    end

    def event_edit_path(path, index)
      new_path = SystemUI.select_directory(directory: path)
      call('app.updatePath', new_path, index) unless new_path.nil?
    end

    def event_save_config(config)
      p ["TODO: Save config", config]
      @dialog.close
    end

    def event_cancel
      @dialog.close
    end

  end # class
end # module

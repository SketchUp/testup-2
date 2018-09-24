#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/log'


module TestUp
  module Adapter

    # @param [Hash] options
    def initialize(options)
      options[:dialog_title] = options[:title] if options.key?(:title)
      super(options)
    end

    # @return [Hash]
    def register_callback
      raise NotImplementedError
    end

    # Sets up the callbacks for the dialogs. To add additional callbacks
    # override this method and remember to call `super`
    #
    # @param [UI::HtmlDialog, UI::WebDialog] dialog
    # @return [UI::HtmlDialog, UI::WebDialog]
    def register_callbacks(dialog)
      dialog.add_action_callback('ready') { |dialog|
        Log.info "ready(...)"
        event_window_ready
      }
      dialog.add_action_callback('js_error') { |dialog, error|
        Log.info "js_error(...)"
        event_js_error(error)
      }
      dialog
    end


  end # class
end # module

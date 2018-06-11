#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/ui/adapters/webdialog'
require 'testup/ui/adapters/htmldialog' if defined?(UI::HtmlDialog)
require 'testup/log'


module TestUp
  class Window

    # Used when JavaScript errors are forwarded from WebDialogs to Ruby.
    class JavaScriptError < RuntimeError; end

    def initialize
      @dialog = create_dialog
    end

    def toggle
      if @dialog.visible?
        @dialog.close
        @dialog = nil
      else
        @dialog ||= create_dialog
        register_callbacks(@dialog)
        @dialog.show
      end
    end

    private

    # @return [Hash]
    def window_options
      raise NotImplementedError
    end

    # @return [String]
    def window_source
      raise NotImplementedError
    end

    # Called when the dialog is ready. (Callback must be made from JS)
    def event_window_ready
    end

    # Sets up the callbacks for the dialogs. To add additional callbacks
    # override this method and remember to call `super`
    #
    # @param [UI::HtmlDialog, UI::WebDialog] dialog
    # @return [UI::HtmlDialog, UI::WebDialog]
    def register_callbacks(dialog)
      dialog.register_callback('ready') { |dialog|
        Log.info "ready(...)"
        event_window_ready
      }
      dialog.register_callback('js_error') { |dialog, error|
        Log.info "js_error(...)"
        event_js_error(error)
      }
      dialog
    end

    # Determines whether to use `UI::HtmlDialog` or `UI::WebDialog` dialogs.
    #
    # @return [Class]
    def window_class
      window_adapter = TestUp.settings[:window_adapter]
      case window_adapter
      when 'default', nil
        defined?(HtmlDialogAdapter) ? HtmlDialogAdapter : WebDialogAdapter
      when 'html_dialog'
        HtmlDialogAdapter
      when 'web_dialog'
        WebDialogAdapter
      else
        raise "Unknown adapter: #{window_adapter}"
      end
    end

    # @return [UI::HtmlDialog, UI::WebDialog]
    def create_dialog
      filename = window_source
      dialog = window_class.new(window_options)
      dialog.set_file(filename)
      dialog
    end

    # @param [String] function JavaScript function to call.
    # @param [Array<#to_json>] args parameters for the JavaScript call.
    # @return [nil]
    def call(function, *args)
      Log.info "call(#{function}, ...)"
      arguments = args.map { |arg| JSON.pretty_generate(arg) }
      argument_js = arguments.join(', ');
      @dialog.execute_script("#{function}(#{argument_js});")
      nil
    end

    # @param [Hash] js_error
    def is_legacy_ie?(js_error)
      user_agent = js_error['user-agent']
      return false unless user_agent.is_a?(String)
      return false unless user_agent.include?('MSIE')
      document_mode = js_error['document-mode']
      return false unless document_mode.is_a?(Numeric)
      document_mode < 9
    end

    # Converts a JavaScript error to a Ruby error.
    #
    # @param [Hash] js_error
    def event_js_error(js_error)
      # Have to set the backtrace after the error has been thrown in order for
      # it to propagate properly. Otherwise the backtrace will point back to
      # this location.
      # IE8 is completely unable to load Vue. We don't want to trigger the
      # error dialog for this old version. The dialogs should display a
      # message using conditional IE comments.
      return if is_legacy_ie?(js_error)
      begin
        p js_error['user-agent']
        p js_error['document-mode']
        raise JavaScriptError, js_error['message']
      rescue JavaScriptError => error
        error.set_backtrace(js_error['backtrace'])
        raise
      end
    end

  end # class
end # module
